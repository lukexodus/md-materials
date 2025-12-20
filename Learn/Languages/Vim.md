## Text Objects

In the context of **text objects** in **Vim/Neovim**, "words, sentences, paragraphs, and the like" refer to the logical units of text you can manipulate with commands. Text objects let you efficiently operate on specific chunks of text in Normal or Visual mode.

---

### **Common Text Objects**

#### **1. Word (`w`)**

- A word is a sequence of characters delimited by whitespace or punctuation.
- **Commands**:
    - `dw`: Delete a word from the cursor.
    - `ciw`: Change the current word (delete and enter insert mode).
- **Variants**:
    - `aw` (a word): Includes the word and the trailing whitespace.
    - `iw` (inner word): Includes only the word, excluding the whitespace.

---

#### **2. Sentence (`s`)**

- A sentence is text ending with a period (`.`), question mark (`?`), or exclamation point (`!`), followed by one or more spaces or a newline.
- **Commands**:
    - `das`: Delete a sentence.
    - `cis`: Change the inner sentence.
- **Variants**:
    - `as` (a sentence): Includes the sentence and the trailing whitespace.
    - `is` (inner sentence): Excludes the trailing whitespace.

---

#### **3. Paragraph (`p`)**

- A paragraph is a block of text separated by blank lines.
- **Commands**:
    - `dap`: Delete a paragraph.
    - `cip`: Change the inner paragraph.
- **Variants**:
    - `ap` (a paragraph): Includes the paragraph and the trailing newline or whitespace.
    - `ip` (inner paragraph): Excludes the trailing whitespace or newline.

---

### **Other Common Text Objects**

#### **4. Block of Code (`{` and `}`)**

- Enclosed by braces (`{}`) or nested structures like XML/HTML tags.
- **Commands**:
    - `di{`: Delete the content inside braces.
    - `ci{`: Change the content inside braces.
- **Variants**:
    - `a{` (a block): Includes the braces themselves.
    - `i{` (inner block): Excludes the braces.

#### **5. Quoted Strings (`'`, `"`, `` ` ``)**

- Text enclosed within quotes or backticks.
- **Commands**:
    - `di"`: Delete the content inside double quotes.
    - `ci'`: Change the content inside single quotes.
- **Variants**:
    - `a"` (a quoted string): Includes the quotes.
    - `i"` (inner quoted string): Excludes the quotes.

#### **6. Entire Line (`l`)**

- Operates on the current line.
- **Commands**:
    - `dd`: Delete the entire line.
    - `yy`: Yank (copy) the entire line.
- **No Variants**.

---

### **Combining Text Objects with Operators**

Operators like `d` (delete), `y` (yank), and `c` (change) work with text objects to perform actions:

- `diw`: Delete the inner word.
- `yas`: Yank the entire sentence.
- `cip`: Change the inner paragraph.

---

### **How to Remember**

- Think of **`i`** (inner) as focusing only on the content.
- Think of **`a`** (around) as including the delimiters or extra whitespace.

### **Analogy**

If text is a document:

- A **word** is like a brick.
- A **sentence** is a row of bricks.
- A **paragraph** is a wall made of multiple rows.
- Text objects let you select and manipulate these components with precision.

## Replacing Text in Vim

In Vim, you can perform search and replace operations using a variety of commands. Here’s a concise guide on how to do it effectively:

1. **Basic Replace Command**:
   - To replace a specific word or phrase throughout the entire file, you can use the following command in normal mode:
     ```
     :%s/old_text/new_text/g
     ```
     Here, `old_text` is the text you want to replace, and `new_text` is the text you want to use as a replacement. The `g` at the end stands for "global," meaning it will replace all occurrences in the file.

2. **Replace with Confirmation**:
   - If you want to confirm each replacement, you can add the `c` flag:
     ```
     :%s/old_text/new_text/gc
     ```
     This will prompt you for confirmation before each replacement.

3. **Replace in a Specific Range**:
   - To limit the replacement to a specific range of lines, specify the line numbers:
     ```
     :10,20s/old_text/new_text/g
     ```
     This command replaces `old_text` with `new_text` only between lines 10 and 20.

4. **Replace in the Current Line**:
   - To replace text only in the current line, use:
     ```
     :s/old_text/new_text/g
     ```
     This will replace all occurrences of `old_text` with `new_text` in the line where your cursor is located.

5. **Using the Current Word**:
   - If you want to replace the word under the cursor with a new word, you can use a mapping in your `.vimrc` file. For example:
     ```vim
     nnoremap <leader>r yiw:%s/\<<C-r>"\>//g<left><left>
     ```
     This allows you to type `<leader>r` followed by the new word to replace the current word.

