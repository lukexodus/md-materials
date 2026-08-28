## Introduction to Logic and Logic Programming


### Overview

Logic programming is a declarative programming paradigm built on formal logic, in which programs consist of facts and rules expressed as logical statements, and computation is performed through logical inference rather than sequential state mutation or function application. Instead of specifying *how* to compute a result, a logic program specifies *what* is true, and a reasoning engine (typically implementing a resolution or unification procedure) derives answers by searching for values that satisfy the stated logical relationships. Prolog is the most widely known and historically significant logic programming language.

### Foundations in Formal Logic

Logic programming derives from first-order predicate logic, particularly the subset known as Horn clause logic, which restricts logical statements to a computationally tractable form.

$$\text{Horn clause: } A \leftarrow B_1 \land B_2 \land \dots \land B_n$$

This reads as: "A is true if $B_1$ and $B_2$ and ... and $B_n$ are all true." $A$ is the head (the conclusion), and $B_1, \dots, B_n$ form the body (the conditions).

**Key Points**

- A fact is a Horn clause with no body (always true): $A \leftarrow \text{true}$
- A rule is a Horn clause with both head and body
- A query (goal) asks whether some statement can be derived as true from the known facts and rules
- Logic programming is grounded in the theoretical work on resolution theorem proving (Robinson, 1965) and Horn clause logic (Alfred Horn)

[Unverified] Precise historical attribution and dates for foundational theoretical contributions are drawn from standard computer science history references; some details of priority and influence are debated among historians of the field.

### Facts, Rules, and Queries in Prolog

Prolog is the canonical logic programming language, developed in the early 1970s by Alain Colmerauer and Robert Kowalski's research collaborators.

```prolog
% Facts
parent(tom, bob).
parent(tom, liz).
parent(bob, ann).
parent(bob, pat).

% Rule: X is a grandparent of Y if X is a parent of some Z, and Z is a parent of Y
grandparent(X, Y) :- parent(X, Z), parent(Z, Y).

% Query
?- grandparent(tom, ann).
% true.

?- grandparent(tom, Who).
% Who = ann ;
% Who = pat.
```

In this example, `parent/2` facts state raw relationships. The `grandparent/2` rule defines a derived relationship in terms of existing ones. The query `grandparent(tom, Who)` asks the system to find all bindings of `Who` that make the statement true, and the engine searches the fact/rule database to answer.

### Unification

Unification is the core mechanism by which the logic engine matches a query against facts and rule heads, binding variables as needed to make both sides syntactically identical.

**Key Points**

