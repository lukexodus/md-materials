## Multiple Dispatch


Multiple dispatch selects function implementations based on the runtime types of multiple arguments rather than a single receiver object. The dispatch mechanism examines all argument types simultaneously to determine the most specific applicable method.

**Dispatch semantics:**

Traditional single dispatch:

```java
// Dispatches only on 'this'
object.method(arg1, arg2)
```

Multiple dispatch:

```julia
# Dispatches on all argument types
collide(object1, object2)
```

The system finds the method whose parameter types best match all argument types.

**Method specificity:**

When multiple methods could apply, specificity rules determine precedence:

```julia
collide(x::GameObject, y::GameObject) = generic_collision(x, y)
collide(x::Asteroid, y::Spaceship) = asteroid_hits_ship(x, y)
collide(x::Spaceship, y::Asteroid) = ship_hits_asteroid(x, y)
collide(x::Asteroid, y::Asteroid) = asteroids_bounce(x, y)

# Call with specific types
collide(asteroid1, ship1)  # Dispatches to asteroid_hits_ship
```

**[Inference]** The most specific method is chosen by comparing type relationships. A method is more specific when its parameter types are subtypes of another method's parameters.

**Ambiguity resolution:**

Ambiguous situations arise when no single most-specific method exists:

```julia
foo(x::Int, y::Any) = 1
foo(x::Any, y::String) = 2

foo(42, "hello")  # Ambiguous: both methods match
```

Resolution strategies:

- **Error at call site**: Language rejects ambiguous calls
- **Declaration order**: Earlier methods take precedence
- **Manual disambiguation**: Define a method for the conflicting case

```julia
# Resolve ambiguity explicitly
foo(x::Int, y::String) = 3
```

**Dispatch tables:**

Runtime dispatch uses lookup tables keyed by type combinations:

```
(Type₁, Type₂) → Method
(Asteroid, Spaceship) → asteroid_hits_ship
(Spaceship, Asteroid) → ship_hits_asteroid
(Asteroid, Asteroid) → asteroids_bounce
```

**[Inference]** Dispatch table construction likely occurs at:

- Compile time for static types
- Runtime for dynamic types with caching

**Symmetric operations:**

Multiple dispatch naturally expresses commutative or symmetric operations:

```julia
intersect(s::Sphere, b::Box) = sphere_box_test(s, b)
intersect(b::Box, s::Sphere) = sphere_box_test(s, b)  # Reuse logic

# Or use type ordering
intersect(s::Sphere, b::Box) = sphere_box_test(s, b)
intersect(b::Box, s::Sphere) = intersect(s, b)  # Delegate to canonical order
```

**Extension mechanisms:**

New types integrate seamlessly with existing multimethod frameworks:

```julia
# Existing multimethods
collide(x::GameObject, y::GameObject) = ...
collide(x::Asteroid, y::Spaceship) = ...

# Later, add new type
struct Missile <: GameObject
  # ...
end

# Define behavior with existing types
collide(x::Missile, y::Asteroid) = missile_explodes(x, y)
collide(x::Asteroid, y::Missile) = asteroid_destroyed(x, y)
```

The expression problem is partially addressed—new types and new operations can be added without modifying existing code.

**Performance considerations:**

Dispatch overhead involves:

- Type tag extraction from arguments
- Table lookup or tree traversal
- Potential method cache queries

Optimizations include:

- **Inline caching**: Remember recently dispatched methods
- **Polymorphic inline caches**: Cache several recent dispatches
- **Method specialization**: Generate optimized code for common type combinations

**Comparison with visitor pattern:**

Multiple dispatch eliminates visitor boilerplate:

```julia
# No visitor pattern needed
process(x::TypeA, y::TypeB) = ...
process(x::TypeA, y::TypeC) = ...
process(x::TypeB, y::TypeC) = ...
```

The language runtime handles what visitor pattern accomplishes through double dispatch.

**Variance considerations:**

Contravariance in parameter types affects specificity:

```julia
# More general in first parameter
foo(x::Any, y::String) = 1

# More specific in first parameter  
foo(x::Int, y::String) = 2

foo(42, "hello")  # Dispatches to second method
```

**[Inference]** The specificity ordering likely follows subtype relationships—more derived types indicate more specific methods.

