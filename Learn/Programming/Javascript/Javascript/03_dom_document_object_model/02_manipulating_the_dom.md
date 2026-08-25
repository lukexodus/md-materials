## **Manipulating the DOM**


#### **Changing Content**

1. **Modify Text Content**:
    
    ```javascript
    const header = document.querySelector("h1");
    header.textContent = "New Heading";
    ```
    
2. **Modify Inner HTML**:
    
    ```javascript
    const paragraph = document.querySelector("p");
    paragraph.innerHTML = "<strong>Bold Text</strong>";
    ```
    

---

#### **DOM Attributes**

DOM (Document Object Model) elements are the nodes representing HTML elements in a web page. Each element can have **attributes**, which provide additional information or behavior. These attributes are accessible and manipulatable via JavaScript.

---

##### **Attributes Overview**

1. **Standard Attributes**: Defined by HTML specifications and used commonly (e.g., `id`, `class`, `src`, `alt`).
2. **Custom Data Attributes**: Prefixed with `data-`, used to store custom data.
3. **Boolean Attributes**: Represent properties that are either true or false (e.g., `checked`, `disabled`).
4. **Event Attributes**: Used to define inline event listeners (e.g., `onclick`, `onmouseover`).

---
##### **Accessing Attributes**

###### Using JavaScript:

1. **`getAttribute(attributeName)`**: Gets the value of a specified attribute.
2. **`setAttribute(attributeName, value)`**: Sets a value for a specified attribute.
3. **`hasAttribute(attributeName)`**: Checks if an attribute exists.
4. **`removeAttribute(attributeName)`**: Removes a specified attribute.

Example:

```javascript
let element = document.querySelector('img');

// Get the 'src' attribute
console.log(element.getAttribute('src'));

// Set a new 'alt' attribute
element.setAttribute('alt', 'A descriptive image');

// Check if 'id' attribute exists
console.log(element.hasAttribute('id'));

// Remove the 'title' attribute
element.removeAttribute('title');
```

---

##### **Common Attributes**

1. **Global Attributes**: Usable on any HTML element.
    - `id`: Unique identifier for the element.
    - `class`: Specifies one or more class names for styling.
    - `innerHTML`: The HTML content inside an element.
    - `outerHTML`: The HTML content of the element, including the element itself.
    - `textContent`: The text inside the element (ignores HTML tags).
    - `title`: Provides additional information (e.g., a tooltip).
    - `style`: Inline CSS styles for the element.
    - `hidden`: Determines whether the element is hidden (`true`) or visible (`false`).
    - `data-*`: Custom data attributes (e.g., `data-user-id="1234"`).
2. **Input-Specific Attributes**:
    - `type`: Specifies the type of input (e.g., `text`, `email`, `password`).
    - `value`: Default value for the input field.
    - `placeholder`: Text shown when the input is empty.
    - `checked`: Boolean attribute for radio buttons/checkboxes.
    - `disabled`: Prevents user interaction with the element.
    - `files`: Represents the list of selected files in a file input.
3. **Media-Specific Attributes**:
    - `src`: Specifies the source of an image, video, or audio.
    - `alt`: Alternative text for an image.
    - `autoplay`: Boolean attribute for automatic media playback.
    - `controls`: Boolean indicating whether the media player has controls.
    - `volume`: Represents the volume level (0 to 1).
4. **Anchor-Specific Attributes**:
    - `href`: Specifies the URL the link points to.
    - `target`: Defines how the link is opened (e.g., `_blank` for new tab).
5. **Dimension and Position Properties**: 
	- **`offsetHeight` and `offsetWidth`**: The height and width of an element (including borders and padding).
	- **`clientHeight` and `clientWidth`**: The height and width of an element's content (excluding borders).
	- **`scrollHeight` and `scrollWidth`**: The total height/width of an element, including content that overflows.
	- **`getBoundingClientRect()`**: Provides the element's size and position relative to the viewport.
		```javascript
		let rect = element.getBoundingClientRect();
		console.log(rect.top, rect.left, rect.width, rect.height);
		```


---

##### **Custom Data Attributes**

Custom attributes start with `data-` and are designed for storing custom data in an element. They are accessible via JavaScript using `dataset`.

