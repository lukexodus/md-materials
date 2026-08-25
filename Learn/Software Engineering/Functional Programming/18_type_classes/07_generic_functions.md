## Generic Functions


Generic functions abstract over types using parametric polymorphism, enabling single implementations that work uniformly across different types. They define algorithms independent of specific data representations while maintaining type safety.

**Type parameters:**

Functions declare type variables that stand for arbitrary types:

```scala
def identity[A](x: A): A = x

def first[A, B](pair: (A, B)): A = pair._1

def swap[A, B](pair: (A, B)): (B, A) = (pair._2, pair._1)
```

The brackets `[A]` introduce type parameters. Each call site instantiates these with concrete types.

**Parametric polymorphism guarantees:**

Generic functions satisfy **parametricity**—they cannot inspect or manipulate type parameter values beyond what operations their constraints allow. This means:

```haskell
-- Can only rearrange elements, cannot examine them
reverse :: [a] -> [a]

-- Can only return input or produce from thin air (impossibly)
mystery :: a -> a
mystery x = x  -- Only valid implementation
```

**[Inference]** Parametricity provides free theorems—certain properties hold automatically from the type signature alone, without examining implementation.

**Type inference:**

Many languages infer type arguments from context:

```scala
val x = identity(42)        // A inferred as Int
val y = identity("hello")   // A inferred as String
val z = swap((1, "two"))    // A=Int, B=String inferred
```

Explicit specification remains available when inference is ambiguous or for documentation:

```scala
val x = identity[Int](42)
```

**Bounded quantification:**

Type parameters can have upper or lower bounds:

```scala
// A must be subtype of Comparable
def max[A <: Comparable[A]](x: A, y: A): A =
  if (x.compareTo(y) > 0) x else y

// A must be supertype of String  
def example[A >: String](x: A): A = x
```

Bounds constrain which types can instantiate parameters while enabling use of bounded type's operations.

**Higher-kinded types:**

Type parameters can themselves be type constructors:

```scala
trait Functor[F[_]] {
  def map[A, B](fa: F[A])(f: A => B): F[B]
}

// F is a type constructor that takes one type parameter
def twice[F[_]: Functor, A](fa: F[A])(f: A => A): F[A] = {
  val functor = implicitly[Functor[F]]
  functor.map(functor.map(fa)(f))(f)
}
```

The `F[_]` notation indicates `F` takes one type to produce another type.

**Specialization:**

Compilers may generate specialized versions for specific types:

```scala
def sum[@specialized A: Numeric](xs: List[A]): A = {
  val num = implicitly[Numeric[A]]
  xs.foldLeft(num.zero)(num.plus)
}
```

**[Inference]** Specialization likely generates separate implementations for primitive types to avoid boxing overhead.

**Existential types:**

Type parameters can be hidden:

```scala
trait Container {
  type T
  def value: T
}

def useContainer(c: Container): c.T = c.value
```

The concrete type `T` exists but is hidden from external code. The function can return it without knowing what it is.

**Rank-N types:**

Higher-rank polymorphism allows functions to accept polymorphic functions:

```haskell
-- Rank-2: polymorphic function argument
runST :: (forall s. ST s a) -> a

-- The function argument must work for ALL types s
-- Caller cannot choose s; callee must be polymorphic
```

This prevents type variable escape and enables safe encapsulation of mutable state.

**Type application:**

Some languages support explicit type application syntax:

```haskell
-- Visible type applications
show @Int 42
read @Double "3.14"
fmap @Maybe @Int @String show (Just 42)
```

This disambiguates when inference is insufficient or documents intent.

**Generic type constructors:**

Data structures parameterized by types:

```scala
sealed trait List[+A]
case object Nil extends List[Nothing]
case class Cons[A](head: A, tail: List[A]) extends List[A]

sealed trait Tree[A]
case class Leaf[A](value: A) extends Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
```

Operations on these structures are generic over element types.

**Monomorphization:**

**[Inference]** Compiled languages likely generate separate code for each type instantiation, eliminating runtime type dispatch overhead but increasing code size.

**Variance annotations:**

Type parameters can specify variance:

```scala
trait Producer[+A]  // Covariant: Producer[Cat] is subtype of Producer[Animal]
trait Consumer[-A]  // Contravariant: Consumer[Animal] is subtype of Consumer[Cat]
trait Box[A]        // Invariant: no subtype relationship
```

Variance controls subtyping relationships in generic types, affecting where instances can be used.

