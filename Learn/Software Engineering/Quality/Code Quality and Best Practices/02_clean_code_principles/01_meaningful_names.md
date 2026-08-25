## Meaningful Names


Naming is the most ubiquitous activity in software development. Names appear in variables, functions, arguments, classes, and packages. Because names are the primary documentation of intent, they must be rigorously selected to communicate specific meaning without ambiguity.

**Key Points**

- **Intention-Revealing Names:** A variable, function, or class name should answer all the big questions: why it exists, what it does, and how it is used. If a name requires a comment, the name does not reveal its intent.
    
    - _Poor:_ `int d; // elapsed time in days`
        
    - _Good:_ `int elapsedTimeInDays;`
        
- **Avoid Disinformation:** Do not leave false clues that obscure the meaning of code. Avoid words whose entrenched meanings vary from the intended meaning. For example, do not refer to a grouping of accounts as an `accountList` unless it is actually a `List` data structure. `accountGroup` or `bunchOfAccounts` is better.
    
- **Make Meaningful Distinctions:** Programmers create problems for themselves when they write code solely to satisfy a compiler or interpreter. For example, `ProductInfo` or `ProductData` are indistinct names if `Product` already exists. `Info` and `Data` are noise words like `a`, `an`, and `the`.
    
- **Use Pronounceable Names:** Humans are good at words. A significant part of our brains is dedicated to the concept of words. If you can't pronounce it, you can't discuss it without sounding like an idiot.
    
    - _Poor:_ `class DtaRcrd102 { private Date genymdhms; }`
        
    - _Good:_ `class Customer { private Date generationTimestamp; }`
        
- **Use Searchable Names:** Single-letter names and numeric constants have a particular problem: they are not easy to locate across a body of text. `MAX_CLASSES_PER_STUDENT` is easily searchable; the number `7` is not. Single-letter names can only be used as local variables inside short methods (e.g., `i` in a loop).
    
- **Avoid Encodings:** Hungarian notation, member prefixes (e.g., `m_`), and interface prefixes (e.g., `IShape`) are unnecessary in modern IDEs. They add mental burden and clutter.
    
- **Class Names:** Classes and objects should have noun or noun phrase names like `Customer`, `WikiPage`, `Account`, and `AddressParser`. Avoid words like `Manager`, `Processor`, `Data`, or `Info` in the name of a class. A class name should not be a verb.
    
- **Method Names:** Methods should have verb or verb phrase names like `postPayment`, `deletePage`, or `save`. Accessors, mutators, and predicates should be named for their value and prefixed with `get`, `set`, and `is` according to the javabean standard.
    

**Example**

**Bad Practice:**

Java

```
public List<int[]> getThem() {
  List<int[]> list1 = new ArrayList<int[]>();
  for (int[] x : theList)
    if (x[0] == 4)
      list1.add(x);
  return list1;
}
```

**Refactored for Meaningful Names:**

Java

```
public List<Cell> getFlaggedCells() {
  List<Cell> flaggedCells = new ArrayList<Cell>();
  for (Cell cell : gameBoard)
    if (cell.isFlagged())
      flaggedCells.add(cell);
  return flaggedCells;
}
```

