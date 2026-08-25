## TypeScript with React


### Understanding TypeScript in React

TypeScript provides static type checking for JavaScript, offering significant advantages when building React applications. By detecting errors during development rather than runtime, TypeScript helps create more robust and maintainable React code. It also enhances developer experience with improved autocompletion, documentation, and refactoring capabilities.

### Setting Up a TypeScript React Project

You can create a new TypeScript React project using Create React App:

```bash
npx create-react-app my-app --template typescript
```

For existing projects, you can add TypeScript by installing necessary dependencies:

```bash
npm install --save typescript @types/node @types/react @types/react-dom @types/jest
```

Then create a `tsconfig.json` file in your project root with appropriate configuration:

```json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noFallthroughCasesInSwitch": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
```

### React Component Types

TypeScript offers multiple ways to define React components with proper typing.

#### Function Components

The most common approach is using function components with explicit typing:

```tsx
import React from 'react';

// Using React.FC (Function Component) type
const Greeting: React.FC<{ name: string }> = ({ name }) => {
  return <h1>Hello, {name}!</h1>;
};

// Or with explicit parameter typing
const GreetingAlt = ({ name }: { name: string }) => {
  return <h1>Hello, {name}!</h1>;
};
```

While `React.FC` was once popular, the current best practice is to avoid it because:

- It implicitly includes children in props even when not needed
- It doesn't work well with generic components
- It complicates component default props

#### Class Components

Although less common in modern React, class components can be typed with TypeScript:

```tsx
import React, { Component } from 'react';

interface GreetingProps {
  name: string;
}

interface GreetingState {
  count: number;
}

class Greeting extends Component<GreetingProps, GreetingState> {
  state = {
    count: 0
  };

  render() {
    return (
      <div>
        <h1>Hello, {this.props.name}!</h1>
        <p>You clicked {this.state.count} times</p>
        <button onClick={() => this.setState({ count: this.state.count + 1 })}>
          Click me
        </button>
      </div>
    );
  }
}
```

#### Higher Order Components

When creating Higher Order Components (HOCs), utilize generics for type safety:

```tsx
import React from 'react';

// HOC that adds a "theme" prop
function withTheme<T extends object>(Component: React.ComponentType<T & { theme: string }>) {
  return (props: T) => {
    const theme = "dark"; // Would normally come from context
    return <Component {...props} theme={theme} />;
  };
}

// Usage
const ThemedButton = withTheme(({ theme, label }: { theme: string; label: string }) => {
  return <button className={`btn-${theme}`}>{label}</button>;
});

// Now we can use ThemedButton without passing "theme"
<ThemedButton label="Click Me" />; // Type safe!
```

### Props and State Typing

#### Typing Props

Defining prop types with interfaces provides clear contracts for components:

```tsx
// Using interface for props definition
interface UserCardProps {
  name: string;
  email: string;
  age?: number; // Optional prop
  isAdmin: boolean;
  status: 'active' | 'suspended' | 'pending'; // Union type
  roles: string[];
  onProfileClick: (userId: string) => void; // Function prop
}

const UserCard = (props: UserCardProps) => {
  const { name, email, age, isAdmin, status, roles, onProfileClick } = props;
  
  return (
    <div className="user-card">
      <h3>{name} {isAdmin && '(Admin)'}</h3>
      <p>Email: {email}</p>
      {age && <p>Age: {age}</p>}
      <p>Status: {status}</p>
      <p>Roles: {roles.join(', ')}</p>
      <button onClick={() => onProfileClick(name)}>View Profile</button>
    </div>
  );
};
```

#### Default Props

Best practices for default props in TypeScript React:

```tsx
interface ButtonProps {
  label: string;
  primary?: boolean;
  disabled?: boolean;
  size?: 'small' | 'medium' | 'large';
}

const Button = ({
  label, 
  primary = false, 
  disabled = false, 
  size = 'medium'
}: ButtonProps) => {
  // Implementation using defaults
  return (
    <button 
      className={`btn-${size} ${primary ? 'btn-primary' : 'btn-secondary'}`}
      disabled={disabled}
    >
      {label}
    </button>
  );
};
```

#### Children Props

Type the children prop using React's built-in types:

```tsx
import React, { ReactNode } from 'react';

interface CardProps {
  title: string;
  children: ReactNode; // Can accept any valid JSX
}

const Card = ({ title, children }: CardProps) => {
  return (
    <div className="card">
      <h2>{title}</h2>
      <div className="card-content">
        {children}
      </div>
    </div>
  );
};

// Usage
<Card title="User Information">
  <p>This is the card content.</p>
  <button>Action</button>
</Card>
```

#### State Typing

In class components, state is typed in the component definition. For hooks, types are inferred or explicitly declared:

```tsx
import React, { useState } from 'react';

// State with type inference
const Counter = () => {
  const [count, setCount] = useState(0); // TypeScript infers number type
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
};

// Explicit state typing
interface User {
  id: number;
  name: string;
  isActive: boolean;
}

const UserProfile = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);

  const fetchUser = (id: number) => {
    setLoading(true);
    // Mock API call
    setTimeout(() => {
      setUser({
        id,
        name: 'John Doe',
        isActive: true
      });
      setLoading(false);
    }, 1000);
  };

  return (
    <div>
      {loading && <p>Loading...</p>}
      {user && (
        <div>
          <h2>{user.name}</h2>
          <p>ID: {user.id}</p>
          <p>Status: {user.isActive ? 'Active' : 'Inactive'}</p>
        </div>
      )}
      {!loading && !user && (
        <button onClick={() => fetchUser(1)}>Load User</button>
      )}
    </div>
  );
};
```

### Hooks with TypeScript

