## Pattern Matching Use Cases


Pattern matching serves as a powerful control flow mechanism that goes beyond simple switch statements, enabling elegant solutions across numerous programming scenarios. It transforms conditional logic into declarative specifications of what to match rather than how to check conditions.

**Key Points:**

- Replaces complex conditional logic with declarative patterns
- Enforces exhaustiveness checking for safer code
- Simplifies data transformation and extraction
- Handles recursive data structures naturally
- Integrates seamlessly with algebraic data types
- Reduces cognitive load by making intent explicit

### Algebraic Data Type Manipulation

Pattern matching is the primary way to work with sum types and product types, providing type-safe access to variants and their associated data.

**Example:**

```scala
sealed trait Result[+A]
case class Success[A](value: A) extends Result[A]
case class Failure(error: String) extends Result[Nothing]
case object Pending extends Result[Nothing]

def processResult[A](result: Result[A]): String = result match {
  case Success(value) => s"Operation succeeded with: $value"
  case Failure(error) => s"Operation failed: $error"
  case Pending => "Operation still in progress"
}

sealed trait Tree[+A]
case class Leaf[A](value: A) extends Tree[A]
case class Branch[A](left: Tree[A], right: Tree[A]) extends Tree[A]
case object Empty extends Tree[Nothing]

def treeSize[A](tree: Tree[A]): Int = tree match {
  case Empty => 0
  case Leaf(_) => 1
  case Branch(left, right) => treeSize(left) + treeSize(right)
}

def treeMap[A, B](tree: Tree[A])(f: A => B): Tree[B] = tree match {
  case Empty => Empty
  case Leaf(value) => Leaf(f(value))
  case Branch(left, right) => Branch(treeMap(left)(f), treeMap(right)(f))
}
```

### List and Collection Processing

Pattern matching excels at recursive list operations, expressing algorithms in terms of base cases and recursive cases.

**Example:**

```scala
def sum(list: List[Int]): Int = list match {
  case Nil => 0
  case head :: tail => head + sum(tail)
}

def reverse[A](list: List[A]): List[A] = {
  def reverseHelper(remaining: List[A], accumulated: List[A]): List[A] = 
    remaining match {
      case Nil => accumulated
      case head :: tail => reverseHelper(tail, head :: accumulated)
    }
  reverseHelper(list, Nil)
}

def takeWhile[A](list: List[A])(predicate: A => Boolean): List[A] = 
  list match {
    case Nil => Nil
    case head :: tail if predicate(head) => head :: takeWhile(tail)(predicate)
    case _ => Nil
  }

def partition[A](list: List[A])(predicate: A => Boolean): (List[A], List[A]) = 
  list match {
    case Nil => (Nil, Nil)
    case head :: tail =>
      val (satisfied, unsatisfied) = partition(tail)(predicate)
      if (predicate(head)) (head :: satisfied, unsatisfied)
      else (satisfied, head :: unsatisfied)
  }
```

**Output:**

```
sum(List(1, 2, 3, 4, 5))                    // 15
reverse(List(1, 2, 3))                      // List(3, 2, 1)
takeWhile(List(2, 4, 6, 7, 8))(_ % 2 == 0)  // List(2, 4, 6)
partition(List(1, 2, 3, 4, 5))(_ % 2 == 0)  // (List(2, 4), List(1, 3, 5))
```

### Option and Either Handling

Pattern matching provides clean extraction of values from container types without explicit null checks or exception handling.

**Example:**

```scala
def divide(numerator: Double, denominator: Double): Option[Double] =
  if (denominator == 0) None else Some(numerator / denominator)

def formatResult(result: Option[Double]): String = result match {
  case Some(value) => f"Result: $value%.2f"
  case None => "Cannot divide by zero"
}

sealed trait Either[+L, +R]
case class Left[L](value: L) extends Either[L, Nothing]
case class Right[R](value: R) extends Either[Nothing, R]

def parseNumber(input: String): Either[String, Int] =
  try {
    Right(input.toInt)
  } catch {
    case _: NumberFormatException => Left(s"'$input' is not a valid number")
  }

def processInput(input: String): String = parseNumber(input) match {
  case Right(n) if n > 0 => s"Positive number: $n"
  case Right(n) if n < 0 => s"Negative number: $n"
  case Right(0) => "Zero"
  case Left(error) => s"Error: $error"
}
```

