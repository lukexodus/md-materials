# React + TypeScript Types — Complete Taxonomy

---

## 1. TypeScript Primitives

| Type        | Description                                                                    |
| ----------- | ------------------------------------------------------------------------------ |
| `string`    | Text values.                                                                   |
| `number`    | All numeric values (int and float).                                            |
| `boolean`   | `true` or `false`.                                                             |
| `bigint`    | Arbitrary-precision integers.                                                  |
| `symbol`    | Unique, immutable identifier.                                                  |
| `null`      | Intentional absence of value.                                                  |
| `undefined` | Variable declared but not assigned.                                            |
| `never`     | Type with no possible values; used for exhaustive checks and unreachable code. |
| `unknown`   | Top type; must narrow before use. Safer than `any`.                            |
| `any`       | Opts out of type checking. Avoid when possible.                                |
| `void`      | Return type for functions that return nothing meaningful.                      |
| `object`    | Any non-primitive value.                                                       |

---

## 2. TypeScript Constructs

|Type|Description|
|---|---|
|`interface`|Declares an object shape. Extensible via declaration merging.|
|`type alias`|Names any type expression including unions, intersections, and mapped types.|
|`enum`|Named set of numeric or string constants.|
|`const enum`|Inlined enum — values replaced at compile time.|
|`tuple`|Fixed-length array with typed positions, e.g. `[string, number]`.|
|`A \| B` (union)|Value may be one of multiple types.|
|`A & B` (intersection)|Value must satisfy all combined types simultaneously.|
|Literal types|Exact value as a type, e.g. `'left' \| 'right'` or `42`.|
|Template literal type|String pattern as a type, e.g. `` `on${string}` ``.|
|`keyof`|Produces a union of all keys of a type.|
|`typeof` (type-level)|Infers the type of a variable or expression.|
|`infer`|Captures a type within a conditional type for later use.|
|Conditional type|`T extends U ? X : Y` — type branching.|
|Mapped type|Transforms each property of a type, e.g. `{ [K in keyof T]: ... }`.|
|Indexed access `T[K]`|Looks up the type of property `K` on type `T`.|
|`satisfies`|Validates a value matches a type while preserving the narrowed literal type.|
|`as const`|Freezes inferred types to their literal values and makes arrays readonly.|
|`declare`|Ambient declaration — tells TS a value exists without emitting code.|
|`namespace`|Groups related types or values under a named scope.|
|Module augmentation|Adds declarations to an existing module or global.|

---

## 3. TypeScript Utility Types

|Type|Description|
|---|---|
|`Partial<T>`|All properties of `T` become optional.|
|`Required<T>`|All properties of `T` become required.|
|`Readonly<T>`|All properties of `T` become readonly.|
|`Record<K, V>`|Object type with keys `K` and values `V`.|
|`Pick<T, K>`|Keeps only the listed keys from `T`.|
|`Omit<T, K>`|Removes the listed keys from `T`.|
|`Exclude<T, U>`|Removes from union `T` members assignable to `U`.|
|`Extract<T, U>`|Keeps only union `T` members assignable to `U`.|
|`NonNullable<T>`|Removes `null` and `undefined` from `T`.|
|`ReturnType<T>`|Infers the return type of a function type.|
|`Parameters<T>`|Infers the parameter types of a function as a tuple.|
|`ConstructorParameters<T>`|Infers constructor parameter types as a tuple.|
|`InstanceType<T>`|Infers the instance type of a constructor.|
|`Awaited<T>`|Recursively unwraps `Promise` types.|
|`ThisType<T>`|Sets the type of `this` inside an object literal.|
|`ThisParameterType<T>`|Extracts the type of the explicit `this` parameter.|
|`OmitThisParameter<T>`|Removes the `this` parameter from a function type.|
|`Uppercase<S>`|Transforms a string literal type to uppercase.|
|`Lowercase<S>`|Transforms a string literal type to lowercase.|
|`Capitalize<S>`|Capitalizes the first character of a string literal type.|
|`Uncapitalize<S>`|Lowercases the first character of a string literal type.|

---

## 4. React Core Types