TypeScript enhances React hooks with strong typing, making them more predictable and safer to use.

#### useState

```tsx
// Basic usage with type inference
const [name, setName] = useState('');

// Explicit type definition
const [user, setUser] = useState<User | null>(null);

// For complex state with union types
type Status = 'idle' | 'loading' | 'success' | 'error';
const [status, setStatus] = useState<Status>('idle');

// For array state
const [items, setItems] = useState<string[]>([]);
```

#### useEffect

For `useEffect`, TypeScript ensures correct dependency types:

```tsx
const UserData = ({ userId }: { userId: string }) => {
  const [user, setUser] = useState<User | null>(null);
  
  useEffect(() => {
    // TypeScript ensures userId is a string
    const fetchUser = async () => {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      setUser(data);
    };
    
    fetchUser();
  }, [userId]); // Dependency correctly typed
  
  return user ? <div>{user.name}</div> : <div>Loading...</div>;
};
```

#### useReducer

TypeScript makes complex state management with reducers safer:

```tsx
type State = {
  count: number;
  isLoading: boolean;
  error: string | null;
};

// Discriminated union for action types
type Action = 
  | { type: 'INCREMENT'; payload: number }
  | { type: 'DECREMENT'; payload: number }
  | { type: 'RESET' }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'SET_ERROR'; payload: string };

const initialState: State = {
  count: 0,
  isLoading: false,
  error: null
};

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'INCREMENT':
      return { ...state, count: state.count + action.payload };
    case 'DECREMENT':
      return { ...state, count: state.count - action.payload };
    case 'RESET':
      return { ...state, count: 0 };
    case 'SET_LOADING':
      return { ...state, isLoading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload };
    default:
      // TypeScript ensures exhaustive check of all action types
      const _exhaustiveCheck: never = action;
      return state;
  }
}

function CounterWithReducer() {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <div>
      <p>Count: {state.count}</p>
      {state.isLoading && <p>Loading...</p>}
      {state.error && <p>Error: {state.error}</p>}
      <button onClick={() => dispatch({ type: 'INCREMENT', payload: 1 })}>
        Increment
      </button>
      <button onClick={() => dispatch({ type: 'DECREMENT', payload: 1 })}>
        Decrement
      </button>
      <button onClick={() => dispatch({ type: 'RESET' })}>
        Reset
      </button>
    </div>
  );
}
```

#### useRef

Type annotations for refs ensure correct DOM element access:

```tsx
import React, { useRef, useEffect } from 'react';

const InputFocus = () => {
  // For DOM elements
  const inputRef = useRef<HTMLInputElement>(null);
  
  // For mutable values that don't trigger re-renders
  const prevCountRef = useRef<number>(0);
  
  useEffect(() => {
    // Safe because we check if inputRef.current exists
    if (inputRef.current) {
      inputRef.current.focus();
    }
  }, []);
  
  return <input ref={inputRef} type="text" />;
};
```

#### useCallback and useMemo

Proper typing helps ensure correct parameter and return types:

```tsx
import React, { useState, useCallback, useMemo } from 'react';

interface Item {
  id: number;
  name: string;
}

const ItemList = () => {
  const [items, setItems] = useState<Item[]>([]);
  const [filter, setFilter] = useState('');
  
  // Type-safe callback function
  const handleAddItem = useCallback((name: string) => {
    const newItem: Item = {
      id: Date.now(),
      name
    };
    setItems(prev => [...prev, newItem]);
  }, []);
  
  // Type-safe memoized value
  const filteredItems = useMemo(() => {
    return items.filter(item => 
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [items, filter]);
  
  return (
    <div>
      <input 
        value={filter} 
        onChange={(e) => setFilter(e.target.value)} 
        placeholder="Filter items" 
      />
      <button onClick={() => handleAddItem('New Item')}>Add Item</button>
      <ul>
        {filteredItems.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    </div>
  );
};
```

#### Custom Hooks

TypeScript shines with custom hooks by enabling reusable, type-safe abstractions:

```tsx
import { useState, useEffect } from 'react';

// Custom hook with proper TypeScript typing
function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      // Get from local storage by key
      const item = window.localStorage.getItem(key);
      // Parse stored json or if none return initialValue
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      // If error also return initialValue
      console.log(error);
      return initialValue;
    }
  });

  // Return a wrapped version of useState's setter function
  const setValue = (value: T) => {
    try {
      // Allow value to be a function so we have same API as useState
      const valueToStore =
        value instanceof Function ? value(storedValue) : value;
      // Save state
      setStoredValue(valueToStore);
      // Save to local storage
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.log(error);
    }
  };

  return [storedValue, setValue];
}

// Usage
const UserSettings = () => {
  // Strong typing ensures theme can only be 'light' or 'dark'
  const [theme, setTheme] = useLocalStorage<'light' | 'dark'>('theme', 'light');
  
  return (
    <div>
      <p>Current theme: {theme}</p>
      <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
        Toggle Theme
      </button>
    </div>
  );
};
```

### Context API Typing

Context API in TypeScript requires proper typing for both the context value and provider.

#### Creating Typed Context

```tsx
import React, { createContext, useContext, useState, ReactNode } from 'react';

// Define the shape of context data
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

// Create context with a default value
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// Provider component with typed props
interface ThemeProviderProps {
  children: ReactNode;
  initialTheme?: 'light' | 'dark';
}

export const ThemeProvider = ({ 
  children, 
  initialTheme = 'light' 
}: ThemeProviderProps) => {
  const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme);

  const toggleTheme = () => {
    setTheme(prevTheme => (prevTheme === 'light' ? 'dark' : 'light'));
  };

  // The value passed to the provider is type-checked
  const value: ThemeContextType = {
    theme,
    toggleTheme
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

// Custom hook for using the theme context
export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
```

