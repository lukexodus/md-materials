## Macros and Repeat Commands (., @)


### Overview of Repeat Commands
Repeat commands in Neovim allow users to re-execute previous actions efficiently, reducing repetitive keystrokes. The dot command (.) repeats the last change, while other commands like ; and , repeat motions. These are built-in features, and their behavior may vary depending on plugins or mappings in LazyVim.

**Key Points**
- The . command replays the most recent change, including insertions, deletions, or replacements.
- Changes are defined as modifications to the buffer, such as those made in normal, visual, or insert modes.
- ; repeats the last f, F, t, or T motion forward; , repeats it backward.
- n and N repeat searches forward and backward, respectively.
- Behavior may differ if plugins like vim-repeat are installed, which enhances repeatability for custom mappings.

**Example**
Suppose you delete a word with dw. To repeat this on the next word:
1. Position the cursor.
2. Press . 
This applies dw again without retyping.

### Recording Macros
Macros enable recording a sequence of commands into a register for later playback. Recording starts with q followed by a register name (a-z or 0-9), and ends with q. This is a core Neovim feature, available in LazyVim without additional setup.

**Key Points**
- Registers for macros: Lowercase a-z for general use; uppercase A-Z append to existing; 0-9 are read-only for recent deletions.
- During recording, the status line shows "recording @register".
- Macros can include motions, edits, and even commands like :w.
- Nested recordings are not supported; attempting to record while recording stops the current one.
- Macros may interact with undo history, potentially grouping changes.

**Example**
To record a macro that appends a semicolon to the end of a line:
1. Press qa to start recording in register a.
2. Press A; followed by \<Esc> to append and exit insert mode.
3. Press q to stop.
The macro is now stored and ready for playback.

### Playing Back Macros
Playback uses @ followed by the register name. For repeated execution, prepend a count, like 5@a to run five times. @@ repeats the last played macro.

**Key Points**
- @register executes the macro once; count@register runs it multiple times.
- @@ replays the most recently executed macro.
- Q in normal mode enters Ex mode, but this is unrelated to macros.
- If a macro fails midway (e.g., due to invalid motion), execution stops, and an error may appear.
- In LazyVim, macros work seamlessly with most plugins, but complex interactions (e.g., with LSP) may require testing.

**Example**
After recording the semicolon macro in a:
1. Move to another line.
2. Press @a to execute it.
To apply to 10 lines: 10@a.

**Output**
If the original line is "print('hello')", after @a it becomes "print('hello');".

### Editing and Viewing Macros
Macros are stored in registers, viewable with :registers or :display. To edit, paste the register into a buffer, modify, and yank back.

**Key Points**
- :reg a shows the content of register a as a sequence of keystrokes.
- To edit: "ap to paste, make changes, "ay to yank back into a.
- Special characters appear escaped (e.g., \<Esc> as ^[).
- Registers persist across sessions if viminfo is enabled.
- [Inference]: In LazyVim, default config likely preserves registers via shada file.

**Example**
View a macro: :reg a
Edit:
1. Open a new buffer.
2. "ap to insert the macro text.
3. Modify, e.g., change ; to !.
4. Select and "ay to update.

### Advanced Usage and Combinations
Combine macros with repeats for complex automation. For instance, use . within a macro, or chain macros. Visual mode selections can be part of macros.

**Key Points**
- Macros can include . to repeat inner changes.
- Use @= for expression registers to execute Vimscript dynamically.
- In visual mode, @register applies the macro to selected lines.
- Recursive macros (e.g., @a including @a) require care to avoid infinite loops; use counts or conditions.
- LazyVim's keybindings (e.g., leader keys) can be recorded if they resolve to native commands.

**Example**
Record a macro b that deletes a line and repeats a previous change:
1. qb
2. dd.
3. q
Playback with @b combines deletion and repeat.

### Integration with LazyVim Features
In LazyVim, macros and repeats integrate with plugins like which-key for discoverability and mini.vim for enhancements. No specific overrides for . or @ exist by default.

**Key Points**
- LazyVim's undo tree (via mini.bufremove or similar) may affect how . interacts with history.
- LSP actions or auto-completions can be recorded in macros.
- If vim-repeat is enabled (optional in LazyVim), it makes plugin mappings repeatable with ..
- [Unverified]: Some users report inconsistencies with multi-cursor plugins; test in your setup.

### Common Pitfalls and Tips
Users may encounter issues like unintended recursions or mode mismatches in macros.

**Key Points**
- Ensure macros end in the intended mode (e.g., normal).
- Use gv to reselect visual areas in macros.
- For counts in macros, record with a specific count or use dynamically.
- Test macros on sample text to avoid data loss.
- Behavior may vary across Neovim versions or with incompatible plugins.

### Conclusion
Macros and repeat commands offer powerful ways to automate tasks in Neovim, enhancing productivity through recording and replaying sequences. With practice, they can handle complex edits efficiently, though testing is recommended for reliability.

### Next Steps
- Practice recording simple macros in a scratch buffer.
- Explore :help q and :help . for detailed documentation.
- Customize via lua/config/autocmds.lua if needed for specific behaviors.
- Experiment with combining macros and visual selections for bulk operations.

---