Example:

```html
<div data-user-id="1234" data-user-role="admin">John Doe</div>
```

Accessing via JavaScript:

```javascript
let div = document.querySelector('div');

// Accessing custom data attributes
console.log(div.dataset.userId);    // "1234"
console.log(div.dataset.userRole); // "admin"
```

---

##### **Property vs. Attribute**

Attributes and properties are related but not identical:

- **Attributes** are part of the HTML and define the initial state of an element.
- **Properties** are part of the DOM object and represent the current state.

Example:

```javascript
let input = document.querySelector('input');
input.setAttribute('value', 'Hello'); // Sets the initial value
console.log(input.value);             // Outputs: Hello

input.value = 'World';                // Updates the value property
console.log(input.getAttribute('value')); // Outputs: Hello (unchanged)
```

---

##### **Boolean Attributes**

Boolean attributes are either present or absent; their mere presence means "true."

Examples:

```html
<input type="checkbox" checked>
<button disabled>Click me</button>
```

Checking with JavaScript:

```javascript
let checkbox = document.querySelector('input');
console.log(checkbox.hasAttribute('checked')); // true
console.log(checkbox.checked);                 // true
```

---

##### **Attributes vs. Dataset**

|**Aspect**|**Attributes**|**Dataset**|
|---|---|---|
|**Definition**|HTML-defined attributes (e.g., `src`, `id`)|Custom attributes prefixed with `data-`.|
|**Access Method**|`getAttribute`, `setAttribute`|`dataset` property in JavaScript.|
|**Use Case**|Built-in element attributes.|Storing custom data.|


---

#### **Changing Styles**

- Modify styles using the `style` property:
    
    ```javascript
    const button = document.querySelector("button");
    button.style.backgroundColor = "blue";
    button.style.fontSize = "20px";
    ```


---

#### **Adding and Removing Classes**

- Use `classList` for dynamic class manipulation:
    
    ```javascript
    const element = document.querySelector("div");
    element.classList.add("new-class");
    element.classList.remove("old-class");
    element.classList.toggle("active-class");
    ```

#### DOM Element Methods

DOM element methods allow us to manipulate and interact with elements in the document dynamically. These methods enable actions like finding, creating, modifying, or removing elements and managing their content, style, or events.

---

##### **Selecting Elements**

1. **`querySelector(selector)`**  
    Selects the first element matching the CSS selector.
    
    ```javascript
    const element = document.querySelector(".className");
    ```
    
2. **`querySelectorAll(selector)`**  
    Selects all elements matching the CSS selector and returns a static `NodeList`.
    
    ```javascript
    const elements = document.querySelectorAll(".className");
    ```
    
3. **`getElementById(id)`**  
    Selects an element by its `id` attribute.
    
    ```javascript
    const element = document.getElementById("myId");
    ```
    
4. **`getElementsByClassName(className)`**  
    Selects elements by class name, returning a live HTMLCollection.
    
    ```javascript
    const elements = document.getElementsByClassName("myClass");
    ```
    
5. **`getElementsByTagName(tagName)`**  
    Selects elements by their tag name (e.g., `div`, `p`).
    
    ```javascript
    const elements = document.getElementsByTagName("div");
    ```
    

---

##### **Creating and Cloning Elements**

1. **`createElement(tagName)`**  
    Creates a new DOM element.
    
    ```javascript
    const newDiv = document.createElement("div");
    ```
    
2. **`cloneNode(deep)`**  
    Creates a copy of the element. Pass `true` to copy all child nodes as well.
    
    ```javascript
    const clone = element.cloneNode(true);
    ```
    

---

##### **Inserting and Removing Elements**

1. **`appendChild(node)`**  
    Appends a node as the last child of the element.
    
    ```javascript
    const parent = document.querySelector(".parent");
    parent.appendChild(newDiv);
    ```
    
2. **`insertBefore(newNode, referenceNode)`**  
    Inserts a node before the specified reference node.
    
    ```javascript
    parent.insertBefore(newDiv, referenceChild);
    ```
    
3. **`removeChild(child)`**  
    Removes a specified child node.
    
    ```javascript
    parent.removeChild(childNode);
    ```
    
