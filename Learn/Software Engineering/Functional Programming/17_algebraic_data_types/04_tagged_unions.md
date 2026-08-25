## Tagged unions


Tagged unions (also called discriminated unions or variant types) combine the data payload with an explicit tag that identifies which variant is active. They provide type-safe pattern matching where the tag determines how to interpret the associated data.

**Manual Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal

class IntValue(NamedTuple):
    tag: Literal['int']
    value: int

class StrValue(NamedTuple):
    tag: Literal['str']
    value: str

class BoolValue(NamedTuple):
    tag: Literal['bool']
    value: bool

TaggedValue = Union[IntValue, StrValue, BoolValue]

def process_tagged(val: TaggedValue) -> str:
    match val.tag:
        case 'int':
            return f"Integer: {val.value}"
        case 'str':
            return f"String: {val.value}"
        case 'bool':
            return f"Boolean: {val.value}"

# Usage
int_val = IntValue('int', 42)
str_val = StrValue('str', "hello")
bool_val = BoolValue('bool', True)
```

**Event System with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal
from datetime import datetime

class MouseClick(NamedTuple):
    tag: Literal['click']
    x: int
    y: int
    button: str
    timestamp: datetime

class KeyPress(NamedTuple):
    tag: Literal['keypress']
    key: str
    modifiers: list[str]
    timestamp: datetime

class Scroll(NamedTuple):
    tag: Literal['scroll']
    delta_x: int
    delta_y: int
    timestamp: datetime

Event = Union[MouseClick, KeyPress, Scroll]

def handle_event(event: Event) -> str:
    match event.tag:
        case 'click':
            return f"Clicked {event.button} at ({event.x}, {event.y})"
        case 'keypress':
            mods = '+'.join(event.modifiers) if event.modifiers else ''
            return f"Pressed {mods}+{event.key}" if mods else f"Pressed {event.key}"
        case 'scroll':
            return f"Scrolled by ({event.delta_x}, {event.delta_y})"

# Creating events
click = MouseClick('click', 100, 200, 'left', datetime.now())
keypress = KeyPress('keypress', 'A', ['ctrl', 'shift'], datetime.now())
scroll = Scroll('scroll', 0, -10, datetime.now())
```

**Message Passing with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal, Any

class Request(NamedTuple):
    tag: Literal['request']
    id: str
    endpoint: str
    payload: dict[str, Any]

class Response(NamedTuple):
    tag: Literal['response']
    id: str
    status: int
    data: Any

class Error(NamedTuple):
    tag: Literal['error']
    id: str
    message: str
    code: int

Message = Union[Request, Response, Error]

def route_message(msg: Message) -> str:
    match msg.tag:
        case 'request':
            return f"Routing request {msg.id} to {msg.endpoint}"
        case 'response':
            return f"Response {msg.id}: status {msg.status}"
        case 'error':
            return f"Error {msg.id}: {msg.message} (code: {msg.code})"

# Message queue processing
def process_messages(messages: list[Message]) -> list[str]:
    return [route_message(msg) for msg in messages]
```

**State Machine with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal

class Idle(NamedTuple):
    tag: Literal['idle']

class Loading(NamedTuple):
    tag: Literal['loading']
    progress: float

class Success(NamedTuple):
    tag: Literal['success']
    data: str

class Failure(NamedTuple):
    tag: Literal['failure']
    error: str

State = Union[Idle, Loading, Success, Failure]

def render_state(state: State) -> str:
    match state.tag:
        case 'idle':
            return "Ready to start"
        case 'loading':
            return f"Loading... {state.progress * 100:.1f}%"
        case 'success':
            return f"Completed: {state.data}"
        case 'failure':
            return f"Failed: {state.error}"

# State transitions
def start_loading(state: State) -> State:
    match state.tag:
        case 'idle':
            return Loading('loading', 0.0)
        case _:
            return state

def update_progress(state: State, progress: float) -> State:
    match state.tag:
        case 'loading':
            if progress >= 1.0:
                return Success('success', "Operation complete")
            return Loading('loading', progress)
        case _:
            return state
```

**Tree Structures with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal, TypeVar, Generic

T = TypeVar('T')

class Leaf(NamedTuple, Generic[T]):
    tag: Literal['leaf']
    value: T

class Node(NamedTuple, Generic[T]):
    tag: Literal['node']
    value: T
    left: 'Tree[T]'
    right: 'Tree[T]'

Tree = Union[Leaf[T], Node[T]]

def tree_sum(tree: Tree[int]) -> int:
    match tree.tag:
        case 'leaf':
            return tree.value
        case 'node':
            return tree.value + tree_sum(tree.left) + tree_sum(tree.right)