#### Using Typed Context

```tsx
// App.tsx
import React from 'react';
import { ThemeProvider } from './ThemeContext';
import ThemedButton from './ThemedButton';

const App = () => {
  return (
    <ThemeProvider initialTheme="light">
      <div className="app">
        <h1>Themed App</h1>
        <ThemedButton />
      </div>
    </ThemeProvider>
  );
};

// ThemedButton.tsx
import React from 'react';
import { useTheme } from './ThemeContext';

const ThemedButton = () => {
  const { theme, toggleTheme } = useTheme();
  
  return (
    <button 
      onClick={toggleTheme}
      className={`btn btn-${theme}`}
    >
      Current theme: {theme}. Click to toggle!
    </button>
  );
};
```

#### Complex Context with Multiple Values

For more complex applications, you can create separate contexts or combine them:

```tsx
import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// User-related types
interface User {
  id: string;
  name: string;
  email: string;
}

type AuthState = {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
};

type AuthAction =
  | { type: 'LOGIN_START' }
  | { type: 'LOGIN_SUCCESS'; payload: User }
  | { type: 'LOGIN_FAILURE'; payload: string }
  | { type: 'LOGOUT' };

interface AuthContextType {
  state: AuthState;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

// Create the context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Initial state
const initialState: AuthState = {
  user: null,
  isAuthenticated: false,
  isLoading: false,
  error: null
};

// Reducer function
function authReducer(state: AuthState, action: AuthAction): AuthState {
  switch (action.type) {
    case 'LOGIN_START':
      return { ...state, isLoading: true, error: null };
    case 'LOGIN_SUCCESS':
      return { 
        ...state, 
        isLoading: false, 
        isAuthenticated: true, 
        user: action.payload 
      };
    case 'LOGIN_FAILURE':
      return { 
        ...state, 
        isLoading: false, 
        error: action.payload 
      };
    case 'LOGOUT':
      return initialState;
    default:
      return state;
  }
}

// Provider component
interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [state, dispatch] = useReducer(authReducer, initialState);

  // Login function
  const login = async (email: string, password: string) => {
    try {
      dispatch({ type: 'LOGIN_START' });
      
      // Simulated API call
      const response = await new Promise<User>((resolve) => {
        setTimeout(() => {
          resolve({
            id: '123',
            name: 'John Doe',
            email
          });
        }, 1000);
      });
      
      dispatch({ type: 'LOGIN_SUCCESS', payload: response });
    } catch (error) {
      dispatch({ 
        type: 'LOGIN_FAILURE', 
        payload: error instanceof Error ? error.message : 'Unknown error' 
      });
    }
  };

  // Logout function
  const logout = () => {
    dispatch({ type: 'LOGOUT' });
  };

  const value = {
    state,
    login,
    logout
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook
export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
```

#### Using Multiple Contexts Together

```tsx
// App.tsx
import React from 'react';
import { ThemeProvider } from './ThemeContext';
import { AuthProvider } from './AuthContext';
import Dashboard from './Dashboard';

const App = () => {
  return (
    <AuthProvider>
      <ThemeProvider>
        <Dashboard />
      </ThemeProvider>
    </AuthProvider>
  );
};

// Dashboard.tsx
import React from 'react';
import { useAuth } from './AuthContext';
import { useTheme } from './ThemeContext';
import LoginForm from './LoginForm';
import UserProfile from './UserProfile';

const Dashboard = () => {
  const { state } = useAuth();
  const { theme } = useTheme();
  
  return (
    <div className={`dashboard dashboard-${theme}`}>
      <h1>Application Dashboard</h1>
      {state.isAuthenticated ? <UserProfile /> : <LoginForm />}
    </div>
  );
};
```

### Advanced TypeScript Features for React

#### Generic Components

Generic components provide flexibility while maintaining type safety:

```tsx
import React from 'react';

// Generic component that can display any data type
interface DataDisplayProps<T> {
  data: T;
  renderItem: (item: T) => React.ReactNode;
  fallback?: React.ReactNode;
}

function DataDisplay<T>({ 
  data, 
  renderItem, 
  fallback = <p>No data available</p> 
}: DataDisplayProps<T>) {
  if (!data) {
    return <>{fallback}</>;
  }
  
  return <>{renderItem(data)}</>;
}

// Usage
const UserDisplay = () => {
  const user = { id: 1, name: 'Alice', role: 'Admin' };
  
  return (
    <DataDisplay
      data={user}
      renderItem={(user) => (
        <div>
          <h3>{user.name}</h3>
          <p>Role: {user.role}</p>
        </div>
      )}
    />
  );
};

const NumberDisplay = () => {
  const count = 42;
  
  return (
    <DataDisplay
      data={count}
      renderItem={(num) => <span>The answer is {num}</span>}
      fallback={<span>No number provided</span>}
    />
  );
};
```

#### Type Guards with React

Type guards help narrow types in conditional rendering:

