## Functions should be small


The first rule of functions is that they should be small. The second rule of functions is that they should be smaller than that. Functions are the verbs of a system, and smaller functions lead to better composition, readability, and testability.

**Key Points**

- **Lines of Code Limits:** While there is no hard enforcement, a function should ideally barely be 20 lines long. Historical constraints suggested functions should fit on a screen (approx. 60 lines), but modern clean code standards push for much tighter limits.
    
- **Blocks and Indenting:** The blocks within `if`, `else`, `while`, and similar statements should be one line long. That line should probably be a function call. This keeps the enclosing function small and adds documentary value because the function called within the block can have a nicely descriptive name. Consequently, the maximum indentation level of a function should not be greater than one or two.
    
- **Do One Thing (Single Responsibility):** Functions should do one thing. They should do it well. They should do it only. If a function does more than one of the steps in a process (e.g., parses input, creates an object, AND saves to the database), it is doing too much.
    
    - _Identification Strategy:_ If you can extract another function from the original function with a name that is not merely a restatement of its implementation, the original function is doing too much.
        
- **One Level of Abstraction per Function:** To make sure our functions are doing "one thing," we need to make sure that the statements within the function are all at the same level of abstraction. Mixing levels of abstraction is confusing.
    
    - _High Level:_ `getHtml()`
        
    - _Intermediate Level:_ `String path = pagePathName`
        
    - _Low Level:_ `.append("\n")`
        
- **The Step-Down Rule:** Code should be read like a top-down narrative. We want every function to be followed by those at the next level of abstraction so that we can read the program, descending one level of abstraction at a time as we read down the list of functions.
    
- **Switch Statements:** It is hard to make a small switch statement. Switch statements invariably do N things. They should be buried low in an abstract factory and never repeated. Polymorphism is usually the preferred replacement for switch statements.
    

**Example**

**Bad Practice (Too Large, Mixed Abstraction):**

Java

```
public void renderPage(StringBuffer html, PageData pageData, boolean isSuite) {
    if (isSuite) {
        html.append(PageData.TEAR_DOWN_SUITE);
    }
    WikiPage wikiPage = pageData.getWikiPage();
    StringBuffer buffer = new StringBuffer();
    if (pageData.hasAttribute("Test")) {
        if (isSuite)
            buffer.append("include suite setup");
        buffer.append("include setup");
    }
    buffer.append(pageData.getContent());
    if (pageData.hasAttribute("Test")) {
        buffer.append("include teardown");
        if (isSuite)
            buffer.append("include suite teardown");
    }
    pageData.setContent(buffer.toString());
    html.append(pageData.getHtml());
}
```

**Refactored (Small, Single Level of Abstraction):**

Java

```
public void renderPage(StringBuffer html, PageData pageData, boolean isSuite) {
    if (isTestPage(pageData))
        includeSetupAndTeardownPages(pageData, isSuite);
    html.append(pageData.getHtml());
}
```

