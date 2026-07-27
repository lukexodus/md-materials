# Mastering Lisp: A Comprehensive Guide

## A Note on Dialects Before We Start

"Lisp" isn't a single language — it's a family. This guide teaches the *ideas* using clean **Scheme** syntax first, then shifts to **Common Lisp** for the advanced material (macros, the object system, the condition system), because that's where those features are most fully developed. Where it matters, differences are called out explicitly. By the end, you'll be able to read and write any Lisp dialect, because the family shares one nervous system even when the skin differs.

You'll want a REPL to follow along. Options:
- **Scheme**: install Racket (`raco pkg install r7rs`) or use `scheme` (Chez/Guile)
- **Common Lisp**: install SBCL (`sbcl` — free, fast, the de facto standard implementation)

Everything shown is real, runnable code. Paste it in and watch it happen — that's not optional advice, that's the actual practice of learning Lisp.

---

## Part 1: Why Lisp Looks the Way It Does

Before touching syntax, you need the one idea that explains everything else about Lisp: **in Lisp, programs and data are the same shape.**

In most languages, code is text that gets parsed into an internal tree structure (an AST) that you, the programmer, never directly touch. In Lisp, the tree structure *is* the syntax you write. There's no separate "AST" hidden behind the scenes — what you type is already the tree.

This is called **homoiconicity** ("same representation"). It sounds abstract, but it has an extremely concrete consequence: if code and data are the same shape, then a Lisp program can treat other Lisp code as ordinary data — inspect it, transform it, generate it — using the exact same tools it uses for lists and numbers. This is the root of *why* macros exist and *why* they're so much more powerful in Lisp than "macros" in C or Rust.

The parentheses are not decoration. They exist because a tree needs an unambiguous way to show nesting, and `(operator argument argument ...)` is the simplest possible notation for a tree node. Every `(...)` is a node. That's it. Once you see it that way, the parens stop looking arbitrary — they are the *entire syntax*, doing one job, doing it completely uniformly, everywhere in the language. There is no operator precedence to memorize, no "is this a statement or an expression" distinction, no special-casing. `(+ 1 2)` and `(if x y z)` and `(defun f (x) x)` are all the exact same kind of tree node: a list, whose first element says what to do with the rest.

This uniformity is what makes Lisp both easy to parse (a good thing for tools) and easy to *generate* (a good thing for you, the programmer, when you start writing macros that write code).

### The REPL is not a debugging tool — it's the primary interface

In most languages you write a file, compile or run it, see output, edit, repeat. Lisp was designed around a different loop: you have a live process, and you *converse* with it. You define a function, call it immediately, see the result, redefine it if it's wrong, call it again — all without restarting anything. This is called **REPL-driven development** (Read-Eval-Print Loop), and it's not a nice-to-have, it's the intended way to write Lisp. Programs are "grown," not "written then run."

Keep this in mind as you go through every example below: type it into a REPL. Don't just read it.

---

## Part 2: Syntax and the REPL

### The basic shape

Everything in Lisp is either an **atom** (a single value: a number, a symbol, a string) or a **list** (a parenthesized sequence, possibly containing atoms and other lists). That's the entire syntax. There is nothing else to learn about Lisp's grammar. Everything below is semantics — what these shapes *mean* — not new syntax.

```scheme
42                  ; an atom (a number)
"hello"             ; an atom (a string)
foo                 ; an atom (a symbol — a name)
(+ 1 2)             ; a list — and when evaluated, a function call
(1 2 3)             ; a list — but NOT a function call (1 isn't a function)
```

At the REPL:

```
> (+ 1 2)
3
> (* 3 4)
12
> (+ 1 (* 2 3))
7
```

Notice: the operator comes *first*, inside the parens, followed by its operands. This is **prefix notation**. `(+ 1 2)` reads as "apply `+` to `1` and `2`," not "1 plus 2." This looks strange for exactly one day and then becomes completely natural, because it means every operation — arithmetic, function calls, control flow — uses the exact same shape. There's no special case for "infix operators" the way there is in almost every other language.

### Evaluation rule

When Lisp evaluates a list `(a b c ...)`, the default rule is:
1. Evaluate `a`, `b`, `c`, ... (in most implementations, left to right)
2. Treat the value of `a` as a function (or special form/macro — more on this distinction soon)
3. Apply it to the values of `b`, `c`, ...

```scheme
> (+ (* 2 3) (* 4 5))
26
```