```tsx
type ResponseStatus = 'loading' | 'success' | 'error';

interface BaseState {
  status: ResponseStatus;
}

interface LoadingState extends BaseState {
  status: 'loading';
}

interface SuccessState extends BaseState {
  status: 'success';
  data: { id: string; name: string }[];
}

interface ErrorState extends BaseState {
  status: 'error';
  error: string;
}

type State = LoadingState | SuccessState | ErrorState;

// Type guard functions
function isLoading(state: State): state is LoadingState {
  return state.status === 'loading';
}

function isSuccess(state: State): state is SuccessState {
  return state.status === 'success';
}

function isError(state: State): state is ErrorState {
  return state.status === 'error';
}

// Component using type guards for conditional rendering
const DataFetcher = () => {
  const [state, setState] = useState<State>({ status: 'loading' });
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        // Simulated API call
        const response = await fetch('/api/data');
        if (!response.ok) throw new Error('Failed to fetch');
        
        const data = await response.json();
        setState({ status: 'success', data });
      } catch (error) {
        setState({ 
          status: 'error', 
          error: error instanceof Error ? error.message : 'Unknown error' 
        });
      }
    };
    
    fetchData();
  }, []);
  
  // Conditional rendering with type narrowing
  if (isLoading(state)) {
    return <div>Loading...</div>;
  }
  
  if (isError(state)) {
    return <div>Error: {state.error}</div>;
  }
  
  if (isSuccess(state)) {
    return (
      <ul>
        {state.data.map(item => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>
    );
  }
  
  // TypeScript can detect if you've handled all possible states
  // This line should be unreachable if all states are handled above
  const _exhaustiveCheck: never = state;
  return null;
};
```

### Event Handling with TypeScript

Properly typed event handlers improve safety and developer experience:

```tsx
import React, { ChangeEvent, FormEvent, MouseEvent, KeyboardEvent } from 'react';

interface LoginFormData {
  email: string;
  password: string;
}

const LoginForm = () => {
  const [formData, setFormData] = useState<LoginFormData>({
    email: '',
    password: ''
  });
  
  // Typed change event handler
  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };
  
  // Typed submit event handler
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
  };
  
  // Typed click event handler
  const handleButtonClick = (e: MouseEvent<HTMLButtonElement>) => {
    console.log('Button clicked at:', e.clientX, e.clientY);
  };
  
  // Typed keyboard event handler
  const handleKeyPress = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      console.log('Enter pressed in input');
    }
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="email">Email:</label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          onKeyPress={handleKeyPress}
          required
        />
      </div>
      <div>
        <label htmlFor="password">Password:</label>
        <input
          type="password"
          id="password"
          name="password"
          value={formData.password}
          onChange={handleChange}
          required
        />
      </div>
      <button type="submit" onClick={handleButtonClick}>
        Login
      </button>
    </form>
  );
};
```

### Utility Types for React Development

TypeScript provides useful utility types that can simplify React development:

```tsx
// Partial: Makes all properties optional
type PartialUser = Partial<User>;
// Useful for updates where only some properties change

// Required: Makes all properties required
type RequiredUser = Required<User>;
// Useful when ensuring all fields are provided

// Pick: Select specific properties
type UserCredentials = Pick<User, 'email' | 'password'>;
// Creates a type with only email and password from User

// Omit: Remove specific properties
type PublicUser = Omit<User, 'password' | 'token'>;
// Creates a type with all User properties except password and token

// Record: Create a dictionary type
type UserRoles = Record<string, string[]>;
// Creates a type with string keys and string[] values

// Example usage within React components
interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  role: string;
  token?: string;
}

interface UpdateUserFormProps {
  user: User;
  onSave: (updatedUser: Partial<User>) => void;
}

const UpdateUserForm = ({ user, onSave }: UpdateUserFormProps) => {
  const [formData, setFormData] = useState<Partial<User>>({
    name: user.name,
    email: user.email
  });
  
  const handleSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    onSave(formData);
  };
  
  // Form implementation...
  return <form onSubmit={handleSubmit}>...</form>;
};

// Public profile component omitting sensitive data
const UserProfile = ({ user }: { user: User }) => {
  // Extract only public information
  const publicInfo: PublicUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role
  };
  
  return (
    <div>
      <h2>{publicInfo.name}</h2>
      <p>Email: {publicInfo.email}</p>
      <p>Role: {publicInfo.role}</p>
    </div>
  );
};
```

### Performance Optimization with TypeScript

TypeScript not only provides type safety for React applications but can also be leveraged to optimize performance. Using TypeScript effectively can help identify and resolve performance bottlenecks at compile time rather than at runtime.

#### Memoization with TypeScript

Memoization is a performance optimization technique that prevents unnecessary re-renders by caching results of expensive calculations or component renders.

```typescript
import React, { useMemo, useCallback, memo } from 'react';

// Strongly typed props with required and optional properties
interface ListItemProps {
  item: {
    id: number;
    title: string;
    description: string;
  };
  onSelect: (id: number) => void;
  isSelected?: boolean;
}

// Memoized component with properly typed props
const ListItem = memo(({ item, onSelect, isSelected = false }: ListItemProps) => {
  // Component logic
  console.log(`Rendering ListItem ${item.id}`);
  
  return (
    <div 
      className={`list-item ${isSelected ? 'selected' : ''}`}
      onClick={() => onSelect(item.id)}
    >
      <h3>{item.title}</h3>
      <p>{item.description}</p>
    </div>
  );
});

// Parent component with memoized callbacks and values
const ItemList: React.FC<{ items: Array<ListItemProps['item']> }> = ({ items }) => {
  const [selectedId, setSelectedId] = React.useState<number | null>(null);
  
  // Memoized callback with correct type
  const handleSelect = useCallback((id: number) => {
    setSelectedId(id);
  }, []);
  
  // Memoized expensive calculation with correct return type
  const processedItems = useMemo<Array<ListItemProps['item']>>(() => {
    console.log('Processing items');
    return items.map(item => ({
      ...item,
      title: item.title.toUpperCase()
    }));
  }, [items]);
  
  return (
    <div className="list-container">
      {processedItems.map(item => (
        <ListItem
          key={item.id}
          item={item}
          onSelect={handleSelect}
          isSelected={item.id === selectedId}
        />
      ))}
    </div>
  );
};
```

#### Type-Safe Lazy Loading

Type safety can be maintained while implementing lazy loading for components:

```typescript
import React, { Suspense, lazy, ComponentType } from 'react';

// Type-safe lazy loading
const LazyComponent = lazy<ComponentType<{ title: string }>>(
  () => import('./HeavyComponent')
);

interface AppProps {
  showHeavyComponent: boolean;
}

const App: React.FC<AppProps> = ({ showHeavyComponent }) => {
  return (
    <div>
      <h1>My App</h1>
      {showHeavyComponent && (
        <Suspense fallback={<div>Loading...</div>}>
          <LazyComponent title="Lazy Loaded Component" />
        </Suspense>
      )}
    </div>
  );
};
```

#### Optimizing Re-renders with TypeScript Discriminated Unions

TypeScript's discriminated unions can help optimize conditional rendering:

```typescript
// Discriminated union for component state
type ViewState = 
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: User[] };

interface User {
  id: string;
  name: string;
  email: string;
}

const UserDashboard: React.FC = () => {
  const [state, setState] = React.useState<ViewState>({ status: 'loading' });
  
  React.useEffect(() => {
    fetchUsers()
      .then(users => setState({ status: 'success', data: users }))
      .catch(error => setState({ status: 'error', error }));
  }, []);
  
  // Optimized rendering based on state type
  switch (state.status) {
    case 'loading':
      return <LoadingSpinner />;
    case 'error':
      return <ErrorMessage message={state.error.message} />;
    case 'success':
      return <UserList users={state.data} />;
  }
};
```

#### Virtual List Optimization with TypeScript

TypeScript helps create type-safe virtual list implementations:

```typescript
import React from 'react';

interface VirtualListProps<T> {
  items: T[];
  height: number;
  itemHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T, index: number) => string;
}

function VirtualList<T>({
  items,
  height,
  itemHeight,
  renderItem,
  keyExtractor
}: VirtualListProps<T>) {
  const [scrollTop, setScrollTop] = React.useState(0);
  
  // Calculate which items should be visible
  const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight));
  const endIndex = Math.min(items.length - 1, Math.floor((scrollTop + height) / itemHeight));
  
  const visibleItems = items.slice(startIndex, endIndex + 1);
  const totalHeight = items.length * itemHeight;
  
  const handleScroll = (e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  };
  
  return (
    <div
      style={{ height, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        {visibleItems.map((item, relativeIndex) => {
          const absoluteIndex = startIndex + relativeIndex;
          return (
            <div
              key={keyExtractor(item, absoluteIndex)}
              style={{
                position: 'absolute',
                top: absoluteIndex * itemHeight,
                height: itemHeight,
                width: '100%'
              }}
            >
              {renderItem(item, absoluteIndex)}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// Usage with strong typing
interface User {
  id: string;
  name: string;
  email: string;
}

const UserList: React.FC<{ users: User[] }> = ({ users }) => {
  return (
    <VirtualList<User>
      items={users}
      height={400}
      itemHeight={50}
      keyExtractor={(user) => user.id}
      renderItem={(user) => (
        <div className="user-item">
          <strong>{user.name}</strong>
          <div>{user.email}</div>
        </div>
      )}
    />
  );
};
```

#### Optimizing Component Props with TypeScript

Type-checking can identify unnecessary prop changes that might trigger re-renders:

```typescript
import React, { memo } from 'react';

// Props interface with strict typing
interface UserCardProps {
  user: {
    id: string;
    name: string;
    email: string;
    role: 'admin' | 'user' | 'guest';
  };
  onUserUpdate: (id: string, updates: Partial<Omit<UserCardProps['user'], 'id'>>) => void;
}

// Custom equality function with type safety
function areEqual(prevProps: UserCardProps, nextProps: UserCardProps): boolean {
  return (
    prevProps.user.id === nextProps.user.id &&
    prevProps.user.name === nextProps.user.name &&
    prevProps.user.email === nextProps.user.email &&
    prevProps.user.role === nextProps.user.role &&
    prevProps.onUserUpdate === nextProps.onUserUpdate
  );
}

// Memoized component with custom equality check
const UserCard = memo<UserCardProps>(({ user, onUserUpdate }) => {
  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    onUserUpdate(user.id, { name: e.target.value });
  };

  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <span className="badge">{user.role}</span>
      <input
        type="text"
        value={user.name}
        onChange={handleNameChange}
        className="name-input"
      />
    </div>
  );
}, areEqual);
```

#### Reducing Bundle Size with Type-Only Imports

TypeScript allows type-only imports that don't add to your runtime bundle:

```typescript
// Regular import (adds to bundle)
import { SomeComponent } from './components';

// Type-only import (doesn't add to bundle)
import type { SomeComponentProps } from './components';

// Mixed imports
import { SomeComponent, type SomeComponentProps } from './components';

// Type-safe component that doesn't bloat your bundle
const MyComponent: React.FC<SomeComponentProps> = (props) => {
  return <SomeComponent {...props} extraProp={true} />;
};
```

#### Using const Assertions for Performance

Const assertions can help optimize React performance by allowing TypeScript to infer the narrowest type possible:

```typescript
// Without const assertion - type is { type: string, payload: string }
const regularAction = { type: 'USER_LOGGED_IN', payload: 'user123' };

// With const assertion - type is { type: 'USER_LOGGED_IN', payload: 'user123' }
const specificAction = { type: 'USER_LOGGED_IN', payload: 'user123' } as const;

// This allows for more specific type checking in reducer functions
type UserAction = typeof specificAction;

function userReducer(state: UserState, action: UserAction) {
  // TypeScript knows action.type is exactly 'USER_LOGGED_IN'
  // No need for string comparison
  switch (action.type) {
    case 'USER_LOGGED_IN':
      return { ...state, currentUser: action.payload, isLoggedIn: true };
    default:
      return state;
  }
}
```