def tree_map(f: callable, tree: Tree[T]) -> Tree[T]:
    match tree.tag:
        case 'leaf':
            return Leaf('leaf', f(tree.value))
        case 'node':
            return Node(
                'node',
                f(tree.value),
                tree_map(f, tree.left),
                tree_map(f, tree.right)
            )

# Building a tree
tree = Node('node', 10, Leaf('leaf', 5), Node('node', 15, Leaf('leaf', 12), Leaf('leaf', 18) ) )

total = tree_sum(tree) # 60
````

**JSON-like Data Structure:**

```python
from typing import NamedTuple, Union, Literal

class JNull(NamedTuple):
    tag: Literal['null']

class JBool(NamedTuple):
    tag: Literal['bool']
    value: bool

class JNumber(NamedTuple):
    tag: Literal['number']
    value: float

class JString(NamedTuple):
    tag: Literal['string']
    value: str

class JArray(NamedTuple):
    tag: Literal['array']
    items: list['JSON']

class JObject(NamedTuple):
    tag: Literal['object']
    fields: dict[str, 'JSON']

JSON = Union[JNull, JBool, JNumber, JString, JArray, JObject]

def json_to_python(json: JSON) -> Any:
    match json.tag:
        case 'null':
            return None
        case 'bool':
            return json.value
        case 'number':
            return json.value
        case 'string':
            return json.value
        case 'array':
            return [json_to_python(item) for item in json.items]
        case 'object':
            return {k: json_to_python(v) for k, v in json.fields.items()}

# Example JSON structure
data = JObject('object', {
    'name': JString('string', 'Alice'),
    'age': JNumber('number', 30),
    'active': JBool('bool', True),
    'tags': JArray('array', [
        JString('string', 'developer'),
        JString('string', 'python')
    ])
})

converted = json_to_python(data)
# Output: {'name': 'Alice', 'age': 30, 'active': True, 'tags': ['developer', 'python']}
````

**Command Pattern with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal

class CreateUser(NamedTuple):
    tag: Literal['create_user']
    username: str
    email: str

class DeleteUser(NamedTuple):
    tag: Literal['delete_user']
    user_id: int

class UpdateUser(NamedTuple):
    tag: Literal['update_user']
    user_id: int
    fields: dict[str, Any]

class SendEmail(NamedTuple):
    tag: Literal['send_email']
    to: str
    subject: str
    body: str

Command = Union[CreateUser, DeleteUser, UpdateUser, SendEmail]

def execute_command(cmd: Command) -> str:
    match cmd.tag:
        case 'create_user':
            return f"Creating user {cmd.username} with email {cmd.email}"
        case 'delete_user':
            return f"Deleting user {cmd.user_id}"
        case 'update_user':
            return f"Updating user {cmd.user_id} with fields {cmd.fields}"
        case 'send_email':
            return f"Sending email to {cmd.to}: {cmd.subject}"

# Command queue
commands = [
    CreateUser('create_user', 'alice', 'alice@example.com'),
    UpdateUser('update_user', 1, {'age': 31}),
    SendEmail('send_email', 'alice@example.com', 'Welcome', 'Hello!')
]

results = [execute_command(cmd) for cmd in commands]
```

**Validation Results with Tagged Unions:**

```python
from typing import NamedTuple, Union, Literal, TypeVar

T = TypeVar('T')

class Valid(NamedTuple, Generic[T]):
    tag: Literal['valid']
    value: T

class Invalid(NamedTuple):
    tag: Literal['invalid']
    errors: list[str]

Validation = Union[Valid[T], Invalid]

def validate_email(email: str) -> Validation[str]:
    errors = []
    if '@' not in email:
        errors.append("Missing @ symbol")
    if len(email) < 5:
        errors.append("Email too short")
    if not email.split('@')[0]:
        errors.append("Missing username")
    
    if errors:
        return Invalid('invalid', errors)
    return Valid('valid', email)

def validate_age(age: int) -> Validation[int]:
    if age < 0:
        return Invalid('invalid', ["Age cannot be negative"])
    if age > 150:
        return Invalid('invalid', ["Age too high"])
    return Valid('valid', age)

# Combining validations
def combine_validations(*validations: Validation) -> Validation[tuple]:
    errors = []
    values = []
    
    for v in validations:
        match v.tag:
            case 'valid':
                values.append(v.value)
            case 'invalid':
                errors.extend(v.errors)
    
    if errors:
        return Invalid('invalid', errors)
    return Valid('valid', tuple(values))

email_result = validate_email("alice@example.com")
age_result = validate_age(30)
combined = combine_validations(email_result, age_result)
```