By using these commands, you can efficiently manage text replacements in Vim, making your editing process smoother and more effective!

## Changing Case

#### `gu` - Change to Lowercase

- **Description**: Converts the specified text to lowercase.
- **Usage**: `gu{motion}`
    - `{motion}` specifies the range of text to apply the command to.
    - Example motions:
        - `guw`: Lowercases the current word.
        - `gug`: Lowercases the current line.
        - `gu}`: Lowercases to the end of the paragraph.
    - Example:
        
        ```text
        BEFORE: HELLO WORLD
        Command: guw
        AFTER: hello WORLD
        ```
        

#### `gU` - Change to Uppercase

- **Description**: Converts the specified text to uppercase.
- **Usage**: `gU{motion}`
    - `{motion}` specifies the range of text to apply the command to.
    - Example motions:
        - `gUw`: Uppercases the current word.
        - `gUG`: Uppercases the current line.
        - `gU}`: Uppercases to the end of the paragraph.
    - Example:
        
        ```text
        BEFORE: hello world
        Command: gUw
        AFTER: HELLO world
        ```
        

#### Practical Use Cases:

##### Changing Case of Entire Line:

- Lowercase:
    
    ```vim
    gugu
    ```
    
- Uppercase:
    
    ```vim
    gUgU
    ```
    

##### Changing Case for a Visual Selection:

- Select text visually using `v` or `V`.
- Use `gu` for lowercase or `gU` for uppercase:
    - Example: After selecting text:
        
        ```vim
        gu
        ```
        
        or
        
        ```vim
        gU
        ```

## Completion Commands

In Vim, `<C-p>` and `<C-n>` are primarily used for **completion** in **Insert Mode**. They allow you to cycle through suggested completions, such as file names, words, or keywords, based on the context. Here's how they work:

---

### **1. `<C-p>`: Previous Completion**

- **Purpose**: Inserts the **previous match** in the completion list.
- **Context**: While typing in Insert Mode, `<C-p>` suggests matches from:
    - Open buffers.
    - Files in the current directory (for filenames).
    - Previously typed words.
- **Example**:
    - Suppose you have the following text in your buffer:
        
        ```
        Vim is versatile.
        Vim has powerful completion features.
        ```
        
    - When typing `Vi` and pressing `<C-p>`, it suggests `Vim` based on existing words.

---

### **2. `<C-n>`: Next Completion**

- **Purpose**: Inserts the **next match** in the completion list.
- **Usage**: Works like `<C-p>` but cycles forward through suggestions.

---

### **Use Case for `<C-p>` and `<C-n>`**

1. **Keyword Completion**:
    - Start typing a word.
    - Press `<C-p>` or `<C-n>` to cycle through words in the buffer that match the prefix.
    - Example:
        - Buffer contains: `function` and `funny`.
        - Type `fun` and press `<C-n>` to cycle through `function` and `funny`.
2. **Filename Completion**:
    - In Insert Mode, type `:e` followed by part of a filename.
    - Use `<C-p>` and `<C-n>` to complete filenames in the current directory.
3. **Omni Completion (Context-Aware)**:
    - Some file types (e.g., programming languages) support **Omni Completion** for functions and variables.
    - Example:
        - In a Python file:
            ```python
            import os
            os.
            ```
            - Type `os.` and press `<C-x><C-o>` (Omni Completion), then use `<C-n>` and `<C-p>` to navigate suggestions.

---

### Comparison of `<C-p>` and `<C-n>`:

|**Key**|**Function**|**Direction**|
|---|---|---|
|`<C-p>`|Suggests a match|Moves **backward** in the list.|
|`<C-n>`|Suggests a match|Moves **forward** in the list.|

---

### Related Commands:

- **Omni Completion**: `<C-x><C-o>` (context-aware completion for programming).
- **File Completion**: `<C-x><C-f>` (completes filenames).
- **Dictionary Completion**: `<C-x><C-k>` (completes words from a dictionary file).
- **Tag Completion**: `<C-x><C-]>` (completes tags).

These commands make editing faster and more efficient, especially when dealing with repetitive or complex text.

## Filter `!` Command

The **`!` filter command** in Vim/Neovim allows you to process lines of text using an external shell command. This is incredibly powerful for tasks like formatting, transforming, or filtering text.

---

### **How It Works**

The general syntax is:

```vim
:[range]!{command}
```

- **`[range]`**: Specifies the lines you want to filter (e.g., `1,5` for lines 1 to 5, or `%` for the whole file).
- **`!`**: Invokes an external command.
- **`{command}`**: The shell command to execute on the specified lines.