|Type|Description|
|---|---|
|`React.ReactNode`|Everything React can render: elements, strings, numbers, portals, null, booleans, arrays, fragments.|
|`React.ReactElement`|Object returned by JSX / `createElement` — has `type`, `props`, `key`.|
|`React.ReactChild`|Deprecated alias for `ReactElement \| string \| number`.|
|`React.JSX.Element`|Alias for `ReactElement<any>`; the type inferred from JSX expressions.|
|`React.FC<P>`|Function component type. Implicit `children` was removed in React 18.|
|`React.FunctionComponent<P>`|Long form of `React.FC<P>`.|
|`React.Component<P, S>`|Base class for class components, with props `P` and state `S`.|
|`React.PureComponent<P, S>`|Class component with shallow `shouldComponentUpdate`.|
|`React.ComponentType<P>`|Either a function component or class component accepting props `P`.|
|`React.ComponentProps<T>`|Extracts the props type of a component type `T`.|
|`React.ComponentPropsWithRef<T>`|`ComponentProps<T>` with `ref` included.|
|`React.ComponentPropsWithoutRef<T>`|`ComponentProps<T>` with `ref` excluded.|
|`React.ElementType`|Any valid JSX element type: string tag name, function component, or class component.|
|`React.ElementRef<T>`|Infers the ref type that a component exposes.|
|`React.PropsWithChildren<P>`|Adds optional `children: ReactNode` to props type `P`.|
|`React.PropsWithRef<P>`|Adds `ref?: Ref<T>` to props type `P`.|
|`React.ExoticComponent<P>`|Type for exotic components like `Context.Provider`, `forwardRef`, `memo`.|
|`React.Provider<T>`|Type of a Context Provider component.|
|`React.Consumer<T>`|Type of a Context Consumer component.|
|`React.Context<T>`|Return type of `React.createContext`.|
|`React.Key`|Valid `key` prop value: `string \| number`.|
|`React.Ref<T>`|`RefCallback<T> \| RefObject<T> \| null` — all ref forms.|
|`React.RefObject<T>`|Object with a mutable `current: T \| null` property.|
|`React.RefCallback<T>`|Callback form of ref: `(instance: T \| null) => void`.|
|`React.MutableRefObject<T>`|`RefObject` whose `current` property is writable.|
|`React.ForwardRefRenderFunction<Ref, P>`|Function passed to `forwardRef`.|
|`React.LazyExoticComponent<T>`|Return type of `React.lazy()`.|
|`React.Suspense`|Component type used to wrap lazy-loaded components.|
|`React.Fragment`|Component type for `<></>` fragments.|
|`React.StrictMode`|Component type that activates additional runtime warnings.|
|`React.Portal`|Return type of `ReactDOM.createPortal`.|

---

## 5. React Hook Types

|Type|Description|
|---|---|
|`React.Dispatch<A>`|Type of the dispatch function returned by `useReducer`.|
|`React.SetStateAction<S>`|`S \| ((prevState: S) => S)` — value or updater function for `useState`.|
|`React.Reducer<S, A>`|`(state: S, action: A) => S` — reducer signature for `useReducer`.|
|`React.ReducerState<R>`|Extracts the state type from a reducer type.|
|`React.ReducerAction<R>`|Extracts the action type from a reducer type.|
|`React.EffectCallback`|`() => void \| (() => void)` — the callback signature for `useEffect` / `useLayoutEffect`.|
|`React.DependencyList`|`ReadonlyArray<unknown>` — the deps array for hooks.|
|`React.TransitionStartFunction`|Function returned by `useTransition` to wrap non-urgent state updates.|
|`useRef` (inferred)|Inferred from the initial value; typically `MutableRefObject<T>` or `RefObject<T>`.|
|`useImperativeHandle` (inferred)|The handle shape is inferred from the second argument.|

---

## 6. React Event Types

|Type|Description|
|---|---|
|`React.SyntheticEvent<T, E>`|Base synthetic event type wrapping native events. `T` = element, `E` = native event.|
|`React.MouseEvent<T>`|Mouse events: click, mousedown, mouseover, etc.|
|`React.KeyboardEvent<T>`|Keyboard events: keydown, keyup, keypress.|
|`React.ChangeEvent<T>`|Input change events; value is in `event.target.value`.|
|`React.FocusEvent<T>`|Focus and blur events.|
|`React.FormEvent<T>`|Form submit and reset events.|
|`React.SubmitEvent<T>`|Form submit events (includes `submitter`).|
|`React.DragEvent<T>`|Drag-and-drop events.|
|`React.TouchEvent<T>`|Touch events on mobile devices.|
|`React.PointerEvent<T>`|Unified pointer events (mouse, pen, touch).|
|`React.WheelEvent<T>`|Mouse wheel / scroll events.|
|`React.ClipboardEvent<T>`|Cut, copy, paste events.|
|`React.AnimationEvent<T>`|CSS animation start, end, iteration events.|
|`React.TransitionEvent<T>`|CSS transition end events.|
|`React.UIEvent<T>`|Generic UI events (scroll, etc.).|
|`React.CompositionEvent<T>`|IME composition events for CJK input.|
|`React.MediaEvent<T>`|Media element events (play, pause, ended, etc.).|
|`React.InvalidEvent<T>`|Input invalid event (constraint validation).|
|`React.EventHandler<E>`|Generic handler type: `(event: E) => void`.|
|`React.MouseEventHandler<T>`|`EventHandler<MouseEvent<T>>`.|
|`React.KeyboardEventHandler<T>`|`EventHandler<KeyboardEvent<T>>`.|
|`React.ChangeEventHandler<T>`|`EventHandler<ChangeEvent<T>>`.|
|`React.FocusEventHandler<T>`|`EventHandler<FocusEvent<T>>`.|
|`React.FormEventHandler<T>`|`EventHandler<FormEvent<T>>`.|

