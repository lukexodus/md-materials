## Transaction Handling in Mutations

A transaction groups multiple database operations into a single atomic unit — either all operations succeed and are committed, or any failure causes all of them to be rolled back. In tRPC mutations, transactions are critical wherever a procedure performs more than one write that must stay consistent. Without them, a partial failure leaves the database in a corrupted intermediate state.

---

### Why Mutations Need Transactions

A mutation that performs a single write is inherently atomic. The moment a mutation performs two or more writes, a failure between them creates inconsistency.

```ts
// ❌ No transaction — vulnerable to partial failure
create: protectedProcedure
  .input(z.object({ name: z.string() }))
  .mutation(async ({ ctx, input }) => {
    const order = await ctx.db.order.create({
      data: { userId: ctx.user.id, name: input.name },
    });

    // If this throws, the order exists but has no line items
    await ctx.db.orderItem.createMany({
      data: input.items.map((i) => ({ orderId: order.id, ...i })),
    });

    // If this throws, inventory was never decremented
    await ctx.db.product.update({
      where: { id: input.productId },
      data:  { stock: { decrement: input.quantity } },
    });

    return order;
  }),
```

**Key Points:**

- Each `await` is a separate database round-trip — a crash, timeout, or constraint violation between them leaves the previous writes in place
- The solution is to wrap all related writes in a transaction so the database treats them as one indivisible operation

---

### Basic Transaction Pattern (Prisma)

```ts
create: protectedProcedure
  .input(z.object({
    name:      z.string(),
    productId: z.string(),
    quantity:  z.number().int().positive(),
    items:     z.array(z.object({ productId: z.string(), qty: z.number() })),
  }))
  .mutation(async ({ ctx, input }) => {
    return ctx.db.$transaction(async (tx) => {
      const order = await tx.order.create({
        data: { userId: ctx.user.id, name: input.name },
      });

      await tx.orderItem.createMany({
        data: input.items.map((i) => ({
          orderId:   order.id,
          productId: i.productId,
          quantity:  i.qty,
        })),
      });

      await tx.product.update({
        where: { id: input.productId },
        data:  { stock: { decrement: input.quantity } },
      });

      return order;
    });
  }),
```

**Key Points:**

- `tx` is a scoped Prisma client — all operations on it participate in the same transaction
- The return value of the `$transaction` callback becomes the return value of the mutation
- Any thrown error inside the callback rolls back all operations [Inference: standard transaction semantics; behavior is ultimately determined by your database engine]
- Always use `tx` inside the callback — using `ctx.db` instead of `tx` issues queries outside the transaction

---

### Basic Transaction Pattern (Drizzle)

```ts
create: protectedProcedure
  .mutation(async ({ ctx, input }) => {
    return ctx.db.transaction(async (tx) => {
      const [order] = await tx
        .insert(orders)
        .values({ userId: ctx.user.id, name: input.name })
        .returning();

      await tx.insert(orderItems).values(
        input.items.map((i) => ({
          orderId:   order.id,
          productId: i.productId,
          quantity:  i.qty,
        }))
      );

      await tx
        .update(products)
        .set({ stock: sql`${products.stock} - ${input.quantity}` })
        .where(eq(products.id, input.productId));

      return order;
    });
  }),
```

---

### Basic Transaction Pattern (Kysely)

```ts
create: protectedProcedure
  .mutation(async ({ ctx, input }) => {
    return ctx.db.transaction().execute(async (trx) => {
      const order = await trx
        .insertInto('orders')
        .values({ user_id: ctx.user.id, name: input.name })
        .returningAll()
        .executeTakeFirstOrThrow();

      await trx
        .insertInto('order_items')
        .values(input.items.map((i) => ({
          order_id:   order.id,
          product_id: i.productId,
          quantity:   i.qty,
        })))
        .execute();

      await trx
        .updateTable('products')
        .set((eb) => ({ stock: eb('stock', '-', input.quantity) }))
        .where('id', '=', input.productId)
        .execute();

      return order;
    });
  }),
```

---

### Error Handling Inside Transactions

Throwing inside a transaction triggers rollback. `TRPCError` can be thrown inside the callback safely — tRPC will catch it after the transaction rolls back and forward it to the client.