4. **`replaceChild(newNode, oldNode)`**  
    Replaces a child node with a new node.
    
    ```javascript
    parent.replaceChild(newDiv, oldChild);
    ```
    
5. **`append(...nodesOrStrings)`**  
    Adds one or more nodes or strings as the last children.
    
    ```javascript
    parent.append("Hello", anotherElement);
    ```
    
6. **`prepend(...nodesOrStrings)`**  
    Adds one or more nodes or strings as the first children.
    
    ```javascript
    parent.prepend("First", anotherElement);
    ```
    
7. **`remove()`**  
    Removes the element from its parent.
    
    ```javascript
    element.remove();
    ```
    
8. **`replaceWith(...nodesOrStrings)`**  
    Replaces the element with specified nodes or strings.
    
    ```javascript
    element.replaceWith(newElement);
    ```
    

---

##### **Content Manipulation**

1. **`innerHTML`**  
    Sets or gets the HTML content of an element.
    
    ```javascript
    element.innerHTML = "<strong>Updated content</strong>";
    ```
    
2. **`textContent`**  
    Sets or gets the text content of an element (ignores HTML tags).
    
    ```javascript
    element.textContent = "Plain text";
    ```
    
3. **`innerText`**  
    Similar to `textContent`, but accounts for CSS visibility.
    
    ```javascript
    element.innerText = "Visible text only";
    ```
    
4. **`insertAdjacentHTML(position, text)`**  
    Inserts HTML at a specified position relative to the element:
    
    - `beforebegin` (before the element itself)
    - `afterbegin` (inside, before first child)
    - `beforeend` (inside, after last child)
    - `afterend` (after the element itself)
    
    ```javascript
    element.insertAdjacentHTML("beforeend", "<p>New content</p>");
    ```
    
5. **`insertAdjacentElement(position, element)`**  
    Similar to `insertAdjacentHTML`, but inserts an actual element.
    
    ```javascript
    element.insertAdjacentElement("afterend", newDiv);
    ```
    
6. **`insertAdjacentText(position, text)`**  
    Inserts plain text at the specified position.
    
    ```javascript
    element.insertAdjacentText("beforebegin", "Hello World");
    ```


---

##### **CSS and Styling**

1. **`style`**  
    Modifies inline CSS styles.
    
    ```javascript
    element.style.color = "blue";
    element.style.fontSize = "20px";
    ```
    
2. **`classList` Methods**
    - `add(className)`: Adds a class to the element.
    - `remove(className)`: Removes a class from the element.
    - `toggle(className)`: Toggles the presence of a class.
    - `contains(className)`: Checks if the element has the specified class.
    
    ```javascript
    element.classList.add("active");
    element.classList.toggle("hidden");
    ```

---

##### **Event Handling**

1. **`addEventListener(event, handler, options)`**  
    Attaches an event listener to the element.
    
    ```javascript
    element.addEventListener("click", () => alert("Clicked!"));
    ```
    
2. **`removeEventListener(event, handler, options)`**  
    Removes an event listener from the element.
    
    ```javascript
    element.removeEventListener("click", clickHandler);
    ```

---

##### **Dimension and Position**

1. **`getBoundingClientRect()`**  
    Returns the size and position of the element relative to the viewport.
    
    ```javascript
    const rect = element.getBoundingClientRect();
    console.log(rect.top, rect.left, rect.width, rect.height);
    ```
    
2. **`scrollIntoView(options)`**  
    Scrolls the element into view.
    
    ```javascript
    element.scrollIntoView({ behavior: "smooth", block: "center" });
    ```

---

##### **Other Useful Methods**

1. **`matches(selector)`**  
    Checks if the element matches a given CSS selector.
    
    ```javascript
    if (element.matches(".active")) {
        console.log("Element is active");
    }
    ```
    
2. **`closest(selector)`**  
    Finds the nearest ancestor that matches the selector.
    
    ```javascript
    const container = element.closest(".container");
    ```
    
3. **`focus()` and `blur()`**  
    Focuses or removes focus from an element.
    
    ```javascript
    input.focus();
    ```
    

##### **Advanced DOM Manipulation**

1. **`normalize()`**  
    Combines adjacent text nodes and removes empty text nodes inside the element.
    
    ```javascript
    element.normalize();
    ```
    
