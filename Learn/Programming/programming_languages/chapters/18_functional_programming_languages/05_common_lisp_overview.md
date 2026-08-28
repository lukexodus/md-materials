## Common Lisp Overview

### Conceptual Foundation

Common Lisp is a standardized, general-purpose LISP dialect developed in the early 1980s to unify a fractured landscape of incompatible LISP implementations — including MacLisp, Interlisp, and several others — that had proliferated since the original 1958 LISP. Rather than being designed from a clean theoretical slate the way Scheme was, Common Lisp was deliberately assembled as a large, practical, feature-rich superset drawing on the best-established features across these prior dialects, standardized first informally through the 1984 book *Common Lisp: The Language* by Guy L. Steele Jr., and later formally as ANSI standard X3.226-1994.

Where Scheme (covered under [[introduction-to-scheme]]) pursued minimalism as an explicit design value, Common Lisp pursued comprehensiveness and practical utility, deliberately including multiple ways to accomplish similar tasks, an extensive standard library, and support for multiple programming paradigms within a single language, reflecting its origins as an industrial and research consolidation effort rather than a language-design research vehicle.

### Lisp-2: Separate Namespaces for Functions and Variables

One of the most consequential and immediately visible differences between Common Lisp and Scheme is that Common Lisp is a **Lisp-2**: it maintains separate namespaces for functions and for variables, meaning the same symbol can simultaneously name a function and, independently, a variable, without conflict.

```lisp
(defun list (x) (+ x 1))  ; defines a FUNCTION named list
(setq list 42)             ; independently binds a VARIABLE named list

(list 5)        ; calls the function: => 6
(print list)    ; refers to the variable: => 42
```

Because of this separation, Common Lisp requires special syntax to pass a named function as a value (since simply writing the symbol `list` in a value position refers to the variable namespace, not the function namespace):

```lisp
(mapcar #'list '(1 2 3))
; #' (the "function" special operator, short for FUNCTION) explicitly
; retrieves the FUNCTION binding of the symbol list, not its variable binding
```

[Inference] This Lisp-2 design is frequently cited as a source of minor but persistent friction for programmers moving between Common Lisp and Scheme (a Lisp-1, with a single shared namespace), since code and mental habits from one do not directly transfer to the other without adjustment — Scheme's `(list 5)` unambiguously calls a function named `list`, with no separate `#'` needed, precisely because there is only one namespace to look in.

### CLOS: The Common Lisp Object System

Common Lisp's approach to object-oriented programming, the **Common Lisp Object System (CLOS)**, was added to the language during standardization and is distinctive among object-oriented systems for being built around **generic functions** and **multiple dispatch**, rather than the single-dispatch, message-passing-to-an-object model used by languages like Java, Python, or C++.

```lisp
(defclass shape () ())
(defclass circle (shape) ((radius :initarg :radius :accessor circle-radius)))
(defclass rectangle (shape) ((width :initarg :width :accessor rect-width)
                              (height :initarg :height :accessor rect-height)))

(defgeneric area (s))

(defmethod area ((s circle))
  (* pi (expt (circle-radius s) 2)))

(defmethod area ((s rectangle))
  (* (rect-width s) (rect-height s)))
```

In CLOS, `area` is a single **generic function** with multiple **methods** attached to it, each specialized to a different class of argument; calling `(area some-shape)` dispatches to whichever method's parameter specializers match the actual runtime class of the argument. This differs structurally from Java-style OOP, where `area()` would instead be a method defined *inside* each class (`Circle.area()`, `Rectangle.area()`), belonging to the class rather than existing as an independent, standalone function that classes contribute implementations to.

**Multiple dispatch** extends this further: a generic function can specialize its behavior based on the runtime classes of *more than one* argument simultaneously, a capability most single-dispatch OOP languages lack natively and can only simulate indirectly (commonly via the visitor pattern).

```lisp
(defgeneric collide (a b))

(defmethod collide ((a circle) (b circle))
  (format t "Circle-circle collision~%"))

(defmethod collide ((a circle) (b rectangle))
  (format t "Circle-rectangle collision~%"))

(defmethod collide ((a rectangle) (b rectangle))
  (format t "Rectangle-rectangle collision~%"))