```ts
transfer: protectedProcedure
  .input(z.object({
    fromId: z.string(),
    toId:   z.string(),
    amount: z.number().positive(),
  }))
  .mutation(async ({ ctx, input }) => {
    return ctx.db.$transaction(async (tx) => {
      const sender = await tx.account.findUnique({
        where: { id: input.fromId },
      });

      if (!sender) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Sender not found.' });
      }

      if (sender.balance < input.amount) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Insufficient balance.',
        });
      }

      if (sender.userId !== ctx.user.id) {
        throw new TRPCError({ code: 'FORBIDDEN' });
      }

      await tx.account.update({
        where: { id: input.fromId },
        data:  { balance: { decrement: input.amount } },
      });

      await tx.account.update({
        where: { id: input.toId },
        data:  { balance: { increment: input.amount } },
      });

      return { success: true };
    });
  }),
```

**Key Points:**

- Validation and authorization checks belong inside the transaction when they read data that the transaction also modifies — this prevents time-of-check/time-of-use (TOCTOU) race conditions [Inference]
- `TRPCError` thrown inside `$transaction` propagates through the transaction rollback and surfaces to the client as a normal tRPC error [Inference: depends on how the ORM and tRPC interact at the boundary; verify for your stack]

---

### TOCTOU Race Conditions

Reading a value, checking it, then acting on it in separate queries creates a window where another request can modify the data between the read and the write.

```ts
// ❌ Vulnerable to race condition
// Two concurrent requests could both pass the stock check
// and both decrement, driving stock below zero
const product = await ctx.db.product.findUnique({ where: { id } });

if (product.stock < input.quantity) {
  throw new TRPCError({ code: 'BAD_REQUEST' });
}

await ctx.db.product.update({
  where: { id },
  data:  { stock: { decrement: input.quantity } },
});
```

```ts
// ✅ Atomic update with a conditional WHERE clause
// The decrement only applies if stock is sufficient
const result = await ctx.db.$executeRaw`
  UPDATE products
  SET    stock = stock - ${input.quantity}
  WHERE  id    = ${input.productId}
  AND    stock >= ${input.quantity}
`;

if (result === 0) {
  throw new TRPCError({
    code: 'BAD_REQUEST',
    message: 'Insufficient stock.',
  });
}
```

Alternatively, use a transaction with a locking read:

```ts
// Prisma with serializable isolation
await ctx.db.$transaction(
  async (tx) => {
    const product = await tx.product.findUnique({
      where: { id: input.productId },
    });

    if (!product || product.stock < input.quantity) {
      throw new TRPCError({ code: 'BAD_REQUEST' });
    }

    await tx.product.update({
      where: { id: input.productId },
      data:  { stock: { decrement: input.quantity } },
    });
  },
  { isolationLevel: 'Serializable' }
);
```

**Key Points:**

- `Serializable` isolation is the strongest level — it prevents phantom reads and write skew at the cost of higher lock contention [Inference]
- The `isolationLevel` option is Prisma-specific; Drizzle and Kysely have their own equivalents [Inference: verify API for your ORM and database version]
- Atomic SQL (`UPDATE ... WHERE stock >= quantity`) is often simpler and more performant than serializable transactions for straightforward inventory patterns [Inference]

---

### Isolation Levels

Isolation levels control how much concurrent transactions can observe each other's in-progress changes. Higher isolation trades consistency for throughput.

| Level | Prevents | Notes |
| --- | --- | --- |
| `ReadUncommitted` | Nothing | Can read uncommitted ("dirty") data from other transactions |
| `ReadCommitted` | Dirty reads | Default in most databases; non-repeatable reads still possible |
| `RepeatableRead` | Dirty + non-repeatable reads | Same row read twice gives same result; phantom reads possible |
| `Serializable` | All anomalies | Transactions behave as if executed sequentially |

```ts
// Prisma — specifying isolation level
await ctx.db.$transaction(async (tx) => { ... }, {
  isolationLevel: 'RepeatableRead',
  timeout:        5000, // ms before transaction is forcibly aborted
  maxWait:        2000, // ms to wait for a connection slot
});
```

```ts
// Kysely — specifying isolation level
await ctx.db.transaction()
  .setIsolationLevel('repeatable read')
  .execute(async (trx) => { ... });
```

**Key Points:**

- Default isolation level varies by database — PostgreSQL defaults to `ReadCommitted`; MySQL InnoDB defaults to `RepeatableRead` [Unverified: verify against your specific database version and configuration]
- Most mutations work correctly at `ReadCommitted`; only choose a higher level when you have identified a specific anomaly that requires it [Inference]

---

### Extracting Transaction Logic into Helper Functions