---

## 7. React DOM / HTML Types

|Type|Description|
|---|---|
|`React.HTMLAttributes<T>`|All standard HTML attributes applicable to any HTML element.|
|`React.AriaAttributes`|All ARIA attributes (`aria-*`).|
|`React.DOMAttributes<T>`|Event handler props for a DOM element `T`.|
|`React.HTMLProps<T>`|`HTMLAttributes<T> & ClassAttributes<T>` — full props for a native element.|
|`React.InputHTMLAttributes<T>`|Props for `<input>` elements.|
|`React.TextareaHTMLAttributes<T>`|Props for `<textarea>` elements.|
|`React.SelectHTMLAttributes<T>`|Props for `<select>` elements.|
|`React.ButtonHTMLAttributes<T>`|Props for `<button>` elements.|
|`React.AnchorHTMLAttributes<T>`|Props for `<a>` elements.|
|`React.ImgHTMLAttributes<T>`|Props for `<img>` elements.|
|`React.FormHTMLAttributes<T>`|Props for `<form>` elements.|
|`React.TableHTMLAttributes<T>`|Props for `<table>` elements.|
|`React.VideoHTMLAttributes<T>`|Props for `<video>` elements.|
|`React.AudioHTMLAttributes<T>`|Props for `<audio>` elements.|
|`React.IframeHTMLAttributes<T>`|Props for `<iframe>` elements.|
|`React.LiHTMLAttributes<T>`|Props for `<li>` elements.|
|`React.OlHTMLAttributes<T>`|Props for `<ol>` elements.|
|`React.ThHTMLAttributes<T>`|Props for `<th>` elements.|
|`React.TdHTMLAttributes<T>`|Props for `<td>` elements.|
|`React.MetaHTMLAttributes<T>`|Props for `<meta>` elements.|
|`React.LinkHTMLAttributes<T>`|Props for `<link>` elements.|
|`React.ScriptHTMLAttributes<T>`|Props for `<script>` elements.|
|`React.StyleHTMLAttributes<T>`|Props for `<style>` elements.|
|`React.SVGProps<T>`|All SVG element attributes for a given SVG element `T`.|
|`React.SVGAttributes<T>`|Base SVG attributes including presentation and event attributes.|
|`React.CSSProperties`|TypeScript type for an inline style object; all CSS properties camelCased.|
|`React.ClassAttributes<T>`|Adds `ref` and `key` to class component props.|

---

## 8. React Server / Async Types

|Type|Description|
|---|---|
|`React.Thenable<T>`|Anything with a `then()` method; used internally for server components and `use()`.|
|`React.use<T>`|Unwraps a `Promise` or `Context` inside a component (React 19+). Types `T` from the input.|
|`React.cache<T>`|Memoizes a server-side function call across a render. Types inferred from the wrapped function.|
|`React.ActionDispatch<A>`|Dispatch type used with `useActionState` (React 19+).|
|`React.FormState<S, P>`|Return type of `useActionState` — `[state, dispatch, isPending]`.|

---

## 9. Generic Patterns

|Pattern|Description|
|---|---|
|`<T extends U>` (constraint)|Restricts `T` to types assignable to `U`.|
|`<T = Default>` (default generic)|Provides a fallback type when `T` is not specified.|
|Variadic tuple `<T extends unknown[]>`|Captures a variable number of typed elements, e.g. `[...Head, ...Tail]`.|
|Higher-kinded simulation|Pattern using interface maps to simulate type constructors in TS.|
|Discriminated union|Union where a shared literal property (discriminant) narrows the type.|
|Branded / Nominal type|`type UserId = string & { __brand: 'UserId' }` — prevents structural aliasing.|
|Opaque type|Hides internal representation; only exposed operations are type-safe.|
|Builder pattern type|Each method returns a new type carrying accumulated state.|
|Recursive type|A type that references itself, e.g. `type JSON = string \| number \| JSON[]`.|
|Covariant / Contravariant position|Whether a type parameter flows out (covariant: return) or in (contravariant: parameter).|
|`<const T>` (const type parameter)|TS 5.0+: infers literal types for `T` without requiring `as const` at the call site.|