#### Typed Webpack Code Splitting

TypeScript can help maintain type safety with code splitting:

```typescript
// Strongly typed dynamic imports
interface DynamicComponentProps {
  name: string;
}

// Returns a properly typed promise
const loadDynamicComponent = (): Promise<React.ComponentType<DynamicComponentProps>> => {
  return import('./DynamicComponent').then(module => module.default);
};

const DynamicComponentLoader: React.FC = () => {
  const [Component, setComponent] = React.useState<React.ComponentType<DynamicComponentProps> | null>(null);
  const [loading, setLoading] = React.useState(true);
  
  React.useEffect(() => {
    let mounted = true;
    
    loadDynamicComponent().then(LoadedComponent => {
      if (mounted) {
        setComponent(() => LoadedComponent);
        setLoading(false);
      }
    });
    
    return () => { mounted = false };
  }, []);
  
  if (loading) return <div>Loading...</div>;
  if (!Component) return <div>Failed to load component</div>;
  
  // Type-safe rendering of dynamically loaded component
  return <Component name="Dynamic Content" />;
};
```

### Testing React Components with TypeScript

TypeScript enhances testing by providing type checking for test cases and mocks, reducing runtime errors and improving test reliability.

#### Unit Testing Components with Jest and TypeScript

```typescript
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { Counter } from './Counter';

// Type definition for component props
interface CounterProps {
  initialCount?: number;
  step?: number;
  onCountChange?: (count: number) => void;
}

describe('Counter Component', () => {
  const renderCounter = (props: Partial<CounterProps> = {}) => {
    const defaultProps: CounterProps = {
      initialCount: 0,
      step: 1,
      onCountChange: jest.fn(),
    };
    return render(<Counter {...defaultProps} {...props} />);
  };

  it('should render with initial count', () => {
    renderCounter({ initialCount: 5 });
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });

  it('should increment counter when increment button is clicked', () => {
    const onCountChange = jest.fn();
    renderCounter({ onCountChange });
    
    fireEvent.click(screen.getByText('+'));
    expect(screen.getByText('Count: 1')).toBeInTheDocument();
    expect(onCountChange).toHaveBeenCalledWith(1);
  });

  it('should use custom step value', () => {
    renderCounter({ step: 5 });
    
    fireEvent.click(screen.getByText('+'));
    expect(screen.getByText('Count: 5')).toBeInTheDocument();
  });
});
```

#### Type-Safe Component Mocking

```typescript
import React from 'react';
import { render, screen } from '@testing-library/react';
import { UserProfile } from './UserProfile';
import { UserService } from '../services/UserService';

// Mock the service with TypeScript
jest.mock('../services/UserService');

// Type the mocked service
const MockedUserService = UserService as jest.MockedClass<typeof UserService>;

describe('UserProfile Component', () => {
  beforeEach(() => {
    // Reset all mocks
    MockedUserService.mockClear();
    
    // Setup the mock implementation with correct types
    MockedUserService.prototype.getUserProfile.mockResolvedValue({
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      role: 'user'
    });
  });

  it('should fetch and display user profile', async () => {
    render(<UserProfile userId="123" />);
    
    // Verify loading state
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    
    // Wait for the user data to load
    const userName = await screen.findByText('Test User');
    expect(userName).toBeInTheDocument();
    expect(screen.getByText('test@example.com')).toBeInTheDocument();
    
    // Verify service was called correctly
    expect(MockedUserService.prototype.getUserProfile).toHaveBeenCalledWith('123');
  });
});
```

### Scalable State Management with TypeScript

Type-safe state management is crucial for large React applications, and TypeScript helps ensure consistency and prevent errors.

#### Type-Safe Redux with TypeScript

```typescript
// Action types as string literals
const ADD_TODO = 'ADD_TODO';
const TOGGLE_TODO = 'TOGGLE_TODO';
const SET_VISIBILITY_FILTER = 'SET_VISIBILITY_FILTER';

// Type definitions
interface Todo {
  id: number;
  text: string;
  completed: boolean;
}

type VisibilityFilter = 'SHOW_ALL' | 'SHOW_COMPLETED' | 'SHOW_ACTIVE';

// Action interfaces
interface AddTodoAction {
  type: typeof ADD_TODO;
  payload: {
    text: string;
  };
}

interface ToggleTodoAction {
  type: typeof TOGGLE_TODO;
  payload: {
    id: number;
  };
}

interface SetVisibilityFilterAction {
  type: typeof SET_VISIBILITY_FILTER;
  payload: {
    filter: VisibilityFilter;
  };
}

// Union type for all actions
type TodoActionTypes = AddTodoAction | ToggleTodoAction | SetVisibilityFilterAction;

// State interface
interface TodoState {
  todos: Todo[];
  visibilityFilter: VisibilityFilter;
}

// Initial state
const initialState: TodoState = {
  todos: [],
  visibilityFilter: 'SHOW_ALL'
};

// Type-safe reducer
function todoReducer(state = initialState, action: TodoActionTypes): TodoState {
  switch (action.type) {
    case ADD_TODO:
      return {
        ...state,
        todos: [
          ...state.todos,
          {
            id: state.todos.length + 1,
            text: action.payload.text,
            completed: false
          }
        ]
      };
    case TOGGLE_TODO:
      return {
        ...state,
        todos: state.todos.map(todo =>
          todo.id === action.payload.id
            ? { ...todo, completed: !todo.completed }
            : todo
        )
      };
    case SET_VISIBILITY_FILTER:
      return {
        ...state,
        visibilityFilter: action.payload.filter
      };
    default:
      return state;
  }
}

// Type-safe action creators
function addTodo(text: string): AddTodoAction {
  return {
    type: ADD_TODO,
    payload: { text }
  };
}

function toggleTodo(id: number): ToggleTodoAction {
  return {
    type: TOGGLE_TODO,
    payload: { id }
  };
}

function setVisibilityFilter(filter: VisibilityFilter): SetVisibilityFilterAction {
  return {
    type: SET_VISIBILITY_FILTER,
    payload: { filter }
  };
}
```