The selected text is sent to the external command as input, and the output replaces the original text in Vim.

---

### **Examples**

1. **Sort Lines** To sort lines 1 to 5 alphabetically:
    
    ```vim
    :1,5!sort
    ```
    
2. **Uppercase Conversion** Convert all lines in the file to uppercase using `tr`:
    
    ```vim
    :%!tr 'a-z' 'A-Z'
    ```
    
3. **Remove Extra Spaces** Remove trailing whitespace from all lines using `sed`:
    
    ```vim
    :%!sed 's/[ \t]*$//'
    ```
    
4. **Run Custom Python Script** Apply a Python script to lines 3 to 10:
    
    ```vim
    :3,10!python3 my_script.py
    ```
    
5. **Format JSON** Pretty-print JSON data in the whole file using `jq`:
    
    ```vim
    :%!jq
    ```
    
6. **Reverse Lines** Reverse the order of lines in the file using `tac`:
    
    ```vim
    :%!tac
    ```
    

---

### **Special Ranges**

- `:%!{command}`: Filters the entire file.
- `:.!{command}`: Filters the current line.
- `:'<,'>!{command}`: Filters the selected lines in visual mode.

---

### **Practical Workflow**

1. **Enter Visual Mode**:
    
    - Select text with `V` (visual line mode) or `v` (character-wise mode).
    - Type `:` to bring up the command-line prompt pre-filled with the selected range (`:'<,'>`).
2. **Apply Command**:
    
    - Enter the desired shell command after the `!`.

For example:

- Highlight text → `:'<,'>!sort` → Sort the selected lines.

---

### **Undo Changes**

If the result of the filter command isn’t what you wanted, you can undo it using `u` in normal mode.

---

### **Key Points**

- The `!` filter command integrates Neovim with shell commands, offering nearly limitless text-processing capabilities.
- It replaces the specified range with the command's output.
- Always double-check commands, especially when working with destructive filters.

This feature is perfect for leveraging the power of external tools within the flexibility of Neovim!

## Visual Modes

In Vim, `<C-v>`, `v`, and `V` are used to enter different **Visual modes**, which allow you to select and manipulate text in various ways. Here's how they differ:

---

### **1. `<C-v>`: Visual Block Mode**

- **Purpose**: Selects a **block (column)** of text.
- **Behavior**:
    - Allows you to select rectangular regions of text.
    - Useful for working with columns, such as aligning text or editing multiple lines simultaneously.
- **Example**:
    
    ```plaintext
    hello world
    Vim is great
    ```
    
    - Place the cursor on the first "h" and press `<C-v>`. Use `j` (down) and `l` (right) to select the first column of letters.
    - Result:
        
        ```
        h   w
        V   i
        ```
        
- **Common Use Cases**:
    - Insert or replace text across multiple lines using block regions.
    - Example: Select a block and press `I` to insert text at the start of each selected line.
    - Align text by padding spaces or removing columns.

---

### **2. `v`: Visual Mode**

- **Purpose**: Selects text **character by character**.
- **Behavior**:
    - Selection starts from the current cursor position and expands as you move.
- **Example**:
    
    ```plaintext
    hello world
    ```
    
    - Place the cursor on "h" and press `v`. Use `l` to expand selection.
    - Result:
        
        ```
        [hello] world  (Selected: "hello")
        ```
        
- **Common Use Cases**:
    - Highlight and manipulate text at the character level.
    - Replace, delete, or copy specific parts of text.

---

### **3. `V`: Visual Line Mode**

- **Purpose**: Selects text **line by line**.
- **Behavior**:
    - Entire lines are selected regardless of the cursor's position within the line.
- **Example**:
    
    ```plaintext
    hello world
    Vim is great
    ```
    
    - Place the cursor on "hello world" and press `V`. Use `j` to include the next line.
    - Result:
        
        ```
        [hello world
        Vim is great]
        ```
        
- **Common Use Cases**:
    - Perform operations on whole lines, such as copying, deleting, or shifting indentation.

---

### **Comparison Table**

|**Command**|**Mode**|**Selection Scope**|**Use Case**|
|---|---|---|---|
|`<C-v>`|Visual Block|Block (rectangular region)|Edit multiple columns or align text.|
|`v`|Visual|Character by character|Fine-grained text manipulation.|
|`V`|Visual Line|Entire lines|Line-based operations like shifting.|

---

### **Key Combination Examples**

1. **Insert in Multiple Lines**:
    - `<C-v>` → Select a column → `I` → Type → `<Esc>`.