### State Machine Implementation

Pattern matching naturally expresses state transitions, making state machines more readable and maintainable.

**Example:**

```scala
sealed trait ConnectionState
case object Disconnected extends ConnectionState
case object Connecting extends ConnectionState
case class Connected(sessionId: String) extends ConnectionState
case class Error(message: String) extends ConnectionState

sealed trait Event
case object Connect extends Event
case object Disconnect extends Event
case class DataReceived(data: String) extends Event
case class ErrorOccurred(message: String) extends Event

def handleEvent(state: ConnectionState, event: Event): ConnectionState = 
  (state, event) match {
    case (Disconnected, Connect) => 
      Connecting
    case (Connecting, DataReceived(sessionId)) => 
      Connected(sessionId)
    case (Connected(_), Disconnect) => 
      Disconnected
    case (_, ErrorOccurred(msg)) => 
      Error(msg)
    case (Error(_), Connect) => 
      Connecting
    case _ => 
      state // No transition
  }
```

### Parser Implementation

Pattern matching simplifies parsing by expressing grammar rules directly as pattern cases.

**Example:**

```scala
sealed trait Token
case class Number(value: Int) extends Token
case class Operator(op: Char) extends Token
case object LeftParen extends Token
case object RightParen extends Token

sealed trait Expr
case class Literal(value: Int) extends Expr
case class BinaryOp(op: Char, left: Expr, right: Expr) extends Expr

def parseExpression(tokens: List[Token]): Option[(Expr, List[Token])] = 
  tokens match {
    case Number(n) :: rest => 
      Some((Literal(n), rest))
    
    case LeftParen :: rest =>
      for {
        (left, after1) <- parseExpression(rest)
        Operator(op) :: after2 = after1
        (right, after3) <- parseExpression(after2)
        RightParen :: after4 = after3
      } yield (BinaryOp(op, left, right), after4)
    
    case _ => None
  }

def evaluate(expr: Expr): Int = expr match {
  case Literal(n) => n
  case BinaryOp('+', left, right) => evaluate(left) + evaluate(right)
  case BinaryOp('-', left, right) => evaluate(left) - evaluate(right)
  case BinaryOp('*', left, right) => evaluate(left) * evaluate(right)
  case BinaryOp('/', left, right) => evaluate(left) / evaluate(right)
}
```

### JSON and Data Structure Traversal

Pattern matching simplifies working with nested data structures by allowing deep pattern matching.

**Example:**

```scala
sealed trait Json
case object JNull extends Json
case class JBool(value: Boolean) extends Json
case class JNumber(value: Double) extends Json
case class JString(value: String) extends Json
case class JArray(values: List[Json]) extends Json
case class JObject(fields: Map[String, Json]) extends Json

def findString(json: Json, path: List[String]): Option[String] = 
  (json, path) match {
    case (JString(s), Nil) => Some(s)
    case (JObject(fields), key :: rest) => 
      fields.get(key).flatMap(findString(_, rest))
    case (JArray(values), indexStr :: rest) =>
      indexStr.toIntOption
        .flatMap(idx => values.lift(idx))
        .flatMap(findString(_, rest))
    case _ => None
  }

def prettyPrint(json: Json, indent: Int = 0): String = {
  val spaces = "  " * indent
  json match {
    case JNull => "null"
    case JBool(b) => b.toString
    case JNumber(n) => n.toString
    case JString(s) => s""""$s""""
    case JArray(Nil) => "[]"
    case JArray(values) =>
      val items = values.map(v => s"$spaces  ${prettyPrint(v, indent + 1)}").mkString(",\n")
      s"[\n$items\n$spaces]"
    case JObject(fields) if fields.isEmpty => "{}"
    case JObject(fields) =>
      val items = fields.map { case (k, v) =>
        s"""$spaces  "$k": ${prettyPrint(v, indent + 1)}"""
      }.mkString(",\n")
      s"{\n$items\n$spaces}"
  }
}
```

**Conclusion:** Pattern matching transforms complex conditional logic into clear, declarative code. It provides exhaustiveness checking, eliminates boilerplate, and makes code intent explicit. The combination of structural matching, type extraction, and guard clauses creates a powerful tool for expressing complex logic simply and safely.

---