#### Type-Safe Global State with TypeScript and Context API

```typescript
import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// Define the state shape
interface User {
  id: string;
  name: string;
  email: string;
}

interface AppState {
  user: User | null;
  isAuthenticated: boolean;
  theme: 'light' | 'dark';
  language: 'en' | 'es' | 'fr';
}

// Define action types
type ActionType = 
  | { type: 'LOGIN_USER'; payload: User }
  | { type: 'LOGOUT_USER' }
  | { type: 'SET_THEME'; payload: 'light' | 'dark' }
  | { type: 'SET_LANGUAGE'; payload: 'en' | 'es' | 'fr' };

// Initial state
const initialState: AppState = {
  user: null,
  isAuthenticated: false,
  theme: 'light',
  language: 'en'
};

// Type-safe reducer
function appReducer(state: AppState, action: ActionType): AppState {
  switch (action.type) {
    case 'LOGIN_USER':
      return {
        ...state,
        user: action.payload,
        isAuthenticated: true
      };
    case 'LOGOUT_USER':
      return {
        ...state,
        user: null,
        isAuthenticated: false
      };
    case 'SET_THEME':
      return {
        ...state,
        theme: action.payload
      };
    case 'SET_LANGUAGE':
      return {
        ...state,
        language: action.payload
      };
    default:
      return state;
  }
}

// Create the context with proper types
interface AppContextType {
  state: AppState;
  dispatch: React.Dispatch<ActionType>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider component
interface AppProviderProps {
  children: ReactNode;
}

export const AppProvider: React.FC<AppProviderProps> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);
  
  // Memoize the context value to prevent unnecessary renders
  const contextValue = React.useMemo(() => {
    return { state, dispatch };
  }, [state, dispatch]);
  
  return (
    <AppContext.Provider value={contextValue}>
      {children}
    </AppContext.Provider>
  );
};

// Custom hook for accessing the context
export function useAppContext(): AppContextType {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
}

// Example usage in a component
const UserProfile: React.FC = () => {
  const { state, dispatch } = useAppContext();
  
  const handleLogout = () => {
    dispatch({ type: 'LOGOUT_USER' });
  };
  
  const toggleTheme = () => {
    const newTheme = state.theme === 'light' ? 'dark' : 'light';
    dispatch({ type: 'SET_THEME', payload: newTheme });
  };
  
  if (!state.isAuthenticated) {
    return <div>Please log in</div>;
  }
  
  return (
    <div className={`profile ${state.theme}`}>
      <h2>{state.user?.name}</h2>
      <p>{state.user?.email}</p>
      <button onClick={toggleTheme}>
        Switch to {state.theme === 'light' ? 'Dark' : 'Light'} Mode
      </button>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );
};
```

### Type-Safe Styling in React

TypeScript can improve CSS-in-JS solutions by providing type checking for styles and themes.

#### Styled Components with TypeScript

```typescript
import styled, { ThemeProvider, DefaultTheme } from 'styled-components';
import React from 'react';

// Define theme interface
interface MyTheme extends DefaultTheme {
  colors: {
    primary: string;
    secondary: string;
    background: string;
    text: string;
    error: string;
  };
  fontSizes: {
    small: string;
    medium: string;
    large: string;
    xlarge: string;
  };
  spacing: {
    xs: string;
    sm: string;
    md: string;
    lg: string;
    xl: string;
  };
  borderRadius: {
    small: string;
    medium: string;
    large: string;
    round: string;
  };
}

// Create and export theme
export const theme: MyTheme = {
  colors: {
    primary: '#0070f3',
    secondary: '#6c757d',
    background: '#ffffff',
    text: '#333333',
    error: '#d32f2f',
  },
  fontSizes: {
    small: '0.875rem',
    medium: '1rem',
    large: '1.25rem',
    xlarge: '1.5rem',
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
  },
  borderRadius: {
    small: '0.25rem',
    medium: '0.5rem',
    large: '1rem',
    round: '50%',
  },
};

// Type for button variants
type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'success';

// Props interface with TypeScript
interface ButtonProps {
  variant?: ButtonVariant;
  size?: 'small' | 'medium' | 'large';
  fullWidth?: boolean;
  disabled?: boolean;
}

// Type-safe styled component
const Button = styled.button<ButtonProps>`
  font-family: inherit;
  font-weight: 600;
  cursor: ${props => props.disabled ? 'not-allowed' : 'pointer'};
  display: inline-flex;
  align-items: center;
  justify-content: center;
  
  /* Size variants */
  font-size: ${props => {
    switch (props.size) {
      case 'small': return props.theme.fontSizes.small;
      case 'large': return props.theme.fontSizes.large;
      default: return props.theme.fontSizes.medium;
    }
  }};
  
  padding: ${props => {
    switch (props.size) {
      case 'small': return `${props.theme.spacing.xs} ${props.theme.spacing.sm}`;
      case 'large': return `${props.theme.spacing.md} ${props.theme.spacing.lg}`;
      default: return `${props.theme.spacing.sm} ${props.theme.spacing.md}`;
    }
  }};
  
  /* Color variants */
  background-color: ${props => {
    if (props.disabled) return props.theme.colors.secondary;
    switch (props.variant) {
      case 'secondary': return 'transparent';
      case 'danger': return '#f44336';
      case 'success': return '#4caf50';
      default: return props.theme.colors.primary;
    }
  }};
  
  color: ${props => {
    if (props.disabled) return '#aaaaaa';
    switch (props.variant) {
      case 'secondary': return props.theme.colors.primary;
      default: return '#ffffff';
    }
  }};
  
  border: ${props => 
    props.variant === 'secondary' 
      ? `1px solid ${props.theme.colors.primary}` 
      : 'none'
  };
  
  border-radius: ${props => props.theme.borderRadius.medium};
  width: ${props => props.fullWidth ? '100%' : 'auto'};
  opacity: ${props => props.disabled ? 0.7 : 1};
  
  &:hover {
    ${props => !props.disabled && `
      filter: brightness(110%);
    `}
  }
  
  &:active {
    ${props => !props.disabled && `
      transform: translateY(1px);
    `}
  }