2. **Change Indentation**:
    - `V` → Select lines → `>` or `<` to shift indentation.
3. **Delete or Copy Text**:
    - `v` → Select characters → `d` (delete) or `y` (yank).

These modes provide flexibility for different types of text editing in Vim.

## Folds

In **Vim/Neovim**, **folds** are a way to hide and show sections of text, making it easier to focus on specific parts of your file without distractions. Folds are especially useful for working with large files, structured text (like code, logs, or markdown), and nested content.

---

### **How Folds Work**

Folds allow you to:

- Collapse (close) sections of text so only a summary line (the fold line) is visible.
- Expand (open) folds to reveal the hidden text.

---

### **Key Concepts**

1. **Folded Text**: Text within a fold is hidden and replaced by a single line (the "fold line").
2. **Fold Levels**: Folds can be hierarchical, meaning you can have folds within folds.

---

### **Basic Fold Commands**

|Command|Description|
|---|---|
|`za`|Toggle a fold (open if closed, close if open).|
|`zc`|Close (collapse) the current fold.|
|`zo`|Open (expand) the current fold.|
|`zM`|Close all folds in the file.|
|`zR`|Open all folds in the file.|
|`zd`|Delete the current fold.|
|`zE`|Delete all folds in the file.|
|`zm`|Increase fold level (close more folds).|
|`zr`|Decrease fold level (open more folds).|

---

### **Fold Methods**

The way Vim/Neovim determines folds is called the **fold method**. You can configure it with `set foldmethod=<type>`. Common fold methods include:

1. **Manual (`manual`)**:
    
    - You define folds manually.
    - Commands: `zf` (create fold), `zd` (delete fold).
    - Example: Select a range of lines in Visual mode and press `zf`.
2. **Indent (`indent`)**:
    
    - Folds are based on indentation levels.
    - Useful for Python, YAML, and other indented formats.
    - Command: `set foldmethod=indent`.
3. **Syntax (`syntax`)**:
    
    - Folds are based on syntax highlighting rules.
    - Useful for programming languages.
    - Command: `set foldmethod=syntax`.
4. **Expression (`expr`)**:
    
    - Folds are determined by a custom function or expression.
    - Allows advanced, custom folding logic.
    - Example: `set foldexpr=nvim_treesitter#foldexpr()` (using Tree-sitter for folds).
5. **Marker (`marker`)**:
    
    - Folds are defined by special markers in the text.
    - Default markers: `{{{` to open, `}}}` to close.
    - Command: `set foldmethod=marker`.
6. **Diff (`diff`)**:
    
    - Folds are based on differences in a file during a diff view.
    - Command: `set foldmethod=diff`.

---

### **Configuring Folds**

- **Set Fold Method**:
    
    ```vim
    set foldmethod=indent   " Use indent-based folding
    set foldlevel=1         " Open folds up to level 1
    ```
    
- **Save and Restore Folds Automatically**: Add to `init.vim` or `init.lua`:
    
    ```vim
    autocmd BufWinLeave *.* mkview
    autocmd BufWinEnter *.* silent! loadview
    ```
    

---

### **Fold Use Cases**

1. **Code**:
    - Collapse functions, classes, or blocks for better readability.
2. **Logs**:
    - Hide repetitive sections of logs to focus on key events.
3. **Markdown**:
    - Collapse sections like headers or lists for easy navigation.

---

### **Analogy**

Think of folds like sections of a book with expandable outlines:

- Closed folds show the title of a section (e.g., a chapter heading).
- Open folds show the full text within that section.

Folds let you quickly navigate and manage large documents or codebases without getting overwhelmed.


## Buffers

In the context of Vim and Neovim, **buffers** represent the in-memory representation of open files. A buffer is essentially a workspace for text that you've opened, created, or edited in Vim.

### Key Features of Buffers:

1. **File Representation:** When you open a file in Vim, it is loaded into a buffer. The buffer holds the text of the file while you edit it.
2. **Unlinked Buffers:** Buffers do not need to be tied to a file on disk. You can create a new, unnamed buffer and work with it as a scratchpad.
3. **Multiple Buffers:** Vim can manage multiple buffers simultaneously. You can switch between them, even though only one is displayed at a time in the simplest configurations.
4. **Lifecycle:** A buffer exists as long as it's needed (i.e., until it's explicitly closed or replaced). A buffer can exist even if its file is deleted on disk.

### Common Buffer Commands:

Here are some commands to manage buffers:

#### Listing Buffers

```vim
:ls
```

- Displays a list of all open buffers with their numbers and statuses.