- Two terms unify if there exists a substitution of variables that makes them identical
- Constants unify only with themselves or with unbound variables
- Unification can bind multiple variables simultaneously and is applied recursively through compound terms
- Occurs-check (verifying a variable does not appear within the term it is being bound to, to avoid infinite structures) is often skipped by default in Prolog implementations for performance reasons [Inference — this is documented behavior in classic Prolog implementations such as SWI-Prolog's default mode; behavior may differ across specific engines or configuration flags]

```prolog
% Unification examples
?- likes(mary, X) = likes(mary, wine).
% X = wine.

?- point(X, Y) = point(3, 4).
% X = 3, Y = 4.

?- foo(X) = bar(X).
% false.  (different functors cannot unify)
```

### Resolution and the Search Process

When a query is posed, the Prolog engine attempts to prove it using SLD resolution (Selective Linear Definite clause resolution), searching the clause database depth-first and using backtracking when a chosen path fails to produce a solution.

```mermaid
flowchart TD
    A[Query: grandparent(tom, Who)] --> B[Match rule: grandparent(X,Y) :- parent(X,Z), parent(Z,Y)]
    B --> C[Bind X = tom, search parent(tom, Z)]
    C --> D[Z = bob via parent(tom, bob)]
    D --> E[Search parent(bob, Y)]
    E --> F[Y = ann via parent(bob, ann)]
    F --> G[Solution: Who = ann]
    G --> H[Backtrack on request for more solutions]
    H --> I[Y = pat via parent(bob, pat)]
    I --> J[Solution: Who = pat]
```

**Key Points**

- Depth-first search means Prolog explores one branch of possibilities fully before backtracking to try alternatives
- Backtracking occurs automatically when a goal fails or when the user/program requests additional solutions
- The order of facts and rules in the source file affects the order in which solutions are found, since resolution proceeds top-to-bottom by default in standard Prolog implementations [Inference — consistent with documented SLD resolution strategy in Prolog's ISO standard and common implementations; some engines offer alternative search strategies as extensions]

### Recursion in Logic Programs

Since logic programming has no imperative loops, recursive rules are the standard mechanism for iteration over structured or repeated data.

```prolog
% Recursive definition of list length
list_length([], 0).
list_length([_|Tail], N) :- list_length(Tail, N1), N is N1 + 1.

?- list_length([a, b, c], N).
% N = 3.
```

```prolog
% Recursive definition of ancestor (transitive closure of parent)
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).
```

The `ancestor/2` predicate demonstrates transitive closure: an ancestor is either a direct parent, or a parent of some other ancestor, recursively.

### Negation and the Closed-World Assumption

Prolog implements negation as negation-as-failure: a goal `\+ G` succeeds if `G` cannot be proven true given the current facts and rules.

```prolog
% Negation as failure
single(X) :- \+ married(X).
```

**Key Points**

- This differs from classical logical negation; `\+ G` succeeding means "G could not be proven," not "G is false" in an absolute sense
- Prolog operates under the closed-world assumption: anything not derivable from the known facts and rules is treated as false
- This can produce results that differ from classical logic when the fact database is incomplete, since absence of evidence is treated as evidence of absence within the system

### Arithmetic and the `is` Operator

Because Prolog terms are not automatically evaluated as arithmetic expressions, the `is` operator explicitly triggers evaluation.

```prolog
?- X = 2 + 3.
% X = 2+3.   (X is bound to the unevaluated term, not 5)

?- X is 2 + 3.
% X = 5.     (is/2 forces arithmetic evaluation)
```

This distinction reflects the underlying philosophy that Prolog terms are symbolic structures by default; evaluation is an explicit operation, not implicit as in imperative or functional languages.

### Cut and Controlling Backtracking

The cut operator (`!`) commits the engine to choices made so far in a clause, pruning alternative backtracking paths.

```prolog
max(X, Y, X) :- X >= Y, !.
max(_, Y, Y).
```

**Key Points**

- Cut improves efficiency by avoiding unnecessary search but can change program semantics if used carelessly, since it silently discards alternative solutions
- Overuse of cut is widely considered poor practice, as it can make programs harder to reason about and less purely declarative [Inference — this is a broadly repeated stylistic guideline across Prolog textbooks and community conventions, though it is a matter of programming style rather than a formally provable claim]
- "Green cuts" (used purely for efficiency without changing which solutions are found) are generally considered more acceptable than "red cuts" (which alter program semantics)

### Illustration: Logic Programming Execution Model

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
<text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Logic Programming Execution Model (svg_diagram)</text>
<rect x="40" y="60" width="180" height="60" rx="8" fill="#ffe8cc" stroke="#c05621" stroke-width="2" />
<text x="130" y="85" text-anchor="middle" font-size="13" font-weight="bold" fill="#7c2d12">Facts</text>
<text x="130" y="105" text-anchor="middle" font-size="11" fill="#7c2d12">parent(tom, bob).</text>
<rect x="260" y="60" width="180" height="60" rx="8" fill="#e0d4fa" stroke="#6b46c1" stroke-width="2" />
<text x="350" y="85" text-anchor="middle" font-size="13" font-weight="bold" fill="#3c1a78">Rules</text>
<text x="350" y="105" text-anchor="middle" font-size="10" fill="#3c1a78">grandparent(X,Y):-...</text>
<rect x="480" y="60" width="180" height="60" rx="8" fill="#cfe8ff" stroke="#2b6cb0" stroke-width="2" />
<text x="570" y="85" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a3d5c">Query/Goal</text>
<text x="570" y="105" text-anchor="middle" font-size="10" fill="#1a3d5c">?- grandparent(tom,W)</text>
<line x1="130" y1="120" x2="330" y2="190" stroke="#333" stroke-width="1.5" marker-end="url(#a3)" />
<line x1="350" y1="120" x2="350" y2="190" stroke="#333" stroke-width="1.5" marker-end="url(#a3)" />
<line x1="570" y1="120" x2="380" y2="190" stroke="#333" stroke-width="1.5" marker-end="url(#a3)" />
<rect x="230" y="190" width="240" height="60" rx="8" fill="#d6f5d6" stroke="#2f855a" stroke-width="2" />
<text x="350" y="215" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a4d2e">Unification Engine</text>
<text x="350" y="235" text-anchor="middle" font-size="11" fill="#1a4d2e">SLD Resolution + Backtracking</text>
<line x1="350" y1="250" x2="350" y2="290" stroke="#333" stroke-width="1.5" marker-end="url(#a3)" />
<rect x="230" y="290" width="240" height="50" rx="8" fill="#fde8e8" stroke="#c53030" stroke-width="2" />
<text x="350" y="320" text-anchor="middle" font-size="13" font-weight="bold" fill="#742a2a">Bindings / Solutions</text>
</svg>

### Comparative Table: Logic Programming vs. Other Paradigms

| Dimension | Logic Programming | Imperative | Functional |
| --- | --- | --- | --- |
| Core unit | Facts/rules (clauses) | Statements | Expressions |
| Computation model | Logical inference (resolution) | State mutation | Function evaluation |
| Control flow | Automatic (search + backtracking) | Explicit (loops, conditionals) | Explicit (recursion, combinators) |
| Program answers "what" or "how" | What is true | How to compute | How to transform |
| Non-determinism | Built-in, via backtracking | Not built-in | Not built-in (typically) |
| Representative language | Prolog | C, Pascal | Haskell, Scheme |

### Applications of Logic Programming

**Key Points**

- Expert systems and knowledge representation, where domain knowledge is naturally expressed as facts and inference rules
- Natural language processing prototypes, historically significant in early computational linguistics research
- Constraint logic programming (CLP) extensions, used in scheduling, resource allocation, and combinatorial optimization problems
- Automated theorem proving and formal verification tooling
- Datalog, a restricted subset of Prolog without complex terms or side effects, is used in deductive databases and, more recently, in program analysis and security tools

[Inference] The stated application domains reflect commonly cited use cases in academic and industry literature on logic programming; the relative prevalence of each use case in current industry practice is not independently verified here and may have shifted over time.

### Limitations and Criticisms

**Key Points**

- Performance can be difficult to predict or control since the search strategy is largely automatic, and poorly structured clause ordering can lead to inefficient or non-terminating searches
- Side-effect-based I/O (as in most practical Prolog programs) sits awkwardly with the purely declarative ideal, similar to the tension functional languages face with I/O
- The cut operator, while practically necessary for performance, undermines the purely declarative reading of programs when used to alter logical outcomes
- Steep conceptual learning curve for programmers accustomed to imperative or functional paradigms, due to the shift toward specifying relationships rather than procedures

### Example: A Small Complete Program

```prolog
% Family relationships knowledge base
parent(john, mary).
parent(john, peter).
parent(mary, susan).
parent(peter, tom).

sibling(X, Y) :- parent(Z, X), parent(Z, Y), X \= Y.

ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).

% Queries and expected results:
% ?- sibling(mary, peter).       -> true.
% ?- ancestor(john, tom).        -> true.
% ?- ancestor(X, susan).         -> X = mary ; X = john.
```

### Related Topics

- Prolog syntax and built-in predicates in depth
- Constraint logic programming (CLP(FD), CLP(R))
- Datalog and its role in deductive databases and static analysis
- Answer Set Programming (ASP) as a related declarative paradigm
- SLD resolution and theorem-proving algorithms in detail
- Minikanren and embedding logic programming in other host languages
- Comparing logic programming to SQL's declarative query model
- Formal semantics of negation-as-failure vs. classical negation