## Coroutines and Generators


Coroutines enable cooperative multitasking and generator functions that can suspend and resume execution.

**State Machine Generation**
The compiler transforms coroutine functions into state machines where each suspension point becomes a state. Local variables are converted into state machine fields, and the function becomes a switch statement or computed goto structure.

**Stack Management**
Stackless coroutines require the compiler to manage activation records differently from regular functions. Local variables must be stored in heap-allocated coroutine frames that persist across suspensions.

**Yield Point Transformation**
Generator functions with yield statements require special handling where the compiler identifies all possible suspension points and generates code to save and restore execution context at these locations.

**Async/Await Implementation**
Asynchronous programming constructs require the compiler to handle promise/future chaining and callback transformation. The compiler may implement async functions as state machines that interface with runtime task schedulers.