#### Opening a Buffer

```vim
:buffer {number}
```

- Opens a buffer by its number (shown in `:ls`).

#### Creating a New Buffer

```vim
:new
```

- Opens a new empty buffer in a split window.

#### Switching Buffers

```vim
:bn
```

- Move to the **next buffer**.

```vim
:bp
```

- Move to the **previous buffer**.

```vim
:b {name or number}
```

- Switch directly to a buffer by its name or number.

#### Deleting Buffers

```vim
:bd
```

- Deletes the current buffer (but doesn’t delete the file).

#### Unloading Buffers

```vim
:bun
```

- Unloads a buffer, freeing memory, but keeps it in the buffer list.

### Status Indicators in Buffers

When you list buffers with `:ls`, you'll see indicators like:

- **%**: The current buffer.
- **#**: The alternate buffer (used before the current one).
- **a**: Active buffer.
- **h**: Hidden buffer (not displayed but still exists in memory).

### Buffers vs. Windows vs. Tabs

Understanding the distinction between buffers, windows, and tabs is crucial:

- **Buffers**: Text content in memory (e.g., files or scratchpads).
- **Windows**: Viewports into a buffer. You can split your screen to show multiple windows of the same or different buffers.
- **Tabs**: Collections of windows. Each tab can have its own set of windows showing different buffers.

### Example Workflow

1. Open a file:
    
    ```vim
    :e file.txt
    ```
    
2. Open another file (creates a new buffer):
    
    ```vim
    :e another_file.txt
    ```
    
3. Switch between them:
    
    ```vim
    :bp
    :bn
    ```
    
4. View all buffers:
    
    ```vim
    :ls
    ```

## Buffers vs Windows vs Tabs vs Args

In **Vim/Neovim**, understanding the distinction between _arglist_, _buffers_, _windows_, and _tabs_ helps you manage your files and workflow effectively. Each of these has a specific role in how you work with files.

---

### **1. Buffers**

- **Definition**: A buffer is an in-memory representation of an open file. You can edit a buffer without immediately saving changes to disk.
- **Key Points**:
    - A buffer is created when a file is opened or when you create a new unsaved file.
    - Buffers persist even when they are not displayed in a window.
    - Buffers have a unique number for identification.
- **Common Commands**:
    - `:ls` or `:buffers`: List all open buffers.
    - `:b <buffer>`: Switch to a specific buffer.
    - `:bd`: Delete a buffer (removes it from the buffer list but does not close the file).

---

### **2. Windows**

- **Definition**: A window is a viewport for viewing a buffer. It allows you to display and interact with buffers in split screens.
- **Key Points**:
    - A single buffer can be opened in multiple windows.
    - Windows provide flexibility for side-by-side editing.
- **Common Commands**:
    - `:split` or `:vsplit`: Create a horizontal or vertical split.
    - `<C-w> h/j/k/l`: Navigate between windows.
    - `<C-w> o`: Close all windows except the current one.

---

### **3. Tabs**

- **Definition**: A tab is a collection of windows. Tabs group windows together to allow quick context switching between different layouts.
- **Key Points**:
    - Tabs are a way to organize multiple window layouts, not buffers.
    - Each tab can have its own arrangement of windows, but they all share the same buffer list.
- **Common Commands**:
    - `:tabnew`: Open a new tab.
    - `:tabn` and `:tabp`: Move to the next or previous tab.
    - `:tabclose`: Close the current tab.

---

### **4. Arglist**

- **Definition**: The arglist (argument list) is a list of files passed to Vim on startup or manually set using commands. It’s a temporary, session-specific list of files to work through.
- **Key Points**:
    - The arglist is useful for focusing on a subset of files.
    - You can traverse the arglist without affecting the buffer list.
- **Common Commands**:
    - `:args file1 file2 ...`: Set the arglist.
    - `:next` and `:prev`: Move to the next/previous file in the arglist.
    - `:argadd file`: Add files to the current arglist.

---

### **How They Work Together**

1. **Buffers** are the core, representing open files or scratch spaces.
2. **Windows** allow multiple views of buffers.
3. **Tabs** group windows for organization.
4. **Arglist** provides a task-focused file list for sequential operations.

---

### **Analogy**

Imagine you are working on several documents:

- **Buffers**: These are the actual documents you are editing.
- **Windows**: Think of them as different frames showing the same or different documents.
- **Tabs**: These are groups of frames, like pages in a notebook, each holding its own arrangement of frames.
- **Arglist**: A prioritized to-do list of documents you want to focus on.

---

### **Practical Example**