When transaction logic grows complex, extracting it into helper functions keeps procedures readable. The helper must accept the transaction client, not import the global `db`.

```ts
// server/lib/inventory.ts
import type { Prisma } from '@prisma/client';
import { TRPCError } from '@trpc/server';

type TxClient = Prisma.TransactionClient;

export async function decrementStock(
  tx: TxClient,
  productId: string,
  quantity: number
) {
  const product = await tx.product.findUnique({ where: { id: productId } });

  if (!product) throw new TRPCError({ code: 'NOT_FOUND' });
  if (product.stock < quantity) {
    throw new TRPCError({ code: 'BAD_REQUEST', message: 'Insufficient stock.' });
  }

  return tx.product.update({
    where: { id: productId },
    data:  { stock: { decrement: quantity } },
  });
}

export async function createAuditLog(
  tx: TxClient,
  opts: { userId: string; action: string; resourceId: string }
) {
  return tx.auditLog.create({ data: opts });
}
```

```ts
// server/routers/order.ts
import { decrementStock, createAuditLog } from '../lib/inventory';

place: protectedProcedure
  .mutation(async ({ ctx, input }) => {
    return ctx.db.$transaction(async (tx) => {
      const order = await tx.order.create({
        data: { userId: ctx.user.id },
      });

      await decrementStock(tx, input.productId, input.quantity);

      await createAuditLog(tx, {
        userId:     ctx.user.id,
        action:     'order.place',
        resourceId: order.id,
      });

      return order;
    });
  }),
```

**Key Points:**

- Helper functions receive `tx` (transaction client) as their first argument — this is the only way to make them participate in the caller's transaction
- The same helper can be called both inside and outside a transaction by accepting either `TxClient` or `PrismaClient` via a union type [Inference]
- `Prisma.TransactionClient` is the type Prisma exposes for the scoped `tx` argument; Drizzle and Kysely have analogous types

---

### Nested Transactions and Savepoints

True nested transactions are not universally supported. Prisma and most ORMs implement them via savepoints in databases that support it (PostgreSQL, MySQL 8+).

```ts
// Prisma — nested transaction creates a savepoint in PostgreSQL
await ctx.db.$transaction(async (outerTx) => {
  await outerTx.order.create({ data: { ... } });

  // If this inner block fails, only operations after the savepoint roll back
  // Behavior depends on database and Prisma version [Inference]
  await ctx.db.$transaction(async (innerTx) => {
    await innerTx.notification.create({ data: { ... } });
  });
});
```

**Key Points:**

- Savepoint behavior varies by ORM version and database engine [Unverified: test with your specific stack]
- A safer pattern is to keep transaction boundaries flat — one `$transaction` per mutation, helpers accept the same `tx` reference [Inference]
- If an inner operation is non-critical (e.g., sending a notification), run it after the outer transaction commits rather than inside it

---

### Non-Critical Side Effects After Commit

Some operations — sending emails, triggering webhooks, logging to external services — should not block or roll back the primary transaction if they fail.

```ts
place: protectedProcedure
  .mutation(async ({ ctx, input }) => {
    // Core business logic in transaction
    const order = await ctx.db.$transaction(async (tx) => {
      const o = await tx.order.create({ data: { userId: ctx.user.id } });
      await decrementStock(tx, input.productId, input.quantity);
      return o;
    });

    // Side effects after commit — failures do not roll back the order
    try {
      await sendOrderConfirmationEmail(order.id, ctx.user.email);
    } catch (err) {
      console.error('Email failed — order committed:', err);
      // Do not re-throw; the mutation should still succeed
    }

    return order;
  }),
```

**Key Points:**

- Side effects outside the transaction run only if the transaction committed — there is no risk of emailing the user and then rolling back [Inference]
- If the side effect is critical (e.g., a financial ledger entry), it belongs inside the transaction, not after it
- For guaranteed delivery of post-commit side effects, consider an outbox pattern — write a job record inside the transaction and process it asynchronously [Inference]

---

### Transaction Flow Diagram

