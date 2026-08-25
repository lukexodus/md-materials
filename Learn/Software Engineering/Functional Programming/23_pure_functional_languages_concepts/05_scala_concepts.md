## Scala Concepts


Scala unifies object-oriented and functional programming on the JVM. It provides sophisticated type system features while maintaining interoperability with Java.

**Case Classes and Pattern Matching**

Case classes provide immutable data holders with automatic implementations of `equals`, `hashCode`, `toString`, and `copy`. Pattern matching destructures data and enables exhaustiveness checking.

```scala
sealed trait Tree[+A]
case class Leaf[A](value: A) extends Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]

def depth[A](tree: Tree[A]): Int = tree match {
  case Leaf(_) => 1
  case Branch(l, r) => 1 + (depth(l) max depth(r))
}
```

**Implicits**

Implicit parameters are resolved automatically by the compiler from the implicit scope. They enable type classes, dependency injection, and extension methods.

```scala
trait Show[A] {
  def show(a: A): String
}

implicit val intShow: Show[Int] = (i: Int) => i.toString

def print[A](a: A)(implicit s: Show[A]): Unit = println(s.show(a))
```

**For-Comprehensions**

For-comprehensions desugar into `flatMap`, `map`, `withFilter`, and `foreach` calls, working with any type implementing these methods (monadic composition).

```scala
val result = for {
  x <- List(1, 2, 3)
  y <- List(10, 20)
  if x * y > 10
} yield x * y
// Equivalent to: List(1,2,3).flatMap(x => List(10,20).withFilter(y => x*y > 10).map(y => x*y))
```

**Higher-Kinded Types**

Scala supports type constructors as parameters (types that take types). This enables abstraction over type constructors like `List`, `Option`, etc.

```scala
trait Functor[F[_]] {
  def map[A, B](fa: F[A])(f: A => B): F[B]
}

implicit val listFunctor: Functor[List] = new Functor[List] {
  def map[A, B](fa: List[A])(f: A => B): List[B] = fa.map(f)
}
```

**Variance Annotations**

Type parameters can be covariant (`+A`), contravariant (`-A`), or invariant. Variance controls subtyping relationships between parameterized types.

```scala
class Box[+A]  // Covariant: Box[Cat] <: Box[Animal]
trait Function1[-T, +R]  // Contravariant in input, covariant in output
```

**Path-Dependent Types**

Types can depend on values, enabling precise type relationships within objects.

```scala
class Outer {
  class Inner
  def method: Inner = new Inner
}

val o1 = new Outer
val o2 = new Outer
val i1: o1.Inner = o1.method  // Type is path-dependent on o1
// val i2: o1.Inner = o2.method  // Type error: o2.Inner != o1.Inner
```

**Self-Type Annotations**

Self-types specify dependencies between traits without inheritance, enabling circular dependencies and cake pattern dependency injection.

```scala
trait UserRepository {
  def findUser(id: Int): User
}

trait UserService { self: UserRepository =>
  def getUser(id: Int): User = findUser(id)
}
```

**Abstract Type Members**

Types can be declared abstract within traits/classes and refined in subclasses, providing an alternative to type parameters.

```scala
trait Container {
  type A
  def value: A
}

class IntContainer extends Container {
  type A = Int
  def value = 42
}
```

**Call-by-Name Parameters**

Parameters can be evaluated lazily at each use site rather than once at call time.

```scala
def unless(condition: Boolean)(block: => Unit): Unit = {
  if (!condition) block
}

unless(false) { println("Evaluated lazily") }
```

**Extension Methods (Using Implicit Classes)**

[Inference] In Scala 2, implicit classes enable adding methods to existing types. Scala 3 provides explicit extension methods syntax.

```scala
// Scala 2
implicit class RichInt(val i: Int) extends AnyVal {
  def squared: Int = i * i
}

// Scala 3
extension (i: Int) {
  def squared: Int = i * i
}
```