1. Open multiple files in Vim: `vim file1 file2 file3`.
    - All these files are loaded into buffers.
    - `:ls` shows the buffers.
2. Split the window: `:split` or `:vsplit`.
    - Now you have two windows viewing either the same or different buffers.
3. Create a new tab: `:tabnew`.
    - You can open more splits in this new tab.
4. Focus on a subset of files: `:args file2 file3`.
    - Use `:next` and `:prev` to navigate the arglist.

By mastering these concepts, you can navigate and manage your workflow with efficiency and precision!

## Managing Windows

Managing **windows** in **Vim/Neovim** involves splitting the editor into multiple views to work on different files or parts of a file simultaneously. Below is a comprehensive guide to window management:

---

### **Creating Splits**

1. **Horizontal Split**:
    
    - `:split` or `:sp`: Opens a new horizontal split.
    - `:split <file>`: Opens `<file>` in a horizontal split.
2. **Vertical Split**:
    
    - `:vsplit` or `:vsp`: Opens a new vertical split.
    - `:vsplit <file>`: Opens `<file>` in a vertical split.

---

### **Navigating Windows**

- `<C-w><direction>`: Move to the adjacent window in the specified direction:
    
    - `<C-w>h`: Left
    - `<C-w>j`: Down
    - `<C-w>k`: Up
    - `<C-w>l`: Right
- `<C-w>w`: Cycle through all open windows.
    
- `<C-w>p`: Move to the previously used window.
    

---

### **Resizing Windows**

- **Increase/Decrease Size**:
    
    - `<C-w>+`: Increase the height of the current window.
    - `<C-w>-`: Decrease the height of the current window.
    - `<C-w>>`: Increase the width of the current window.
    - `<C-w><`: Decrease the width of the current window.
- **Set Size Directly**:
    
    - `<C-w>=`: Make all windows equal in size.
    - `:resize <n>`: Set the height of the current window to `<n>`.
    - `:vertical resize <n>`: Set the width of the current window to `<n>`.

---

### **Maximizing/Minimizing Windows**

- `<C-w>_`: Maximize the height of the current window.
- `<C-w>|`: Maximize the width of the current window.
- `<C-w>=`: Restore all windows to equal size.

---

### **Closing Windows**

- `:close` or `<C-w>c`: Close the current window.
- `:q` or `:quit`: Close the current window if no unsaved changes.
- `:only` or `<C-w>o`: Close all windows except the current one.

---

### **Switching Buffers in Windows**

- Use `:bnext` or `:bn`: Move to the next buffer in the current window.
- Use `:bprev` or `:bp`: Move to the previous buffer in the current window.
- Use `:buffer <n>`: Switch to a specific buffer `<n>` in the current window.

---

### **Moving Windows**

- **Swap Windows**:
    
    - `<C-w>x`: Swap the current window with the next window.
- **Rotate Windows**:
    
    - `<C-w>r`: Rotate windows clockwise.
    - `<C-w>R`: Rotate windows counterclockwise.

---

### **Tabs vs. Windows**

- Windows are views into files or buffers.
- Tabs are collections of windows.
- **Difference**: A tab can have multiple windows (splits), whereas a window only shows a single buffer or file.

---

### **Practical Example**

1. Open a file: `nvim file1.txt`.
2. Split the window vertically: `:vsplit file2.txt`.
3. Move to the left window: `<C-w>h`.
4. Resize the right window: `<C-w>10>`.
5. Close the left window: `<C-w>c`.

---

Mastering window management in Vim/Neovim allows you to efficiently work with multiple files and sections of your code, making it an essential skill for productive editing.


# Navigation

## Marks

In **Vim/Neovim**, the `m` command is used to **set marks** in the text. Marks are like bookmarks in a file that help you quickly navigate to specific locations. Each mark is associated with a position in a file and can be used across sessions (for certain marks) or within the same session.

---

### **Setting a Mark**

- Use `m<letter>` to set a mark at the cursor's current position.
    - `<letter>` can be a lowercase letter (a-z) or an uppercase letter (A-Z).

---

### **Types of Marks**

1. **Local Marks** (lowercase `a-z`):
    
    - Specific to the current file.
    - Example: `ma` sets a mark `a` in the current file.
2. **Global Marks** (uppercase `A-Z`):
    
    - Specific to a position in a file but accessible across different files in your session.
    - Example: `mA` sets a global mark `A`.
3. **Special Marks**:
    
    - `'` (backtick): Tracks the last jump position within the current buffer.
    - `"`: Tracks the position where the file was last closed.
    - `[`, `]`: Define the start and end of the last changed or yanked text.
    - `^`: Tracks the position of the cursor in the last inserted text.