`;

// Usage in a component
const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <div>
        <h1>Styled Components with TypeScript</h1>
        <Button>Default Button</Button>
        <Button variant="secondary" size="small">Secondary Small</Button>
        <Button variant="danger" size="large" fullWidth>
          Danger Large Full Width
        </Button>
        <Button disabled>Disabled Button</Button>
      </div>
    </ThemeProvider>
  );
};
```

#### CSS Modules with TypeScript

```typescript
// styles.module.css.d.ts
declare const styles: {
  readonly container: string;
  readonly header: string;
  readonly button: string;
  readonly buttonPrimary: string;
  readonly buttonSecondary: string;
  readonly active: string;
};

export default styles;

// Component.tsx
import React from 'react';
import styles from './styles.module.css';

interface ButtonProps {
  variant: 'primary' | 'secondary';
  active?: boolean;
  onClick?: () => void;
  children: React.ReactNode;
}

const Button: React.FC<ButtonProps> = ({
  variant = 'primary',
  active = false,
  onClick,
  children
}) => {
  const buttonClass = `
    ${styles.button}
    ${variant === 'primary' ? styles.buttonPrimary : styles.buttonSecondary}
    ${active ? styles.active : ''}
  `.trim();
  
  return (
    <button className={buttonClass} onClick={onClick}>
      {children}
    </button>
  );
};
```

### Accessibility with TypeScript

TypeScript can help enforce accessibility best practices in React applications.

#### Typed ARIA Attributes

```typescript
import React from 'react';

interface AccessibleButtonProps {
  onClick: () => void;
  label: string;
  isExpanded?: boolean;
  controlsId?: string;
  disabled?: boolean;
  children: React.ReactNode;
}

const AccessibleButton: React.FC<AccessibleButtonProps> = ({
  onClick,
  label,
  isExpanded,
  controlsId,
  disabled = false,
  children
}) => {
  // Type-safe ARIA attributes
  const ariaAttributes: React.AriaAttributes = {
    'aria-label': label,
    'aria-expanded': isExpanded,
    'aria-controls': controlsId,
    'aria-disabled': disabled
  };
  
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      {...ariaAttributes}
    >
      {children}
    </button>
  );
};

// Usage
const App: React.FC = () => {
  const [isOpen, setIsOpen] = React.useState(false);
  
  return (
    <div>
      <AccessibleButton
        onClick={() => setIsOpen(!isOpen)}
        label="Toggle Menu"
        isExpanded={isOpen}
        controlsId="mainMenu"
      >
        Menu
      </AccessibleButton>
      
      <div id="mainMenu" hidden={!isOpen}>
        {/* Menu content */}
      </div>
    </div>
  );
};
```

### Server-Side Rendering with TypeScript

TypeScript improves type safety in server-side rendered React applications.

#### Next.js with TypeScript

```typescript
// pages/[slug].tsx
import { GetServerSideProps, NextPage } from 'next';
import React from 'react';

interface Article {
  id: number;
  title: string;
  content: string;
  publishedDate: string;
  author: {
    id: number;
    name: string;
  };
}

interface ArticlePageProps {
  article: Article | null;
  error?: string;
}

const ArticlePage: NextPage<ArticlePageProps> = ({ article, error }) => {
  if (error) {
    return <div className="error">{error}</div>;
  }
  
  if (!article) {
    return <div>Loading...</div>;
  }
  
  return (
    <article>
      <h1>{article.title}</h1>
      <div className="meta">
        By {article.author.name} on {new Date(article.publishedDate).toLocaleDateString()}
      </div>
      <div className="content" dangerouslySetInnerHTML={{ __html: article.content }} />
    </article>
  );
};

export const getServerSideProps: GetServerSideProps<ArticlePageProps> = async (context) => {
  const { slug } = context.params || {};
  
  try {
    // Type safety in API calls
    const response = await fetch(`https://api.example.com/articles/${slug}`);
    
    if (!response.ok) {
      // Handle errors with proper typing
      if (response.status === 404) {
        return { props: { article: null, error: 'Article not found' } };
      }
      throw new Error(`API error: ${response.status}`);
    }
    
    const article: Article = await response.json();
    
    return {
      props: { article }
    };
  } catch (error) {
    console.error('Failed to fetch article:', error);
    return {
      props: {
        article: null,
        error: 'Failed to load article'
      }
    };
  }
};

export default ArticlePage;
```

### Recommended Related Topics

- TypeScript Design Patterns for React Applications
- Advanced TypeScript Generic Components
- TypeScript Migration Strategies for Existing React Projects
- Building Component Libraries with TypeScript and React
- TypeScript with GraphQL and React
- End-to-End Type Safety with TypeScript, React, and Backend APIs
- TypeScript Custom Type Guards for React Components

---