<svg viewBox="0 0 700 500" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<rect width="700" height="500" fill="#0f1117" rx="12"/>
<text x="350" y="34" text-anchor="middle" fill="#e2e8f0" font-size="15" font-weight="bold">Transaction Flow in a tRPC Mutation</text>
<!-- Mutation called -->
<rect x="255" y="60" width="190" height="44" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1.5"/>
<text x="350" y="87" text-anchor="middle" fill="#94a3b8">Mutation Called</text>
<!-- Arrow down -->
<line x1="350" y1="104" x2="350" y2="140" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Transaction begins -->
<rect x="230" y="140" width="240" height="44" rx="8" fill="#1a2744" stroke="#3b82f6" stroke-width="1.5"/>
<text x="350" y="163" text-anchor="middle" fill="#93c5fd">BEGIN TRANSACTION</text>
<!-- Arrow down -->
<line x1="350" y1="184" x2="350" y2="210" stroke="#3b82f6" stroke-width="1.5" marker-end="url(#ablue)"/>
<!-- Op 1 -->
<rect x="240" y="210" width="220" height="36" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.2"/>
<text x="350" y="233" text-anchor="middle" fill="#94a3b8">Write 1 — tx.order.create()</text>
<line x1="350" y1="246" x2="350" y2="262" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Op 2 -->
<rect x="240" y="262" width="220" height="36" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.2"/>
<text x="350" y="285" text-anchor="middle" fill="#94a3b8">Write 2 — tx.product.update()</text>
<line x1="350" y1="298" x2="350" y2="314" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Op 3 -->
<rect x="240" y="314" width="220" height="36" rx="6" fill="#1e293b" stroke="#334155" stroke-width="1.2"/>
<text x="350" y="337" text-anchor="middle" fill="#94a3b8">Write 3 — tx.auditLog.create()</text>
<!-- Fork: success / failure -->
<line x1="350" y1="350" x2="350" y2="374" stroke="#475569" stroke-width="1.5" marker-end="url(#a1)"/>
<!-- Success path -->
<line x1="350" y1="374" x2="220" y2="406" stroke="#22c55e" stroke-width="1.5" marker-end="url(#agreen)"/>
<rect x="90" y="406" width="160" height="44" rx="8" fill="#14532d" stroke="#22c55e" stroke-width="1.5"/>
<text x="170" y="426" text-anchor="middle" fill="#86efac">COMMIT</text>
<text x="170" y="442" text-anchor="middle" fill="#86efac" font-size="10">all writes persist</text>
<!-- Failure path -->
<line x1="350" y1="374" x2="490" y2="406" stroke="#ef4444" stroke-width="1.5" marker-end="url(#ared)"/>
<rect x="440" y="406" width="190" height="44" rx="8" fill="#3b0a0a" stroke="#ef4444" stroke-width="1.5"/>
<text x="535" y="426" text-anchor="middle" fill="#fca5a5">ROLLBACK</text>
<text x="535" y="442" text-anchor="middle" fill="#fca5a5" font-size="10">all writes undone</text>
<!-- Labels -->

<text x="268" y="396" text-anchor="middle" fill="`#86efac`" font-size="10">success</text>
<text x="432" y="396" text-anchor="middle" fill="`#fca5a5`" font-size="10">throw / error</text>

<!-- Side effects after commit -->
<line x1="170" y1="450" x2="170" y2="474" stroke="#22c55e" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#agreen)"/>
<text x="170" y="488" text-anchor="middle" fill="#64748b" font-size="10">side effects (email, webhook)</text>
<defs>
<marker id="a1" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#475569"/>
</marker>
<marker id="ablue" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#3b82f6"/>
</marker>
<marker id="agreen" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#22c55e"/>
</marker>
<marker id="ared" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
<path d="M0,0 L8,4 L0,8 Z" fill="#ef4444"/>
</marker>
</defs>
</svg>

---

### Common Mistakes

| Mistake | Problem | Fix |
| --- | --- | --- |
| Using `ctx.db` inside a `$transaction` callback | Queries run outside the transaction | Use the `tx` / `trx` argument exclusively inside the callback |
| No transaction on multi-write mutations | Partial failure leaves inconsistent state | Wrap all related writes in one transaction |
| Critical side effects inside the transaction | Slow or failing external calls block commit or cause unnecessary rollback | Move non-critical side effects after the transaction returns |
| Validation reads outside the transaction | TOCTOU race condition — state may change between check and write | Move validation reads inside the transaction |
| Ignoring thrown errors from helpers | Silent partial rollback | Let errors propagate naturally; do not swallow inside the transaction callback |
| Deeply nested transactions | Savepoint behavior varies by database — hard to reason about | Keep transaction boundaries flat; pass `tx` down to helpers |

---

**Next Steps:** Structuring routers in large tRPC applications — organizing procedures across multiple files, nested routers, and shared middleware composition.