Here, `(* 2 3)` evaluates to `6`, `(* 4 5)` evaluates to `20`, then `+` is applied: `6 + 20 = 26`.

### Not everything follows the evaluation rule: special forms

Some things that *look* like function calls don't evaluate all their arguments the normal way. `if` is the classic example:

```scheme
> (if (> 3 2) "yes" "no")
"yes"
```

`if` does NOT evaluate all three of `(> 3 2)`, `"yes"`, and `"no"` and then "apply if" — that would be nonsensical (and wasteful: it would evaluate the branch you're *not* taking). Instead, `if` is a **special form**: the language itself knows this shape and gives it custom evaluation rules — evaluate the condition, then evaluate *only* the chosen branch.

This distinction — ordinary function vs. special form vs. macro — matters a lot later. For now: special forms are a small, fixed set built into the language (`if`, `define`/`defun`, `lambda`, `let`, `quote`, and a handful of others). Everything else you'll write is either a regular function or, eventually, a macro you define yourself that behaves like a special form.

### Defining things

Scheme:
```scheme
(define x 10)
(define (square n) (* n n))

> (square 5)
25
```

Common Lisp:
```lisp
(defparameter *x* 10)      ; CL convention: "earmuffs" for globals
(defun square (n) (* n n))

> (square 5)
25
```

(Aside on style: Common Lisp convention wraps global variable names in asterisks — `*x*` — precisely so that when you see a bare symbol used inside a function, you know at a glance it's *not* referring to a global. This matters more in CL than Scheme because CL has more dynamic-scope escape hatches, discussed later.)

### Comments

```scheme
; single-line comment
#| block
   comment |#
```

---

## Part 3: Lists, Cons Cells, and the Real Data Model

This is the section most tutorials rush, and it's the one you actually need to sit with, because *everything* — including code itself, as you'll see in Part 5 — is built from one primitive: the **cons cell**.

### The cons cell

A cons cell is a pair of two pointers, conventionally called `car` and `cdr` (historical names from the original IBM 704 implementation — "Contents of the Address/Decrement Register" — the names stuck for 65+ years and you just have to accept them).

```scheme
> (cons 1 2)
(1 . 2)
```

That's a single cons cell: `car` is `1`, `cdr` is `2`. The `.` in the printed form (called **dotted pair notation**) shows you're looking at a raw pair, not a proper list.

```scheme
> (car (cons 1 2))
1
> (cdr (cons 1 2))
2
```

### Lists are chains of cons cells

A "list" like `(1 2 3)` is not a primitive at all — it's *syntactic sugar* for a chain of cons cells, where each `cdr` points to the next cell, and the final `cdr` is a special empty-list marker (`'()`, also written `nil` in many contexts):

```scheme
(1 2 3)
; is really shorthand for:
(cons 1 (cons 2 (cons 3 '())))
```

You can verify this:
```scheme
> (cons 1 (cons 2 (cons 3 '())))
(1 2 3)
```

They print identically because they *are* identical. This is not a coincidence or a special case — this is the actual, literal representation of every list you will ever write in Lisp.

Once this clicks, `car` and `cdr` stop being mysterious:

```scheme
> (car '(1 2 3))
1
> (cdr '(1 2 3))
(2 3)
```

`car` gives you the first element. `cdr` gives you "everything after the first element" — which, because of the chain structure, is itself a valid list (specifically, it's the rest of the chain). This is why list-processing in Lisp is naturally recursive: **peel off the `car`, recurse on the `cdr`, stop when you hit `'()`.** You'll use this pattern constantly.

### Why "quote" matters here

You may have noticed `'(1 2 3)` above instead of `(1 2 3)`. This is critical and easy to get wrong as a beginner:

```scheme
> (1 2 3)
Error: 1 is not a function
```

Without the quote, `(1 2 3)` is evaluated as a function call — Lisp tries to call `1` as a function on arguments `2` and `3`, and fails, because `1` isn't a function. `'(1 2 3)` (short for `(quote (1 2 3))`) tells Lisp: "don't evaluate this — treat it as literal data."

This is your first real glimpse of homoiconicity in action: `(1 2 3)` and `(+ 1 2)` have the *exact same structure* (a list, first element `1` or `+`). The only difference between "this is a function call" and "this is a plain list of numbers" is whether you evaluate it or quote it. Code and data are, structurally, the same thing — evaluation is what turns a piece of data into a computation. Keep this in your back pocket; it's the entire premise of Part 5 and everything after it.

### Common list operations

```scheme
> (list 1 2 3)          ; construct a list (cleaner than nested cons)
(1 2 3)
> (length '(1 2 3))
3
> (append '(1 2) '(3 4))
(1 2 3 4)
> (reverse '(1 2 3))
(3 2 1)
> (member 2 '(1 2 3))   ; returns the sublist starting at the match, or #f
(2 3)
> (null? '())           ; is this the empty list?
#t
```

(Common Lisp uses `nil` instead of `#f`/`#t`, and predicate names often end in `p` — `null`, `listp`, `numberp` — rather than `?`. Both conventions mean the same thing.)

### `let` — local bindings

```scheme
> (let ((x 1) (y 2))
    (+ x y))
3
```

`let` creates new local names, all bound "simultaneously" (none can see the others being defined in the same `let`). If you need each binding to see the previous ones, use `let*`:

```scheme
> (let* ((x 1) (y (+ x 1)))
    (+ x y))
3
```

Try `(let ((x 1) (y (+ x 1))) ...)` — it errors, because plain `let`'s `x` isn't visible while `y` is being computed. This distinction trips up almost everyone once; after that, it's automatic.

---

## Part 4: Functions, Recursion, and Closures

### Recursion is the default loop

Classic Lisps had no `for`/`while` loops at all — recursion *was* iteration. Modern dialects have loop constructs (`do`, `loop` in CL; various forms in Scheme), but recursive style remains the idiomatic default for list processing, because it mirrors the cons-cell structure directly (peel `car`, recurse on `cdr`).

```scheme
(define (sum-list lst)
  (if (null? lst)
      0
      (+ (car lst) (sum-list (cdr lst)))))

> (sum-list '(1 2 3 4 5))
15
```

Trace it: base case is the empty list (sum is `0`); recursive case adds the first element to the sum of the rest. This shape — base case matching `'()`, recursive case peeling `car`/`cdr` — is the single most common pattern you'll write in Lisp.

### Tail calls (and an honest caveat)

A **tail call** is a recursive call that is the *very last thing* a function does — nothing happens after it returns. Scheme's standard *guarantees* tail-call optimization: a tail-recursive function runs in constant stack space, indistinguishable from a loop.

```scheme
(define (sum-iter lst acc)
  (if (null? lst)
      acc
      (sum-iter (cdr lst) (+ acc (car lst)))))   ; tail call — the recursive
                                                    ; call IS the return value,
                                                    ; nothing left to do after

> (sum-iter '(1 2 3 4 5) 0)
15
```

Compare to `sum-list` above: there, the recursive call is *not* the last thing that happens — `(+  (car lst) ...)` has to wait for the recursive call to return and then add to it. That's not a tail call, and in Scheme it will (eventually, for large enough lists) grow the stack.

**Important honest caveat:** Common Lisp's standard does *not* require tail-call optimization — whether it happens depends on the implementation and optimization settings. SBCL does it under normal optimization settings; you should not casually assume every CL implementation will save you here the way Scheme guarantees. This is a genuine, often-glossed-over difference between the dialects, not a nitpick — if you write deeply-recursive CL code assuming TCO and move to an implementation/settings where it isn't happening, you'll get stack overflows that wouldn't happen in Scheme. When in doubt in CL, use explicit iteration constructs (`loop`, `dotimes`, `dolist`) for hot paths where stack depth matters.

### Functions are values (first-class functions)

```scheme
> (define (apply-twice f x) (f (f x)))
> (apply-twice square 3)
81
```

`square` is passed *as a value* — not called, just handed over as data — and `apply-twice` calls it internally. This works because functions in Lisp are ordinary values, same status as numbers or strings. You can put them in lists, return them from other functions, and — most importantly — create them anonymously.

### Lambda — anonymous functions

```scheme
> (lambda (n) (* n n))
#<procedure>
> ((lambda (n) (* n n)) 5)
25
> (apply-twice (lambda (n) (+ n 1)) 3)
5
```

In fact, `(define (square n) (* n n))` is itself sugar for `(define square (lambda (n) (* n n)))` — naming a function is really just binding a name to a lambda value. This is worth internalizing: there's no deep distinction in Lisp between "a function" and "a value that happens to be callable."

### Closures

A closure is a function bundled with the environment it was created in — meaning it can "remember" and use variables from where it was defined, even after that defining context has finished executing.

```scheme
(define (make-counter)
  (let ((count 0))
    (lambda ()
      (set! count (+ count 1))
      count)))

> (define c1 (make-counter))
> (c1)
1
> (c1)
2
> (define c2 (make-counter))
> (c2)
1
> (c1)
3
```

`c1` and `c2` are two *independent* closures, each holding its own private `count` — because each call to `make-counter` creates a fresh `let` environment, and the returned lambda "closes over" that specific environment. This is how you get private, encapsulated state without needing classes or objects — closures predate object-oriented programming in Lisp by over a decade, and this exact pattern (a closure as a stateful "object") is one of the cleanest illustrations of why.

---

## Part 5: Code as Data — Quote, Quasiquote, and Eval

This is where Part 3's "quote" aside pays off directly.

### `quote` revisited

```scheme
> (quote (+ 1 2))
(+ 1 2)
> '(+ 1 2)
(+ 1 2)
```

`'(+ 1 2)` is *not* `3`. It's a three-element list whose elements happen to be the symbol `+`, the number `1`, and the number `2`. It is inert data — Lisp is refusing to evaluate it, just handing it back as-is.

### `eval` — evaluating data as code

```scheme
> (eval '(+ 1 2))
3
```

`eval` takes a piece of data that *represents* code (a list shaped like an expression) and actually evaluates it. This is the other half of the coin: `quote` turns code into inert data; `eval` turns data back into a live computation. Because these are both ordinary operations available to you as a programmer — not compiler-internals you can't touch — you can construct expressions programmatically and then run them:

```scheme
(define (make-adder n)
  (eval (list '+ n 10)))

> (make-adder 5)
15
```

`(list '+ n 10)` builds the list `(+ 5 10)` as plain data (using `n`'s *value*, since `n` isn't quoted), and `eval` runs it. This is a toy example — you'd never actually write it this way in practice, since `(+ n 10)` directly would be simpler — but it demonstrates the real mechanism underneath something you'll use constantly: **macros**, which do exactly this kind of code-construction, just with much better ergonomics and, crucially, at *compile time* rather than runtime.

### Quasiquote and unquote — the practical tool for building code

Writing `(list '+ n 10)` gets unwieldy fast for anything nontrivial. Quasiquote (`` ` ``) and unquote (`,`) solve this: quasiquote is like quote, except you can "poke holes" in it with unquote to splice in evaluated values.

```scheme
> (define n 5)
> `(+ ,n 10)
(+ 5 10)
```

Read `` `(+ ,n 10) `` as: "this is mostly quoted data, *except* evaluate `n` and splice its value in right there." Compare to the clunkier `(list '+ n 10)` above — same result, much more readable, and this readability is *exactly* why quasiquote/unquote is the standard tool for writing macros, which is the very next section.

There's also `,@` (unquote-splicing), which splices a *list's elements* in rather than the list itself:

```scheme
> (define nums '(1 2 3))
> `(+ ,@nums)
(+ 1 2 3)
```

versus

```scheme
> `(+ ,nums)
(+ (1 2 3))     ; wrong shape — nums is spliced in as ONE element, a sublist
```

The difference matters a great deal once you're generating code — `,` inserts one value; `,@` unpacks a list into multiple values in place. Getting this backwards is one of the most common macro bugs, and it's worth deliberately trying both here so you *see* the wrong-shaped output at least once before you hit it by accident in a real macro.

---

## Part 6: Macros — Where Mastery Actually Lives

Everything above was building toward this. **A macro is a function that runs at compile/expansion time, takes unevaluated code as input, and produces new code as output**, which is then evaluated in its place. This is only possible — and only sane to do casually — because of homoiconicity: the input and output of a macro are both just ordinary Lisp data (lists), the same data you've been manipulating since Part 3.

### Why macros, when you already have functions?

Functions can't do certain things, because function arguments are *always* evaluated before the function receives them (Part 2's evaluation rule). Recall `if` from Part 2 — it needed special evaluation rules precisely because it must *not* evaluate the untaken branch. You can't write `if` as an ordinary function; a function's arguments would all get evaluated before `if` even started running.

Macros let *you* — not just the language's built-in special forms — define new syntax with exactly this kind of custom evaluation control. This is the real ceiling of Lisp: in most languages, `if`, `for`, and friends are permanently baked into the compiler, off-limits to you. In Lisp, you have the same tool the language designers used to build those forms in the first place.

### A minimal example: `my-if`

Let's rebuild `if` ourselves, in Common Lisp, to see the mechanism nakedly:

```lisp
(defmacro my-if (condition then-branch else-branch)
  `(cond (,condition ,then-branch)
         (t ,else-branch)))
```

```lisp
> (my-if (> 3 2) "yes" "no")
"yes"
```

Walk through what actually happens:
1. You write `(my-if (> 3 2) "yes" "no")`.
2. Before evaluation, the macro expander runs `my-if` as a function — but on the *unevaluated* code `(> 3 2)`, `"yes"`, `"no"` (as raw data, bound to `condition`, `then-branch`, `else-branch`).
3. The macro body builds and returns new code: `` `(cond (,condition ,then-branch) (t ,else-branch)) `` — using quasiquote exactly as you just learned — which, with the arguments spliced in, produces the list `(cond ((> 3 2) "yes") (t "no"))`.
4. *That* generated code is what actually gets evaluated, not the original `my-if` call.

You can watch step 3 happen directly with `macroexpand-1`:

```lisp
> (macroexpand-1 '(my-if (> 3 2) "yes" "no"))
(COND ((> 3 2) "yes") (T "no"))
```

This is enormously useful in practice — whenever a macro does something unexpected, `macroexpand-1` (or `macroexpand` for full expansion) shows you exactly what code it actually generated, which is almost always where the bug is hiding.

### A more useful example: `my-unless`

```lisp
(defmacro my-unless (condition body)
  `(if (not ,condition) ,body))

> (my-unless (> 2 3) (print "2 is not greater than 3"))
2 is not greater than 3
```

### The classic real-world use case: `while`

Neither Scheme nor CL has a built-in `while` loop as a primitive the way C does (CL actually does have `loop`, which is its own enormous topic — but let's build a simple `while` ourselves to see macros solve a real problem):

```lisp
(defmacro my-while (condition &body body)
  `(loop
     (unless ,condition (return))
     ,@body))
```

```lisp
> (let ((i 0))
    (my-while (< i 5)
      (print i)
      (incf i)))
0
1
2
3
4
```

Notice `&body body` (equivalent to `&rest body` but signals to editors/tools that this parameter holds a body of code, for indentation purposes) and `,@body` — unquote-splicing, from Part 5 — to splice *all* the body forms into the generated `loop`, not just one.

This is exactly the situation where functions genuinely cannot help you: `my-while`'s condition must be re-checked on every iteration, un-evaluated until the macro decides to check it — a function couldn't receive `condition` without evaluating it once, immediately, before the loop even starts.

### The classic gotcha: variable capture

Here's a subtle bug that macro-writers hit constantly. Suppose you write a macro that introduces a temporary variable:

```lisp
;; DON'T do this — buggy version
(defmacro my-square-bad (x)
  `(let ((val ,x)) (* val val)))
```

This looks fine in isolation:
```lisp
> (my-square-bad 5)
25
```

But watch what happens here:
```lisp
> (let ((val 10))
    (my-square-bad val))
100    ; correct here, but only by luck
```

That happened to work. Now try this:
```lisp
> (let ((val 3))
    (+ val (my-square-bad 4)))
```

Expand it mentally: `` `(let ((val ,x)) (* val val)) `` with `x` bound to the *symbol* `val` (since we're passing the variable `val`, unevaluated, as the macro argument) produces `(let ((val val)) (* val val))` — the macro's internal `val` **captures** the caller's `val`, and you get a wrong or undefined result instead of `3 + 16 = 19`, depending on the exact scoping rules in play. The macro's "private" temporary variable collided with a variable of the same name from the *caller's* context — a context the macro author never anticipated and has no control over.

The fix is `gensym` — generate a guaranteed-unique symbol name that can't possibly collide with anything the caller wrote:

```lisp
;; correct version
(defmacro my-square (x)
  (let ((val-sym (gensym)))
    `(let ((,val-sym ,x)) (* ,val-sym ,val-sym))))
```

Now the temporary is something like `#:G1234` internally — a name the caller could never accidentally type — so no collision is possible regardless of what the caller names their own variables.

**Rule of thumb**: any time your macro introduces its own internal temporary variable (not one supplied by the caller), `gensym` it. This single gotcha is probably the most common real-world macro bug, and now you know both why it happens (mechanically — it falls straight out of the substitution model in Part 5) and the standard fix.

### When NOT to reach for a macro

A rule experienced Lisp programmers repeat often: **if a function can do it, use a function.** Macros are for the specific, narrow case where you need to control *whether or when* arguments get evaluated (like `if`, `unless`, `while`) or where you're generating genuinely repetitive boilerplate code. Reaching for a macro when a function would do makes code harder to reason about (macro-expansion is an extra mental step every reader now has to do) for zero benefit. Mastery isn't "use macros everywhere" — it's knowing precisely where the line is.

---

## Part 7: CLOS — The Common Lisp Object System

Any "mastery" claim for Common Lisp has to include CLOS, because it's genuinely unlike most object systems you've encountered, in ways that matter.

### The core difference: generic functions, not methods-on-classes

In Java/Python/C++, a method belongs to a class: `obj.method(args)`. In CLOS, a **generic function** stands on its own, and *methods* are attached to it based on the types of *all* its arguments, not just one privileged "receiver" object.

```lisp
(defclass shape () ())
(defclass circle (shape)
  ((radius :initarg :radius :accessor circle-radius)))
(defclass square (shape)
  ((side :initarg :side :accessor square-side)))

(defgeneric area (shape))

(defmethod area ((s circle))
  (* pi (expt (circle-radius s) 2)))

(defmethod area ((s square))
  (expt (square-side s) 2))
```

```lisp
> (area (make-instance 'circle :radius 5))
78.53981633974483
> (area (make-instance 'square :side 4))
16
```

`area` isn't "owned" by `circle` or `square` — it's a standalone generic function with two methods attached, dispatched on the type of its single argument. This looks similar to single-dispatch OOP so far, but the real power shows up with **multiple dispatch**:

```lisp
(defclass asteroid () ())
(defclass spaceship () ())

(defgeneric collide (a b))

(defmethod collide ((a asteroid) (b asteroid))
  (print "Two asteroids collide"))

(defmethod collide ((a asteroid) (b spaceship))
  (print "Asteroid hits spaceship!"))

(defmethod collide ((a spaceship) (b spaceship))
  (print "Two spaceships collide"))
```

```lisp
> (collide (make-instance 'asteroid) (make-instance 'spaceship))
Asteroid hits spaceship!
```

The correct method is chosen based on the types of *both* arguments simultaneously. In single-dispatch languages (Java, Python, etc.), this "which method runs depends on two objects' types at once" scenario is exactly what forces you into visitor-pattern workarounds. CLOS handles it natively, as the default case, with no pattern needed.

### `:before`, `:after`, `:around` — method combination

CLOS lets multiple methods run for a single call, in a controllable order — not just "the most specific one wins and the rest are inaccessible":

```lisp
(defmethod area :before ((s circle))
  (format t "About to compute area of a circle~%"))

(defmethod area :after ((s circle))
  (format t "Finished computing area~%"))
```

```lisp
> (area (make-instance 'circle :radius 2))
About to compute area of a circle
Finished computing area
12.566370614359172
```

`:before` methods run first, then the primary method, then `:after` methods — all for the *same* generic function call, without you writing any of that sequencing logic yourself. `:around` methods (not shown here, but worth knowing exists) wrap the entire process and can even choose not to call the primary method at all. This is a genuinely different, more flexible model than the rigid "override and optionally call `super()`" pattern in mainstream OOP, and it's worth sitting with the asteroid/spaceship example above until multiple dispatch feels natural — it's the single biggest structural difference from the OOP you likely already know.

---

## Part 8: The Condition System — Not Just Exceptions

This is another place where Common Lisp differs sharply from almost every other language you've used, including ones with "modern" exception handling.

### The problem with plain exceptions

In most languages, when an error is thrown, the stack unwinds *immediately* — by the time your `catch`/`except` block runs, the code that raised the error is already gone. You can decide *how to handle* the error, but you cannot decide to *resume* the original computation from where it broke, because that context no longer exists.

### Conditions and restarts

Common Lisp separates two things that most languages fuse together: **signaling** that something unusual happened, and **deciding what to do about it**. Crucially, a **restart** is a recovery strategy defined at the point of the error — *before* the stack unwinds — that a *handler*, higher up the call stack, can choose to invoke, resuming execution from that exact point.

```lisp
(define-condition my-error (error)
  ((msg :initarg :msg :reader my-error-msg)))

(defun risky-operation (x)
  (restart-case
      (if (< x 0)
          (error 'my-error :msg "negative number!")
          (* x 2))
    (use-value (v) v)
    (retry-with (new-x) (risky-operation new-x))))
```

```lisp
> (handler-case (risky-operation -5)
    (my-error (e) (format t "Caught: ~a~%" (my-error-msg e))))
Caught: negative number!
```

That much is similar to ordinary exception handling. Here's the part that isn't:

```lisp
> (handler-bind
      ((my-error (lambda (e) (invoke-restart 'use-value 42))))
    (risky-operation -5))
42
```

`handler-bind`, unlike `handler-case`, does *not* unwind the stack when the condition fires — the handler runs *inside* the still-live context where `error` was signaled. That means the handler can call `invoke-restart` and jump to the `use-value` restart, which was defined right there at the point of failure inside `risky-operation`, supplying `42` as if `risky-operation` had simply computed and returned it — the computation resumes and finishes normally, instead of the entire call being abandoned.

Concretely, this is the mechanism behind something every Common Lisp programmer eventually experiences: hitting an undefined-function or unbound-variable error inside SBCL's REPL and being offered options like "supply a value," "use a different function," or "retry" — instead of your whole top-level command just failing outright the way it would after an uncaught exception in Python or Java. That interactive debugger *is* the condition system, exposed directly to you as a user. It's not a special debugger feature bolted on top — it's conditions and restarts, working exactly as designed, with a human in the handler's seat instead of another piece of code.

---

## Part 9: Idiom and Style — Writing Lisp Like a Lisper

Knowing the syntax and even the advanced features isn't the same as writing *idiomatic* Lisp. A few hard-won conventions:

**Prefer recursion and higher-order functions over manual loops with mutation**, where reasonable. Compare:

```scheme
;; less idiomatic — manual, imperative-style accumulation
(define (double-all lst)
  (define result '())
  (for-each (lambda (x) (set! result (cons (* x 2) result))) lst)
  (reverse result))

;; idiomatic
(define (double-all lst)
  (map (lambda (x) (* x 2)) lst))
```

`map`, `filter`, and `reduce`/`fold` express *what* you want (transform each element; keep matching elements; combine everything into one value) rather than *how* to loop and accumulate by hand — and this isn't just stylistic taste, it directly avoids classes of bugs (off-by-one, forgetting to reverse an accumulator, mutating something you shouldn't) that hand-rolled loops invite.

```scheme
> (map (lambda (x) (* x x)) '(1 2 3 4))
(1 4 9 16)
> (filter even? '(1 2 3 4 5 6))
(2 4 6)
```

**Small functions, composed, over large functions.** Lisp rewards decomposing a problem into many tiny, single-purpose functions and gluing them together, more than most languages, because function calls are so syntactically cheap (no method-dispatch ceremony) and because it plays to recursion's strengths.

**Use `cond` over nested `if`.** Deeply nested `if`/`else` is a code smell in Lisp specifically because `cond` exists precisely to flatten it:

```lisp
;; nested if — hard to scan
(if (< x 0)
    "negative"
    (if (= x 0)
        "zero"
        "positive"))

;; cond — flat, scannable
(cond ((< x 0) "negative")
      ((= x 0) "zero")
      (t "positive"))
```

**Name predicates ending in `?` (Scheme) or `p`/`-p` (CL).** `null?`, `even?`, `zerop`, `listp` — this convention is load-bearing, not decorative: it lets a reader instantly recognize "this returns a boolean" without checking documentation, everywhere in the language, including code you didn't write.

**Destructive vs. non-destructive operations are named differently, and the naming is a promise you must honor.** `reverse` returns a new list; `nreverse` (CL) mutates and reverses *in place*, destroying the original structure. Getting this backwards — assuming `reverse` is in-place, or using `nreverse` on a list you still need elsewhere — is a classic bug, and it's the reason CL marks destructive operations with a leading `n` (`nreverse`, `nconc`, `nsubst`) as a visible, permanent warning label in the name itself.

---

## Part 10: Practice — Building Real Fluency

Reading examples gets you to recognition, not fluency. Fluency needs your hands on a keyboard, hitting errors, fixing them. Work through these roughly in order — each builds on skills from the last.

**Tier 1 — core mechanics**
1. Write a recursive function `factorial` and a tail-recursive version `factorial-iter`. Compare their behavior on large inputs.
2. Write `my-length` (reimplement `length` using only recursion, `car`, `cdr`, and `null?`).
3. Write `my-map` (reimplement `map` using recursion, without using `map` itself).
4. Write `flatten`, which takes a nested list like `(1 (2 3) (4 (5 6)))` and returns `(1 2 3 4 5 6)`.

**Tier 2 — closures and higher-order functions**
5. Write `make-adder` — `(make-adder 5)` returns a function that adds 5 to whatever it's given.
6. Write `compose` — `(compose f g)` returns a new function equivalent to `(lambda (x) (f (g x)))`.
7. Implement a simple memoization wrapper: `(memoize f)` returns a version of `f` that caches results by argument (using a closure over a hash table).

**Tier 3 — macros**
8. Write a `my-and` macro that short-circuits (stops evaluating as soon as one argument is false) — and verify with `macroexpand-1` that it's *not* evaluating arguments it shouldn't.
9. Write a `swap!` macro that swaps the values of two variables (this one will force you to confront variable capture directly — try it without `gensym` first, find the bug, then fix it).
10. Write a `for` macro: `(for (i 0 5) (print i))` should print `0 1 2 3 4`.

**Tier 4 — CLOS and conditions (CL specifically)**
11. Model a small class hierarchy (e.g., `animal` → `dog`, `cat`) with a generic function `speak` dispatched per-class.
12. Add an `:around` method to `speak` that prints `"About to speak:"` before calling the primary method, then re-derive what you learned about `:before`/`:after` by adding those too and comparing the ordering.
13. Write a function that signals a custom condition, with a `restart-case` offering at least two different restarts, then write a caller that uses `handler-bind` to pick one restart programmatically (not interactively).

**Tier 5 — a real project**
14. Build a tiny expression evaluator: given a list-based expression like `(+ 1 (* 2 3))`, `eval-expr` should compute `7`, handling `+`, `-`, `*`, `/`, and nested expressions. This is a small, self-contained encounter with exactly the kind of tree-walking your Lisp *interpreter itself* does — a genuinely illuminating exercise, since you're now implementing (a tiny slice of) the very evaluation rule from Part 2.
15. Extend it to support `let`-style local variable bindings, using an environment represented as an association list (a list of `(name . value)` cons pairs) — an intentional callback to Part 3, since an environment really is just a list of pairs.

---

## Part 11: Where to Go From Here

One document can't contain everything — here's a curated path, not an exhaustive list.

**Books:**
- *Structure and Interpretation of Computer Programs* (Abelson & Sussman) — the single most influential Lisp/Scheme text; free online. Focuses on the ideas (recursion, abstraction, interpreters) more than any specific dialect's quirks.
- *Practical Common Lisp* (Peter Seibel) — free online; the standard "get productive in real CL" book, project-based (builds an MP3 database, a spam filter, an ID3 parser).
- *On Lisp* and *Let Over Lambda* — advanced, macro-focused; read these once the material in Part 6 feels comfortable, not before.
- *The Little Schemer* — an unusual, dialogue-driven, very gentle path into recursive thinking specifically; complements SICP.

**Where to actually build things next:**
- **Racket** — if you enjoyed the Scheme sections and want a modern, well-tooled environment with a serious ecosystem for *language-oriented programming* (Racket's whole design philosophy is "build the language you need, then use it") — the natural next step after Part 6's macros.
- **Clojure** — if you want to write Lisp for real, deployable software today: JVM-hosted, huge library ecosystem, immutable-by-default data structures, genuinely used in industry. A different flavor (no CLOS, no condition system in the CL sense) but the same underlying paradigm from Parts 1–6.
- **Emacs Lisp** — if you already use or want to use Emacs; a very practical, immediately-applicable way to keep writing Lisp daily, since every bit of Emacs configuration and every package is elisp.

**Communities:**
- r/lisp, r/Common_Lisp, r/scheme, r/Clojure
- Common Lisp has an active IRC/Discord/Matrix presence around `#lisp` on Libera.Chat
- The Common Lisp HyperSpec (CLHS) is the authoritative reference for every CL standard function — worth bookmarking, not reading cover to cover.

---

## Closing Note on What "Mastery" Actually Looks Like

If you take one thing from this whole guide, take this: mastering Lisp isn't memorizing more functions than the next person. It's internalizing that **code is data**, until macros stop feeling like a special trick and start feeling like an obvious consequence of that one fact — at which point you'll find yourself, without really trying, starting to think of programming languages themselves as something you can shape rather than something handed to you. That shift in how you see the relationship between yourself and your tools is the actual destination here, and everything above is scaffolding to get you there.