---

### **Navigating to Marks**

- Use `'` (single quote) followed by the mark to move to the start of the line where the mark is.
    - Example: `'a` moves to the line of mark `a`.
- Use `` ` `` (backtick) followed by the mark to move to the exact position (line and column) of the mark.
    - Example: `` `a` `` moves to the exact position of mark `a`.

---

### **Deleting Marks**

- Use `:delmarks <letters>` to delete specific marks.
    - Example: `:delmarks a` deletes mark `a`.
- Use `:delmarks!` to delete all marks in the current buffer.

---

### **Practical Use Cases**

1. **Bookmark a Position**:
    
    - If you're editing a long file, use `ma` to bookmark your current location and return to it later with `'a` or `` `a` ``.
2. **Jump Between Files**:
    
    - Use global marks (e.g., `mA`) to bookmark locations in different files and quickly navigate back with `'A` or `` `A` ``.
3. **Highlight Recent Changes**:
    
    - Use `[`, `]` marks to revisit areas of recent edits.

---

### **Example Workflow**

1. Move to a line and set a mark `mA`.
2. Go to another location and set a mark `mB`.
3. Navigate back to mark `A` using `'A` or `` `A` ``.

By using marks effectively, you can significantly enhance your navigation and editing efficiency in Vim/Neovim!

## ftFT

#### `f{char}` - Find Character Forward

- Moves the cursor **forward** to the next occurrence of `{char}` in the current line.
- Example:
    - Text: `hello world`
    - Command: `fo` (find `o`)
    - Cursor moves to: `hello w**o**rld`

#### `F{char}` - Find Character Backward

- Moves the cursor **backward** to the previous occurrence of `{char}` in the current line.
- Example:
    - Text: `hello world`
    - Command: `Fo` (find `o`)
    - Cursor moves to: `hell**o** world`

#### `t{char}` - Move Until Character Forward

- Moves the cursor **forward**, stopping **just before** the next occurrence of `{char}`.
- Example:
    - Text: `hello world`
    - Command: `to` (move until `o`)
    - Cursor stops at: `hello w**o**rld`

#### `T{char}` - Move Until Character Backward

- Moves the cursor **backward**, stopping **just before** the previous occurrence of `{char}`.
- Example:
    - Text: `hello world`
    - Command: `To` (move until `o`)
    - Cursor stops at: `hell**o** world`

---

#### Repeating the Commands

- **Repeat Forward (`;`)**: Repeats the last `f`, `F`, `t`, or `T` command in the same direction.
- **Repeat Backward (`,`)**: Repeats the last `f`, `F`, `t`, or `T` command in the opposite direction.

---

#### Use with Operators

These motions can be combined with operators (like `d`, `c`, `y`) for editing. For example:

- `dfx`: Delete up to and including `x` (using `f` motion).
- `dtx`: Delete up to but not including `x` (using `t` motion).

---

#### Summary Table

|Command|Direction|Behavior|
|---|---|---|
|`f{char}`|Forward|Moves to `{char}`|
|`F{char}`|Backward|Moves to `{char}`|
|`t{char}`|Forward|Stops before `{char}`|
|`T{char}`|Backward|Stops before `{char}`|
|`;`|Repeats|Repeat last motion forward|
|`,`|Repeats|Repeat last motion backward|

These commands are very efficient for fine-grained navigation within a line!

## Scrolling Commands

- **`<C-d>`**: Scroll **downward** by half a screen.
- **`<C-u>`**: Scroll **upward** by half a screen.
- **`<C-e>`**: Scroll down by **one line**.
- **`<C-y>`**: Scroll up by **one line**.
- **`<C-f>`**: Scroll **down a full screen**.
- **`<C-b>`**: Scroll **up a full screen**.

# Configuration

## Common Settings

Here are some commonly used **Neovim settings** to enhance your workflow. These settings can be added to your `init.vim` or `init.lua` file.

---

### **General Settings**

1. **Line Numbers**:
    
    ```vim
    set number       " Show line numbers
    set relativenumber " Relative line numbers for easy navigation
    ```
    
2. **Tab and Indentation**:
    
    ```vim
    set tabstop=4        " Number of spaces a tab represents
    set shiftwidth=4     " Number of spaces used for autoindent
    set expandtab        " Convert tabs to spaces
    set autoindent       " Copy indent from current line
    set smartindent      " Smart auto-indentation for programming
    ```
    
