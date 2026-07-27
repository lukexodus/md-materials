# LazyVim Comprehensive Cheatsheet

## 0. Foundational Concepts

| Concept | Detail |
|---|---|
| Leader key | `<Space>` (LazyVim default) |
| Local leader | `\` (default, less used) |
| Which-key | Auto-triggers on leader press after a short delay; shows all available continuations. `[Inference]` — assumed present since it underlies leader-key discoverability in every default LazyVim install. |
| `:LazyExtras` | Browse/enable optional LazyVim extras (many plugins below are "extras," not core) |
| `:Lazy` | Plugin manager UI — install/update/clean/profile |
| `:checkhealth` | Diagnose broken integrations (LSP, treesitter, clipboard, etc.) |

---

## 1. Editor Core — Neo-tree, Snacks Picker, Outline

### Neo-tree (file explorer)

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer (root-relative) |
| `<leader>E` | Toggle file explorer (cwd-relative) |
| `a` | Add file |
| `A` | Add directory |
| `d` | Delete |
| `r` | Rename |
| `y` | Copy to clipboard (Neo-tree internal) |
| `x` | Cut to clipboard |
| `p` | Paste |
| `c` | Copy file |
| `m` | Move file |
| `q` | Close window |
| `R` | Refresh |
| `?` | Show help |
| `<cr>` | Open file/expand dir |
| `S` | Open in vertical split |
| `s` | Open in horizontal split |
| `t` | Open in new tab |
| `H` | Toggle hidden files |
| `Z` | Expand all nodes |
| `z` | Collapse all nodes |
| `[g` / `]g` | Prev/next git-modified file |

### Snacks Picker (fuzzy finder — replaces Telescope in newer LazyVim)

| Key | Action |
|---|---|
| `<leader><space>` | Find files (smart) |
| `<leader>,` | Switch buffer |
| `<leader>/` | Grep (live) in cwd |
| `<leader>:` | Command history |
| `<leader>ff` | Find files |
| `<leader>fg` | Find git files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>sg` | Grep in project |
| `<leader>sw` | Search word under cursor |
| `<leader>sh` | Search help pages |
| `<leader>sk` | Search keymaps |
| `<leader>sd` | Search diagnostics |
| `<leader>sr` | Search/resume last picker |
| Inside picker: `<C-j>/<C-k>` | Move down/up |
| Inside picker: `<Tab>` | Toggle selection (multi-select) |
| Inside picker: `<C-x>` | Open in horizontal split |
| Inside picker: `<C-v>` | Open in vertical split |
| Inside picker: `<C-t>` | Open in new tab |
| Inside picker: `<C-q>` | Send results to quickfix |

### Outline (symbols/outline view)

| Key | Action |
|---|---|
| `<leader>cs` | Toggle symbols outline |
| `<cr>` | Jump to symbol |
| `<C-space>` | Preview symbol without leaving outline |
| `o` | Toggle fold |
| `r` | Rename symbol (may delegate to LSP rename) |

---

## 2. Completion — Blink.cmp

| Key | Action |
|---|---|
| `<C-space>` | Trigger/toggle completion menu |
| `<Tab>` / `<C-n>` | Next item |
| `<S-Tab>` / `<C-p>` | Previous item |
| `<CR>` | Confirm/accept selected item |
| `<C-e>` | Close completion menu |
| `<C-y>` | Confirm (alt binding, config-dependent) |
| `<C-u>` / `<C-d>` | Scroll documentation window up/down |

`[Inference]` — Blink.cmp is a newer, Rust-backed alternative to nvim-cmp with similar default bindings; exact keys are config-defined in `keymap.preset`, so verify against your `blink.cmp` opts if you've customized presets (`"default"`, `"super-tab"`, `"enter"` are common presets with different Tab/Enter behavior).

---

## 3. AI — GitHub Copilot

| Key | Action |
|---|---|
| `<Tab>` | Accept full suggestion (insert mode, when ghost text visible) |
| `<C-]>` | Dismiss suggestion |
| `<M-]>` / `<M-[>` | Next/previous suggestion |
| `<C-Right>` (or `<M-Right>`) | Accept word-by-word |
| `<leader>ap` | `[Inference]` — common LazyVim Copilot-extra binding to toggle/open Copilot panel |
| `:Copilot status` | Check auth/connection status |
| `:Copilot enable` / `disable` | Toggle Copilot globally |

Note: Copilot's `<Tab>` accept binding **conflicts** with completion-menu Tab-navigation from Blink if both are active in the same context — LazyVim's Copilot extra typically scopes Copilot's Tab to only fire when no cmp/blink menu is visible. If you experience Tab doing "the wrong thing," this is the most common cause.