```

Here, the method actually invoked by `(collide obj1 obj2)` depends on the runtime classes of *both* `obj1` and `obj2` together, resolved by CLOS's method-combination and specificity rules — a genuinely different dispatch model from anything available by default in single-dispatch languages.

### The Condition System

Common Lisp's error-handling facility, the **condition system**, was introduced earlier in this sequence under [[continuation-and-resumption-models]] as the primary real-world example of resumption-model exception handling, and it is worth situating here as one of Common Lisp's most distinctive and influential language-level contributions overall — a considerably more general facility than ordinary exception handling, since **conditions** are not restricted to representing errors at all; they can represent warnings, informational notifications, or any other noteworthy program occurrence a programmer wishes to define, each potentially resumable via an associated **restart**.

```lisp
(define-condition low-disk-space (warning)
  ((remaining-mb :initarg :remaining-mb :reader low-disk-space-remaining)))

(defun check-disk-space (remaining)
  (when (< remaining 100)
    (warn 'low-disk-space :remaining-mb remaining)))
```

`warn` here signals a condition that, by default, prints a message and continues execution (rather than unwinding, as `error` would) — reflecting the condition system's broader scope beyond just fatal, must-be-handled error scenarios.

### The Macro System and Compile-Time Code Generation

Common Lisp inherits and extends LISP's homoiconicity into an extensive, unrestricted macro system via `defmacro`, allowing arbitrary Lisp code to run at macro-expansion time to generate the code that will actually be compiled and executed. Unlike Scheme's `syntax-rules`, which is pattern-based and hygienic by design, Common Lisp's `defmacro` is unrestricted (a macro body is just ordinary Lisp code manipulating list structures) and, by default, **not** hygienic, placing the burden of avoiding accidental variable capture onto the macro author.

```lisp
(defmacro my-unless (condition &body body)
  `(if (not ,condition)
       (progn ,@body)))

(my-unless (> 3 5)
  (format t "3 is not greater than 5~%"))
```

The backtick (`` ` ``) introduces a template, with `,` (unquote) marking positions where an actual runtime value or expression should be spliced in, and `,@` (unquote-splicing) inserting the elements of a list directly rather than the list itself — this quasiquotation syntax is the standard mechanism by which Common Lisp macros construct the code they will expand into. [Inference] Because `defmacro` is unrestricted and non-hygienic, it is considerably more powerful (and more dangerous, in terms of possible variable-capture bugs) than Scheme's `syntax-rules`, which is a direct reflection of the two dialects' broader design-philosophy divergence — Common Lisp generally favors giving the programmer maximal power and trusting their discipline, where Scheme favors constraining power in exchange for stronger, more automatically enforced correctness guarantees.

### The Large, Comprehensive Standard Library

Common Lisp's standard specifies an unusually extensive built-in library relative to other languages of its era, including a highly capable `format` function (a text-formatting mini-language embedded as format-directive strings, comparable in spirit to `printf` but substantially more expressive), a comprehensive set of sequence-manipulation functions (`mapcar`, `reduce`, `sort`, `remove-if`, and many more), and native support for structured data types beyond ordinary cons-cell lists, including arrays, hash tables, and structures (`defstruct`).

```lisp
(format t "~a has ~d items worth $~,2f total~%" "cart" 5 49.999)
; prints: cart has 5 items worth $50.00 total
```

[Inference] This comprehensiveness is frequently cited as a direct consequence of Common Lisp's design mandate — unifying and standardizing existing, independently evolved LISP dialects rather than designing a new language from first principles meant incorporating the union of useful features already present across those dialects, naturally yielding a larger and more heterogeneous standard library than a from-scratch, minimalist design would produce.

### The Read-Eval-Print Loop (REPL) and Interactive Development

Common Lisp implementations (and LISP dialects generally, including Scheme) are strongly associated with **interactive, incremental development** via a Read-Eval-Print Loop, where individual expressions, function definitions, or even entire subsystems can be redefined and tested live, within a running program image, without a full compile-and-restart cycle.

```mermaid
flowchart LR
    A[Read an expression from the user] --> B[Evaluate it in the live running environment]
    B --> C[Print the resulting value]
    C --> A
```

[Inference] This REPL-centric, image-based development style is often credited, in retrospectives on LISP-family languages, as a major influence on later interactive development environments and "live coding" workflows in other languages and ecosystems, since it demonstrated — well before dynamic languages like Python or Ruby popularized interactive interpreters as a mainstream convenience — that a compiled, statically-oriented-feeling language could still support fully live, incremental redefinition of running code.

### Common Lisp's Multi-Paradigm Character

Although rooted in LISP's functional lineage, Common Lisp does not restrict programmers to a functional style; it freely supports imperative programming (via `setq`, `loop`, and other iteration constructs), object-oriented programming (via CLOS), and functional programming (via first-class functions, `mapcar`, `reduce`, and recursion) within the same language, leaving the choice of paradigm largely to the programmer for any given piece of code.

```lisp
; Imperative style
(defun sum-imperative (lst)
  (let ((total 0))
    (dolist (x lst) (incf total x))
    total))

; Functional style
(defun sum-functional (lst)
  (reduce #'+ lst))
```

### Comparison: Common Lisp vs. Scheme (Extended)

| Feature | Common Lisp | Scheme |
| --- | --- | --- |
| Namespace model | Lisp-2 (separate function/variable namespaces) | Lisp-1 (single shared namespace) |
| Object system | CLOS: generic functions, multiple dispatch | No standard built-in object system |
| Macro hygiene | Non-hygienic (`defmacro`) by default | Hygienic (`syntax-rules`) standard |
| Error handling | Condition system (resumable) | Exceptions via `guard`/`raise` (R7RS), non-resumable |
| Tail calls | Not guaranteed by the standard | Guaranteed by the standard |
| Design philosophy | Comprehensive, practical, multi-paradigm | Minimalist, theoretically clean |
| Standardization | ANSI standard (X3.226-1994) | RnRS reports |

### Illustration — Single Dispatch vs. Multiple Dispatch (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 320" font-family="sans-serif">
<text x="410" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Single Dispatch vs CLOS Multiple Dispatch (svg_diagram)</text>

<text x="200" y="65" text-anchor="middle" font-size="14" font-weight="bold" fill="`#1a1a1a`">Single Dispatch (Java-style)</text>

<rect x="80" y="85" width="240" height="35" fill="`#4a90d9`" rx="4" />

<text x="200" y="107" text-anchor="middle" font-size="10" fill="white">obj.area() — dispatches on obj's class ONLY</text>

<rect x="80" y="140" width="110" height="30" fill="#eee" stroke="#999" rx="4" />

<text x="135" y="160" text-anchor="middle" font-size="9" fill="#333">Circle.area()</text>

<rect x="210" y="140" width="110" height="30" fill="#eee" stroke="#999" rx="4" />

<text x="265" y="160" text-anchor="middle" font-size="9" fill="#333">Rectangle.area()</text>

<text x="200" y="195" text-anchor="middle" font-size="10" fill="#555">Method lives inside the class</text>

<text x="620" y="65" text-anchor="middle" font-size="14" font-weight="bold" fill="`#1a1a1a`">CLOS Multiple Dispatch</text>

<rect x="500" y="85" width="240" height="35" fill="`#7a9e5c`" rx="4" />

<text x="620" y="107" text-anchor="middle" font-size="9" fill="white">(collide a b) — dispatches on BOTH a and b</text>

<rect x="480" y="140" width="90" height="30" fill="#eee" stroke="#999" rx="4" />

<text x="525" y="160" text-anchor="middle" font-size="8" fill="#333">circle+circle</text>

<rect x="580" y="140" width="90" height="30" fill="#eee" stroke="#999" rx="4" />

<text x="625" y="160" text-anchor="middle" font-size="8" fill="#333">circle+rect</text>

<rect x="680" y="140" width="90" height="30" fill="#eee" stroke="#999" rx="4" />

<text x="725" y="160" text-anchor="middle" font-size="8" fill="#333">rect+rect</text>

<text x="620" y="195" text-anchor="middle" font-size="10" fill="#555">Methods live independently of any single class</text>

<rect x="60" y="235" width="700" height="65" fill="#f5f5f5" stroke="#ccc" rx="6" />
<text x="80" y="258" font-size="11" fill="#333">Single dispatch asks "what class is the receiver?" — one answer determines the method.</text>
<text x="80" y="278" font-size="11" fill="#333">Multiple dispatch asks the same question of every relevant argument at once.</text>
</svg>

### Related Topics

- CLOS method combination, `:before`/`:after`/`:around` methods, and multiple dispatch resolution rules
- The condition system in depth: `handler-bind`, `restart-case`, `invoke-restart`
- Quasiquotation and macro-writing idioms in unrestricted, non-hygienic macro systems
- `format` directive syntax as a text-formatting mini-language
- Image-based development and the historical LISP Machine environment
- Comparing Common Lisp to other multi-paradigm languages (Python, Scala) in paradigm flexibility
- The historical unification process: MacLisp, Interlisp, and Common Lisp's standardization effort