3. **Search**:
    
    ```vim
    set ignorecase       " Case-insensitive search
    set smartcase        " Case-sensitive if search includes uppercase
    set hlsearch         " Highlight search results
    set incsearch        " Show search results incrementally
    ```
    
4. **UI Enhancements**:
    
    ```vim
    set cursorline       " Highlight the current line
    set showcmd          " Show incomplete commands in the bottom right
    set wildmenu         " Enhanced command-line completion
    set ruler            " Show cursor position in the status line
    set scrolloff=8      " Keep 8 lines visible above/below the cursor
    set sidescrolloff=8  " Keep 8 columns visible to the left/right
    set signcolumn=yes   " Show the sign column (for git, diagnostics, etc.)
    ```
    
5. **Mouse and Clipboard**:
    
    ```vim
    set mouse=a          " Enable mouse in all modes
    set clipboard=unnamedplus " Use system clipboard
    ```
    
6. **Folding**:
    
    ```vim
    set foldmethod=indent " Fold based on indentation
    set foldlevel=99      " Start with all folds open
    ```
    
7. **Backup and Undo**:
    
    ```vim
    set backup            " Enable backup files
    set backupdir=~/.config/nvim/backup// " Directory for backups
    set undofile          " Enable persistent undo
    set undodir=~/.config/nvim/undo// " Directory for undo history
    ```
    

---

### **Performance and File Handling**

1. **Faster Rendering**:
    
    ```vim
    set lazyredraw        " Redraw only when needed
    set updatetime=300    " Faster completion and diagnostics
    ```
    
2. **Splits Behavior**:
    
    ```vim
    set splitbelow        " Open horizontal splits below
    set splitright        " Open vertical splits to the right
    ```
    
3. **Hidden Buffers**:
    
    ```vim
    set hidden            " Keep buffers open in the background
    ```
    
4. **File Encoding**:
    
    ```vim
    set encoding=utf-8    " Default file encoding
    set fileformats=unix,dos,mac " Handle different line endings
    ```
    

---

### **Visual Preferences**

1. **Colorscheme**:
    
    ```vim
    colorscheme gruvbox   " Use a popular colorscheme
    set termguicolors     " Enable true color support
    ```
    
2. **Status Line**: Using a plugin like **lualine** or:
    
    ```vim
    set laststatus=2      " Always show the status line
    ```
    

---

### **Key Mappings**

1. **Remap Space as Leader**:
    
    ```vim
    let mapleader=" "     " Set Space as the leader key
    ```
    
2. **Custom Shortcuts**:
    
    ```vim
    nnoremap <leader>w :w<CR>          " Save file
    nnoremap <leader>q :q<CR>          " Quit
    nnoremap <leader>x :x<CR>          " Save and quit
    ```
    
3. **Navigation Between Splits**:
    
    ```vim
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
    ```
    
4. **Buffer Management**:
    
    ```vim
    nnoremap <leader>bn :bnext<CR>     " Go to next buffer
    nnoremap <leader>bp :bprevious<CR> " Go to previous buffer
    nnoremap <leader>bd :bdelete<CR>   " Delete current buffer
    ```
    

---

### **Common Plugins**

If you're using **plugin managers** (e.g., `vim-plug` or `lazy.nvim`), consider these for enhancing functionality:

1. **File Navigation**: `nvim-tree.lua` or `telescope.nvim`
2. **Status Line**: `lualine.nvim`
3. **Git Integration**: `vim-fugitive` or `gitsigns.nvim`
4. **Syntax Highlighting**: `nvim-treesitter`
5. **Auto-completion**: `nvim-cmp`
6. **Linting/Formatting**: `null-ls.nvim`

---

These settings are a starting point for optimizing your Neovim experience. You can customize them further based on your workflow.

### Managing Options

In **Vim/Neovim**, **options** are settings that control the editor's behavior and appearance. They can be categorized into three types:

1. **Boolean Options**: These can be either enabled or disabled.

- Example: `number` (shows line numbers).
- To enable: `:set number`
- To disable: `:set nonumber`

2. **Number Options**: These accept integer values.

- Example: `shiftwidth` (sets the number of spaces for indentation).
- To set: `:set shiftwidth=4`

3. **String Options**: These accept string values.

- Example: `background` (sets the background color scheme).
- To set: `:set background=dark`

To view all options that differ from their default values, use: `:set`

To view a specific option's value:
```
:set option_name?
```
To toggle a boolean option:
```
:set option_name!
```
To reset an option to its default value:
```
:set option_name&
```

To make changes permanent, add the desired `:set` commands to your `~/.vimrc` file. This file is sourced each time Vim starts, applying your custom configurations.