---

## 4. Navigation — Flash, Harpoon2, Leap

### Flash.nvim

| Key | Action |
|---|---|
| `s` (normal/visual/operator-pending) | Flash jump — label-based 2-char search jump |
| `S` | Flash Treesitter — jump to treesitter node |
| `r` (operator-pending, e.g. after `d`, `y`) | Remote Flash — act on distant text without moving cursor first |
| `R` (operator-pending/visual) | Treesitter Search |
| `<C-s>` (while in `/` or `?` search) | Toggle Flash search integration |

### Harpoon2

| Key | Action |
|---|---|
| `<leader>ha` | Add current file to Harpoon list |
| `<leader>hh` | Toggle Harpoon quick-menu |
| `<C-1>` … `<C-4>` | Jump directly to Harpoon slot 1–4 (common default) |
| Inside Harpoon menu: `<C-v>` | Open selected in vertical split |
| Inside Harpoon menu: `<C-x>` | Open selected in horizontal split |

### Leap.nvim

| Key | Action |
|---|---|
| `s` (normal/visual) | Leap forward |
| `S` | Leap backward |
| `gs` | Leap from windows (cross-window jump) |
| `x` / `X` (operator-pending) | Leap-based operator motion |

**Conflict flag `[Inference]`:** Flash and Leap both default to `s`/`S` in normal mode for jump-motions. Running both plugins simultaneously without remapping one of them means the second-loaded plugin's keymap silently wins, and the other's `s`/`S` binding becomes dead or overridden. If your config genuinely has both active, one of them almost certainly has custom keys (commonly Leap remapped to `gs`-prefixed or Flash restricted to operator-pending-only use). Worth auditing your own `keys` table for these two plugins to see which actually owns `s`.

---

## 5. Clipboard — Yanky.nvim

| Key | Action |
|---|---|
| `y` | Yank (Yanky-wrapped, populates yank-history ring) |
| `p` / `P` | Put after/before (Yanky-aware, supports cycling) |
| `<leader>p` | Open Telescope/Snacks picker over yank history `[Inference — exact picker depends on which picker extension Yanky is configured against]` |
| `<C-p>` (after a put, in insert-adjacent state) | Cycle to previous yank in history |
| `<C-n>` (after a put) | Cycle to next yank in history |
| `gp` / `gP` | Put and leave cursor after inserted text |
| `]p` / `[p` | Put with indentation adjusted to current line |

---

## 6. Rename — Inc-rename.nvim

| Key | Action |
|---|---|
| `<leader>cr` | Start incremental rename (LSP-backed, live preview across all references) |
| (while renaming) type new name, `<CR>` | Confirm rename |
| `<Esc>` | Cancel rename |

Inc-rename depends on active LSP attachment — it has no effect without a language server providing rename capability for the buffer.

---

## 7. Git — Gitsigns, Octo, Diffview

### Gitsigns (inline git decorations + hunk operations)