2. **`isEqualNode(node)`**  
    Compares two nodes to determine if they are equal in structure and content.
    
    ```javascript
    console.log(element.isEqualNode(anotherElement)); // true or false
    ```
    
3. **`isSameNode(node)`**  
    Checks if two nodes reference the same object.
    
    ```javascript
    console.log(element.isSameNode(anotherElement)); // true or false
    ```
    
4. **`contains(node)`**  
    Checks if a node is a descendant of the element.
    
    ```javascript
    console.log(element.contains(childElement)); // true or false
    ```
    
5. **`compareDocumentPosition(node)`**  
    Returns a bitmask showing the relationship between two nodes (e.g., preceding, following).
    
    ```javascript
    const position = element.compareDocumentPosition(anotherElement);
    ```
    

---

##### **Custom Data and Attributes**

6. **`dataset`**  
    Provides access to all custom `data-*` attributes as a DOMStringMap.
    
    ```javascript
    console.log(element.dataset.role); // Accesses 'data-role' attribute
    element.dataset.role = "admin"; // Sets 'data-role' to 'admin'
    ```
    

---

##### **Shadow DOM**

7. **`attachShadow(options)`**  
    Creates a shadow root for the element.
    
    ```javascript
    const shadowRoot = element.attachShadow({ mode: "open" });
    ```
    
8. **`shadowRoot`**  
    Accesses the shadow root of an element (if it exists).
    
    ```javascript
    const shadow = element.shadowRoot;
    ```
    

---

##### **Node Relationships**

9. **`childElementCount`**  
    Returns the number of child elements (excluding text and comments).
    
    ```javascript
    console.log(element.childElementCount);
    ```
    
10. **`firstElementChild` and `lastElementChild`**  
    Access the first and last child elements, respectively.
    
    ```javascript
    console.log(element.firstElementChild);
    console.log(element.lastElementChild);
    ```
    
11. **`nextElementSibling` and `previousElementSibling`**  
    Access the next and previous sibling elements, respectively.
    
    ```javascript
    console.log(element.nextElementSibling);
    console.log(element.previousElementSibling);
    ```
    

---

##### **Scroll and Viewport Methods**

12. **`scrollHeight` and `scrollWidth`**  
    Return the full height and width of the element, including overflow.
    
    ```javascript
    console.log(element.scrollHeight, element.scrollWidth);
    ```
    
13. **`scrollTop` and `scrollLeft`**  
    Get or set the number of pixels scrolled vertically or horizontally.
    
    ```javascript
    element.scrollTop = 100;
    ```
    
14. **`scrollBy(x, y)`**  
    Scrolls the element by the specified x and y pixels.
    
    ```javascript
    element.scrollBy(0, 50);
    ```
    
15. **`scrollTo(x, y)`**  
    Scrolls the element to the specified coordinates.
    
    ```javascript
    element.scrollTo(0, 200);
    ```
    

---

##### **Element State Methods**

16. **`hidden`**  
    Gets or sets whether the element is hidden.
    
    ```javascript
    element.hidden = true;
    ```
    
17. **`offsetHeight`, `offsetWidth`, and `offsetParent`**
    
    - `offsetHeight` and `offsetWidth`: Return the height and width of the element, including borders.
    - `offsetParent`: Returns the nearest positioned ancestor element.
    
    ```javascript
    console.log(element.offsetHeight, element.offsetWidth);
    console.log(element.offsetParent);
    ```
    

---

##### **Special Methods**

18. **`hasChildNodes()`**  
    Checks if the element has any child nodes.
    
    ```javascript
    console.log(element.hasChildNodes()); // true or false
    ```
    
19. **`toString()`**  
    Returns the string representation of the element.
    
    ```javascript
    console.log(element.toString());
    ```
    
20. **`releasePointerCapture(pointerId)`**  
    Releases a pointer from being captured by the element.
    
    ```javascript
    element.releasePointerCapture(pointerId);
    ```
    
21. **`setPointerCapture(pointerId)`**  
    Captures a pointer for exclusive event handling on the element.
    
    ```javascript
    element.setPointerCapture(pointerId);
    ```
    

---