| Key | Action |
|---|---|
| `]h` / `[h` | Next/previous hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage entire buffer |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghR` | Reset entire buffer |
| `<leader>ghp` | Preview hunk (floating diff) |
| `<leader>ghb` | Blame line (floating) |
| `<leader>ghd` | Diff this file against index |
| `<leader>gtb` | Toggle current-line blame (virtual text) |
| `ih` (text object) | Select hunk (works with `d`, `y`, `v`, etc.) |

### Octo.nvim (GitHub issues/PRs inside Neovim)

| Command/Key | Action |
|---|---|
| `:Octo pr list` | List PRs |
| `:Octo pr checkout <number>` | Checkout a PR branch |
| `:Octo issue list` | List issues |
| `:Octo pr diff` | Show PR diff |
| `<leader>ca` (inside Octo PR buffer) | Add comment |
| `<leader>gr` | `[Inference]` — commonly bound to "start review" in Octo-heavy LazyVim configs |
| `:Octo review start` | Begin a formal review session |

### Diffview.nvim

| Command/Key | Action |
|---|---|
| `:DiffviewOpen` | Open diff view against HEAD (or specify a ref) |
| `:DiffviewClose` | Close diffview |
| `:DiffviewFileHistory` | Open file/commit history browser |
| `<tab>` (inside Diffview file panel) | Next diff |
| `<s-tab>` | Previous diff |
| `-` | Toggle stage/unstage entry (in file panel) |
| `cc` | Commit staged changes (opens commit message buffer) |

---

## 8. Testing — Neotest

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run all tests in current file |
| `<leader>ta` | Run entire test suite |
| `<leader>tl` | Re-run last test |
| `<leader>ts` | Toggle test summary panel |
| `<leader>to` | Show test output (floating) |
| `<leader>tO` | Toggle output panel (persistent) |
| `<leader>tS` | Stop running test |
| `<leader>tw` | Toggle watch mode for current file |

---

## 9. Debugging — nvim-dap (+ dap-ui, typically bundled)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Set conditional breakpoint (prompts for condition) |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last debug config |
| `<leader>du` | Toggle DAP UI (`[Inference]` — requires nvim-dap-ui, near-universal companion to nvim-dap) |
| `<leader>de` | Evaluate expression under cursor |
| `<leader>dt` | Terminate debug session |

---

## 10. Formatting — conform.nvim

| Key | Action |
|---|---|
| `<leader>cf` | Format buffer (or selection in visual mode) |
| Auto-format on save | Enabled by default in LazyVim if formatter is configured for filetype — no keybind needed, fires on `BufWritePre` |
| `:ConformInfo` | Show which formatters are active/detected for current buffer |

---

## 11. Linting — nvim-lint

| Key | Action |
|---|---|
| (no dedicated keybind by default) | Lint runs automatically on `BufWritePost`, `BufReadPost`, `InsertLeave` per LazyVim default autocmds |
| `:lua require("lint").try_lint()` | Manually trigger lint for current buffer |
| Diagnostics surface via | Standard `vim.diagnostic` UI — see LSP diagnostic keys below |

---

## 12. LSP Core (underlies Rename, Outline, Copilot-adjacent features) `[Inference — not in your list but structurally required]`

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Go to references (opens picker) |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename (delegates to Inc-rename if installed) |
| `]d` / `[d` | Next/previous diagnostic |
| `]e` / `[e` | Next/previous error specifically |
| `<leader>cd` | Line diagnostics (floating) |
| `<leader>cl` | LSP info |

---

## 13. Likely-Present Companions Not in Your List `[Inference]`

These are near-universal in modern LazyVim setups and interact directly with what you listed. Flagging so you can confirm/deny rather than assuming silently:

| Plugin | Why it's likely present | Key bindings |
|---|---|---|
| **Trouble.nvim** | Standard diagnostics/quickfix UI; pairs directly with nvim-lint + LSP diagnostics you already use | `<leader>xx` toggle diagnostics list, `<leader>xX` buffer diagnostics, `<leader>xL` location list, `<leader>xQ` quickfix list |
| **mini.ai** | Extended text objects (LazyVim default `extras.editor`); makes operators like `d`, `y`, `c` understand function/class boundaries | `af`/`if` (function), `ac`/`ic` (class) — used as text objects, not standalone keys |
| **mini.surround** | Add/change/delete surrounding pairs; extremely common default | `sa` (add), `sd` (delete), `sr` (replace) — note possible clash with Flash/Leap's `s` if not carefully scoped to specific modes |
| **mini.pairs** | Auto-closes brackets/quotes | No manual keys — automatic on insert |
| **Bufferline** | Tab-like buffer bar at top | `<leader>bp` pin buffer, `<leader>bd` delete buffer, `[b`/`]b` prev/next buffer |
| **Toggleterm** | Integrated terminal | `<C-\>` toggle terminal (default), `<leader>ft` terminal picker |
| **Persistence.nvim** | Session save/restore | `<leader>qs` restore session, `<leader>qS` select session, `<leader>ql` restore last session, `<leader>qd` don't save current session |
| **Noice.nvim** | Redesigned cmdline/messages/popup UI | Mostly passive; `<leader>sn` (Snacks-integrated notification history) common |

---

## 14. Workflow — How This Actually Composes

A realistic edit-test-debug-commit loop using your exact stack:

1. **Enter project** → `<leader><space>` (Snacks find files) or `<leader>fg` if you already know it's tracked in git.
2. **Jump around a file quickly** → `s` + two chars (Flash) rather than `/searchterm<CR>` for anything within visual range; Leap as fallback if you've resolved the `s`-key conflict noted above.
3. **Pin hot files** → `<leader>ha` (Harpoon2) for the 3-4 files you're actively bouncing between; then `<C-1>`–`<C-4>` instead of re-fuzzy-finding every time.
4. **Write code** → Blink surfaces completions on `<C-space>` or as-you-type; Copilot ghost-text suggestions layer underneath, accepted with `<Tab>` when no Blink menu is open.
5. **Refactor a symbol** → cursor on symbol, `<leader>cr` triggers Inc-rename, live-previews every reference before you commit the change.
6. **Check outline while refactoring a large file** → `<leader>cs` (Outline) to see the symbol tree without leaving context.
7. **Copy/paste across files** → Yanky's ring means you don't lose a yank when you grab something else before pasting; `<leader>p` (or your configured picker key) to pull an older yank back.
8. **Run the affected test** → cursor in test function, `<leader>tt` (Neotest) runs just that one; `<leader>to` if you need to see full output, not just pass/fail.
9. **Test fails, need to debug** → `<leader>db` to drop a breakpoint, `<leader>dc` to launch the debugger, step with `<leader>di`/`<leader>do`, inspect state via dap-ui panels.
10. **Review the diff before committing** → `<leader>ghp` (Gitsigns) for a quick per-hunk look, or `:DiffviewOpen` (Diffview) for the full-file/full-commit picture if changes are large.
11. **Stage selectively** → `<leader>ghs` per-hunk via Gitsigns, or the `-` toggle inside Diffview's file panel if working across many files.
12. **Push and open a PR without leaving the editor** → Octo (`:Octo pr create` or via GitHub CLI integration, config-dependent) to draft the PR, then `:Octo pr checkout` on a teammate's PR to review it directly.
13. **Diagnostics throughout** → nvim-lint fires silently on save/insert-leave; anything it (or LSP) flags surfaces via `]d`/`[d` or, if Trouble is present, `<leader>xx` for the aggregated list.

---

## 15. Things Worth Auditing In Your Actual Config

Since I can't see your `lazy.nvim` spec files directly, these are the concrete places your real bindings might diverge from the LazyVim defaults above:

- **Flash vs Leap `s`/`S` ownership** — check both plugin specs' `keys` tables; whichever loads second (or has explicit `keys` overrides) wins if both claim `s`.
- **Blink's keymap preset** — `"default"` vs `"super-tab"` vs `"enter"` changes whether `<Tab>` accepts completion, indents, or does nothing, which cascades into whether Copilot's `<Tab>`-accept ever actually fires.
- **Whether Copilot or Blink's own AI-source (if configured) owns ghost-text** — some setups route Copilot suggestions *through* Blink as a completion source rather than as separate ghost text, which changes the accept-key entirely.
- **Yanky's picker backend** — if you're on Snacks Picker (per your list) rather than Telescope, confirm Yanky's `extras.picker.telescope` isn't still loaded/conflicting; it should be pointed at Snacks or use its own default UI.

---

## 16. Window, Split & Tab Management (Native Vim)

| Key | Action |
|---|---|
| `<C-w>s` or `<leader>-` | Split horizontally |
| `<C-w>v` or `<leader>\|` | Split vertically |
| `<C-w>w` | Cycle to next window |
| `<C-w>h/j/k/l` | Move to window left/down/up/right |
| `<C-h/j/k/l>` | Same, unprefixed — LazyVim default direct window nav |
| `<C-w>q` | Close current window |
| `<C-w>o` | Close all other windows (keep only current) |
| `<C-w>=` | Equalize all window sizes |
| `<C-w>_` | Maximize height of current window |
| `<C-w>\|` | Maximize width of current window |
| `<C-Up/Down/Left/Right>` | Resize window incrementally |
| `<leader><tab>n` | New tab |
| `<leader><tab>c` | Close tab |
| `<leader><tab>o` | Close all other tabs |
| `[<tab>` / `]<tab>` | Previous/next tab |
| `gt` / `gT` | Native next/previous tab (always available) |

---

## 17. Marks, Jumplist & Changelist

| Key | Action |
|---|---|
| `ma` | Set mark `a` at cursor (any letter a-z for buffer-local, A-Z for global/cross-file) |
| `` `a `` | Jump to exact position of mark `a` |
| `'a` | Jump to line of mark `a` |
| `` `` `` | Jump to position before last jump (toggle back) |
| `<leader>sm` | `[Inference]` — Snacks Picker marks list, if configured |
| `<C-o>` | Jump back in jumplist (older position) |
| `<C-i>` (or `<Tab>` in normal mode) | Jump forward in jumplist |
| `g;` | Go to previous change (changelist) |
| `g,` | Go to next change (changelist) |
| `` `. `` | Jump to position of last change |

This layer is what Flash/Leap/Harpoon *sit on top of* — they're faster entry points, but marks and jumplist are the underlying mechanism, and `<C-o>`/`<C-i>` remain the fastest way to retrace steps regardless of which jump plugin got you there.

---

## 18. Registers & Macros

| Key | Action |
|---|---|
| `"ayy` | Yank current line into register `a` |
| `"ap` | Paste from register `a` |
| `qa` | Start recording macro into register `a` |
| `q` (while recording) | Stop recording |
| `@a` | Play macro from register `a` |
| `@@` | Repeat last-played macro |
| `5@a` | Play macro `a` five times |
| `:reg` | View contents of all registers |
| `"+y` | Yank into system clipboard register explicitly |
| `"0p` | Paste from yank register (register `0` always holds the last **yank**, unaffected by subsequent deletes — useful when Yanky's ring isn't handy) |
| `.` | Repeat last change — often faster than a macro for single-line repetition |

**Interaction with Yanky (section 5):** Yanky wraps `y`/`p` for its ring/history UI, but raw register access (`"a`, `"0`, `"+`) still works underneath and is often faster for one-off register targeting than opening the Yanky picker.

---

## 19. Folding

| Key | Action |
|---|---|
| `za` | Toggle fold under cursor |
| `zA` | Toggle fold and all nested folds under cursor |
| `zo` / `zc` | Open / close fold under cursor |
| `zR` | Open all folds in buffer |
| `zM` | Close all folds in buffer |
| `zj` / `zk` | Jump to next/previous fold |
| `zf` (visual mode) | Manually create fold from selection |

`[Inference]` — LazyVim defaults to Treesitter-based folding (`foldmethod=expr`, `foldexpr=nvim_treesitter#foldexpr()`), meaning folds align to actual code structure (functions, blocks) rather than indentation guesses. Useful specifically for the "unfamiliar codebase" SDLC task — collapse a file to `zM` then selectively `zo` into what matters.

---

## 20. Visual Block Mode & Multi-Cursor-Style Editing

| Key | Action |
|---|---|
| `<C-v>` | Enter visual block mode |
| `I` (in visual block, after selecting a column) | Insert text at start of block across all selected lines |
| `A` (in visual block) | Append text at end of block across all selected lines |
| `$` (in visual block) | Extend block to end of each line (handles ragged line lengths) |
| `c` (in visual block) | Change block — replace selection, applies to all lines on `<Esc>` |
| `r` (in visual block) | Replace each selected char with a single typed char |
| `<C-v>` + `g<C-a>` | Increment a column of numbers sequentially (visual block + increment) |

`[Inference — situational]`: If a dedicated multi-cursor plugin (`multicursor.nvim`, or a VS-Code-style multi-cursor emulation) is in your config, it typically binds something like `<C-n>` (select next match) / `<C-d>`-style behavior — but this is **not part of default LazyVim** and would need explicit confirmation. Native visual-block above is the zero-dependency equivalent for column-based edits; macros (section 18) or `:s` with a range (section 24) are the native equivalent for pattern-based multi-line edits. I'm not fabricating multi-cursor bindings without confirming the plugin is actually installed.

---

## 21. Treesitter — Incremental Selection & Text Objects

| Key | Action |
|---|---|
| `<CR>` (in normal mode, treesitter incremental-selection scope, if bound) | Init/expand selection to enclosing node |
| `<BS>` | Shrink selection to previous node |
| `<A-space>` | `[Inference]` — alternate scope-increment binding sometimes used instead of `<CR>` to avoid clashing with completion accept |

**Conflict flag:** Treesitter's default `init_selection`/`node_incremental` binding is commonly `<CR>` in some community configs, which directly collides with `<CR>` as Blink's completion-confirm key (section 2) and Inc-rename's confirm key (section 6) depending on mode context. LazyVim's actual default treesitter selection keys should be checked in your `treesitter` plugin spec's `incremental_selection.keymaps` table — this is one of the more commonly-remapped areas precisely because of this collision risk.

Text objects from mini.ai (flagged in section 13) extend standard `i`/`a` objects with treesitter awareness — `if`/`af` (function), `ic`/`ac` (class/conditional), `io`/`ao` (block) — usable directly as targets for `d`, `y`, `c`, `v` without a separate keypress to "enter" text-object mode.

---

## 22. Quickfix & Location List (Pre-Trouble, Foundational Layer)

| Key | Action |
|---|---|
| `:grep <pattern>` | Populate quickfix list via external grep |
| `:copen` | Open quickfix window |
| `:cclose` | Close quickfix window |
| `:cnext` / `:cprev` (or `]q` / `[q`) | Next/previous quickfix entry |
| `:cfirst` / `:clast` | Jump to first/last quickfix entry |
| `:lopen` | Open location list (buffer-local variant of quickfix) |
| `]l` / `[l` | Next/previous location-list entry |
| `<leader>xQ` | Trouble's UI wrapper around quickfix (section 13, restated for continuity) |
| `<leader>xL` | Trouble's UI wrapper around location list |

**Relationship to section 13's Trouble entry:** Trouble is a *rendering layer* over the same underlying quickfix/loclist data structure — anything that populates the raw quickfix list (LSP references via `gr`, `:grep`, Neotest failures in some configs) is immediately visible through Trouble's prettier UI too. They are not competing mechanisms; Trouble just makes the native list nicer to read and navigate.

---

## 23. Project-Wide Search & Structural Replace

### Native approach

| Command | Action |
|---|---|
| `:grep <pattern>` `<CR>` `:copen` | Classic grep-to-quickfix, then `:cdo s/old/new/g \| update` to apply a substitution across every quickfix match |
| `:cdo <command>` | Run an Ex command across every quickfix entry |
| `:bufdo <command>` | Run an Ex command across every open buffer |
| `:argdo <command>` | Run an Ex command across every file in the arglist |

### grug-far.nvim `[Inference — very common modern addition, not in your original list]`

| Key | Action |
|---|---|
| `<leader>sr` | Open Grug-far (search-and-replace UI) — note possible key collision with Snacks' `<leader>sr` "resume last search" from section 1; whichever is configured last wins, or LazyVim's extras system may have already resolved this — worth checking `:Telescope keymaps`-equivalent (Snacks' `<leader>sk`) to confirm actual binding |
| (inside Grug-far buffer) `<leader>r` | Execute replace-all across matched files |
| (inside Grug-far buffer) `<leader>q` | Send results to quickfix instead of replacing directly |

This fills a real gap: Snacks Picker's grep (section 1, `<leader>sg`) is excellent for *finding*, but doesn't give you a live-preview replace-across-files UI the way Grug-far or the older Spectre.nvim does. If your project touches more than a couple of files for a rename/pattern-change that LSP rename (section 6) can't handle because it's not a symbol (e.g., renaming a string literal, a config key, a comment pattern) — this is the tool for that specific job.

---

## 24. Command-Line / Ex-Mode Substitution (Foundational, Non-Plugin)

| Command | Action |
|---|---|
| `:s/old/new/` | Substitute first match on current line |
| `:s/old/new/g` | Substitute all matches on current line |
| `:%s/old/new/g` | Substitute all matches in entire buffer |
| `:%s/old/new/gc` | Same, with confirmation prompt per match |
| `:'<,'>s/old/new/g` | Substitute within visual selection (auto-populated range after `v`-selecting then `:`) |
| `:.,+5s/old/new/g` | Substitute in current line through 5 lines below |
| `&` | Repeat last `:s` substitution on current line |
| `g&` | Repeat last `:s` substitution across entire buffer with same flags |

This is the mechanism `:cdo`/`:bufdo`/`:argdo` in section 23 actually *execute* — worth knowing on its own since ad-hoc single-file substitutions are constant in day-to-day editing and don't need any list-population step first.

---

## 25. Snippets (LuaSnip or Blink's Native Snippet Engine)

| Key | Action |
|---|---|
| `<Tab>` (when snippet placeholder active, not completion menu) | Jump to next placeholder |
| `<S-Tab>` | Jump to previous placeholder |
| Trigger word + `<Tab>`/`<CR>` | Expand snippet (via completion menu selection, ties back into section 2) |

**Conflict flag, continued from section 3:** This is a *third* claimant on `<Tab>` behavior alongside Blink's menu-navigation and Copilot's suggestion-accept. The actual precedence in a working LazyVim config is typically: (1) if snippet jump is active, jump; (2) else if completion menu visible, select next item; (3) else if Copilot ghost text visible, accept; (4) else, insert literal tab/indent. This chain is usually wired through a single `<Tab>` handler function checking each condition in order — if you experience `<Tab>` doing something unexpected, this priority chain in your `blink.cmp` or `luasnip` keymap config is where to look.

---

## 26. HTTP/REST Client Workflows `[Inference — situational, common for backend/API-heavy SDLC work]`

If `kulala.nvim` or `rest.nvim` is present (typical when engineers want to avoid switching to Postman for quick API checks):

| Key | Action |
|---|---|
| `<leader>rr` | Run request under cursor (in a `.http` file) |
| `<leader>rp` | Preview/toggle response panel |
| `<leader>rh` | View request history |

Not part of default LazyVim — flagging because "full SDLC" explicitly includes API testing/integration work, and this is the editor-native equivalent for engineers who prefer not to context-switch to a separate HTTP client app.

---

## 27. Database Inspection `[Inference — situational]`

If `vim-dadbod` + `dadbod-ui` is present:

| Key | Action |
|---|---|
| `<leader>D` | Toggle DB UI panel |
| `<CR>` (on a saved query/connection in DB UI) | Execute query / connect |

Flagging as optional rather than assumed — this is a specialized addition for engineers doing frequent direct DB inspection from the editor rather than a separate DB client.

---

## 28. Documentation & Markdown Authoring

| Key | Action |
|---|---|
| `gx` (cursor on a URL/link) | Open link in system browser (native Vim/Neovim, works regardless of filetype) |
| `<leader>cp` | `[Inference]` — common binding for toggling markdown preview if `render-markdown.nvim` or a similar previewer is active |
| `]]` / `[[` | Next/previous markdown heading (if configured) |

`render-markdown.nvim` specifically renders markdown *inline* in the buffer (headers styled, checkboxes rendered as actual checkboxes, code blocks bordered) rather than requiring a separate browser-based preview — increasingly the default choice over older `markdown-preview.nvim` (which opens an actual browser tab).

Real SDLC relevance: README updates, ADRs (architecture decision records), inline code comments that render as markdown in doc-comment tooltips (`K` from section 12 often renders markdown from docstrings/JSDoc/etc.).

---

## 29. Code Review Mechanics (Extending Octo, Section 7)

Section 7 covered PR listing/checkout/diff. Review-specific actions not yet covered:

| Command/Key | Action |
|---|---|
| `:Octo review start` | Enter review mode (restated from section 7 for grouping) |
| `<leader>ca` (on a specific diff line, inside review mode) | Add inline comment on that exact line |
| `:Octo review submit` | Submit accumulated review comments as a single review (approve/request-changes/comment) |
| `]c` / `[c` (inside Octo review diff) | Next/previous comment thread |
| `<leader>rr` | `[Inference]` — possible collision with section 26's REST-client binding if both plugins are active; verify against your actual `keys` table if you use both Octo review and an HTTP client |
| `:Octo pr ready` | Mark draft PR as ready for review |
| `:Octo pr merge` | Merge PR directly from editor (commonly requires confirmation) |

---

## 30. Project/Workspace Switching `[Inference — situational, relevant for multi-repo engineers]`

If `project.nvim`, Snacks' own project-picker module, or similar is configured:

| Key | Action |
|---|---|
| `<leader>fp` | Find/switch project (jumps `cwd`, often re-triggers LSP root detection) |

Distinct from section 1's `<leader>ff`/file-finding — this operates one level up, switching *which repo* you're even searching within. Relevant for engineers who bounce between multiple services/repos in a single day rather than living inside one monorepo.

---

## 31. LSP — Workspace-Level & Maintenance Actions (Extending Section 12)

| Key/Command | Action |
|---|---|
| `<leader>sS` | `[Inference]` — workspace symbols search (distinct from buffer-local outline in section 1's Outline plugin) — searches symbol names across the *entire* project, not just current file |
| `:LspInfo` | Show attached LSP clients for current buffer |
| `:LspRestart` | Restart LSP client(s) — common fix when a language server hangs or gets into a bad state after a large refactor |
| `:LspLog` | Open LSP log file for debugging server-communication issues |
| `<leader>cA` | `[Inference]` — some configs distinguish `<leader>ca` (code action, section 12) from a capital-A variant scoped to source-wide actions (e.g., "organize imports") vs line-local ones |

---

## 32. Explicit Scope Boundary: What Neovim Does *Not* Cover

Being direct about this rather than padding the cheatsheet: the following are genuinely part of "full SDLC" but are **not editor-native concerns**, and any keybind I gave you for them would be fabricated:

- **CI/CD pipeline execution** (GitHub Actions, Jenkins, etc.) — Neovim can open/edit the YAML config files (treated as any other file, LSP/formatting/linting apply if a language server for YAML/Actions schema is configured), and Octo *may* surface PR check-status inline, but there's no native "run the pipeline" keybind — that's the CI provider's UI/CLI.
- **Deployment** — outside editor scope entirely; typically driven from a separate terminal/CLI tool, which Toggleterm (section 13) gives you fast access to, but the deployment tool itself has its own commands, not Neovim keybinds.
- **Infrastructure-as-code execution** (`terraform apply`, etc.) — same as above; files are edited normally, execution happens via terminal.
- **Container/orchestration management** (Docker, Kubernetes) — some engineers add dedicated plugins for this (`docker.nvim`- style tools exist but are far less standardized/common than everything else in this document), so I'm explicitly not fabricating a keybind table for something I have no confirmation you actually use.

---

## 33. Revised End-to-End Workflow (Cheatsheets 1 + 2 Combined)

The complete loop, now including everything above:

1. **Switch into the right repo** → `<leader>fp` (project switch, section 30) if multi-repo, otherwise skip straight to file-finding.
2. **Orient in an unfamiliar file** → `zM` to collapse all folds (section 19), selectively `zo` into relevant sections, `<leader>cs` for Outline (cheatsheet 1) if the fold-collapsed view still isn't enough structure.
3. **Search across the whole project for a pattern** → `<leader>sg` (Snacks grep, cheatsheet 1) to *find*; if it needs *replacing* across many files and isn't a clean LSP-symbol rename, `<leader>sr` for Grug-far (section 23) instead of manual `:cdo`.
4. **Navigate within a file** → Flash/Leap (cheatsheet 1) for visual jumps; marks (`ma`, `` `a ``, section 17) for "I'll be back here" anchors that outlive a single edit session, unlike Harpoon's more curated file-level pins.
5. **Make a repetitive edit across similar lines** → macro (`qa...q`, `@a`, section 18) if the pattern is irregular; visual-block `<C-v>` + `I`/`A`/`c` (section 20) if it's genuinely columnar; `:%s///g` (section 24) if it's a clean textual substitution.
6. **Refactor a symbol** → Inc-rename (cheatsheet 1, `<leader>cr`) if it's a true LSP-aware symbol; falls through to Grug-far/`:cdo` (section 23) the moment it's a string literal or non-symbol text the LSP doesn't track.
7. **Write/expand boilerplate** → snippet trigger + `<Tab>`-jump between placeholders (section 25), Copilot ghost-text for anything more contextual (cheatsheet 1, section 3).
8. **Check a function's actual usages before changing its signature** → `gr` (section 12) populates quickfix/reference-picker; `<leader>xQ` (Trouble, section 22) if you want the prettier persistent-list view instead of the transient picker.
9. **Test the change** → Neotest (cheatsheet 1) exactly as before; if it's an API-layer change, `<leader>rr` (section 26, if HTTP client present) to hit the actual endpoint directly rather than only relying on unit tests.
10. **Debug a failure** → nvim-dap (cheatsheet 1) as before; `<leader>D` (section 27, if dadbod present) to check actual DB state mid-debug if the bug is data-shaped rather than logic-shaped.
11. **Review the diff** → Gitsigns hunks or Diffview (cheatsheet 1) as before.
12. **Document the change** → update README/ADR with markdown preview active (section 28) so formatting is verified before commit, not after.
13. **Commit, push, open PR** → Octo (cheatsheet 1 + section 29 review mechanics) for the full PR lifecycle including inline review comments if you're reviewing a teammate's change instead of authoring your own.
14. **Everything CI/deploy-related** → hands off to terminal (Toggleterm) or external tooling — explicitly outside what Neovim itself does (section 32).

---

## 34. Audit Checklist — Part 2 Additions

Extending section 15's audit list with the new conflict points surfaced in this document:

- **`<CR>` collision** between Blink completion-confirm (section 2), Inc-rename confirm (section 6), and Treesitter incremental-selection init (section 21) — three different modal contexts, but confirm your config's actual precedence if any of them ever "does the wrong thing."
- **`<Tab>` priority chain** (section 25) — snippet-jump vs completion-select vs Copilot-accept vs literal-indent; four claimants, one key, resolved by an ordered check in your keymap function.
- **`<leader>sr`** — Snacks' "resume last picker" (cheatsheet 1, section 1) vs Grug-far's "search-replace" (section 23) — genuinely likely to collide if both are configured with LazyVim's suggested defaults verbatim; check which one actually fires.
- **`<leader>rr`** — potential collision between an HTTP-client's "run request" (section 26) and Octo review's binding (section 29) if both plugins happen to claim the same mnemonic.
- **Multi-cursor absence** — section 20 explicitly did not fabricate multi-cursor plugin bindings; confirm whether such a plugin is actually in your spec before assuming those keys exist.

**[Unverified]** As with Part 1, everything here reflects common/default LazyVim and companion-plugin behavior. Sections marked `[Inference]` are plugins/bindings I flagged as *likely present given your stated stack and "not limited to the above" instruction*, not confirmed from your actual config files — cross-check against your `lua/plugins/*.lua` specs, particularly anywhere you've defined custom `keys` tables, since those silently override everything documented here.