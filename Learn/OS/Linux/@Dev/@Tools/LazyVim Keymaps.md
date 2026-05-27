# ⌨️ LazyVim Keymaps - Organized by Workflow

> **Purpose:** This document reorganizes LazyVim keymaps by practical workflow frequency instead of plugin categories. The most common editing workflows appear first.
> 
> **Default Leader:** `<space>` | **Default Localleader:** `\`

---

## 🧭 Movement & Window Navigation

### Cursor Movement

|Key|Description|Mode|
|---|---|---|
|`j` / `k`|Down / Up|**n**, **x**|
|`<Down>` / `<Up>`|Down / Up (Alternative)|**n**, **x**|
|`<A-j>` / `<A-k>`|Move Line Down / Up|**n**, **i**, **v**|

### Window Navigation & Resizing

|Key|Description|Mode|
|---|---|---|
|`<C-h>` / `<C-j>` / `<C-k>` / `<C-l>`|Go to Left / Lower / Upper / Right Window|**n**|
|`<C-Up>` / `<C-Down>`|Increase / Decrease Window Height|**n**|
|`<C-Left>` / `<C-Right>`|Decrease / Increase Window Width|**n**|
|`<leader>-`|Split Window Below|**n**|
|`<leader>\|`|Split Window Right|**n**|
|`<leader>wd`|Delete Window|**n**|
|`<leader>wm`|Toggle Zoom Mode|**n**|
|`<c-w><space>`|Window Hydra Mode (which-key)|**n**|

### Flash / Quick Motion (Jump to Any Location)

|Key|Description|Mode|
|---|---|---|
|`s`|Flash (jump to any visible text)|**n**, **o**, **x**|
|`S`|Flash Treesitter (jump within syntax nodes)|**n**, **o**, **x**|
|`gs`|Leap from Windows (with Leap)|**n**, **o**, **x**|
|`r`|Remote Flash (in operator-pending mode)|**o**|

### Search Navigation

|Key|Description|Mode|
|---|---|---|
|`n` / `N`|Next / Previous Search Result|**n**, **x**, **o**|

---

## 🔍 Finding & Opening Files

**One of the most frequently used workflows**

### File Finder & Buffers (Snacks / Picker)

|Key|Description|Mode|
|---|---|---|
|`<leader><space>`|Find Files (Root Dir) — **MOST COMMON**|**n**|
|`<leader>,`|Buffers (Switch open buffers)|**n**|
|`<leader>/`|Grep (Root Dir) — Search file contents|**n**|
|`<leader>ff`|Find Files (Root Dir) — Explicit|**n**|
|`<leader>fF`|Find Files (cwd)|**n**|
|`<leader>fg`|Find Files (git-files only)|**n**|
|`<leader>fb`|Buffers|**n**|
|`<leader>fB`|Buffers (all)|**n**|
|`<leader>fr`|Recent Files|**n**|
|`<leader>fR`|Recent Files (cwd)|**n**|
|`<leader>fc`|Find Config File|**n**|

### File/Explorer Management

|Key|Description|Mode|
|---|---|---|
|`<leader>e`|Explorer (root dir)|**n**|
|`<leader>E`|Explorer (cwd)|**n**|
|`<leader>fm`|mini.files (Current File Directory)|**n**|
|`<leader>fM`|mini.files (cwd)|**n**|
|`<leader>fn`|New File|**n**|

### Search Variations

|Key|Description|Mode|
|---|---|---|
|`<leader>sg`|Grep (Root Dir)|**n**|
|`<leader>sG`|Grep (cwd)|**n**|
|`<leader>sw`|Grep Visual Selection or Word (Root Dir)|**n**, **x**|
|`<leader>sW`|Grep Visual Selection or Word (cwd)|**n**, **x**|
|`<leader>sB`|Grep Open Buffers|**n**|

---

## ✏️ Editing & Text Manipulation

**Core editing operations done hundreds of times per session**

### Yanking (Copy), Pasting & Register History

|Key|Description|Mode|
|---|---|---|
|`y`|Yank Text (with yanky.nvim history)|**n**, **x**|
|`p` / `P`|Put Text After / Before Cursor|**n**, **x**|
|`gp` / `gP`|Put Text After / Before Selection|**n**, **x**|
|`<leader>p`|Open Yank History|**n**, **x**|
|`[y` / `]y`|Cycle Forward / Backward Through Yank History|**n**|
|`<leader>s"`|Registers|**n**|
|`>p` / `>P`|Put and Indent Right|**n**|
|`<p` / `<P`|Put and Indent Left|**n**|
|`=p` / `=P`|Put After / Before Applying a Filter|**n**|

### Surrounding Text (mini.surround)

|Key|Description|Mode|
|---|---|---|
|`gsa`|Add Surrounding|**n**, **x**|
|`gsd`|Delete Surrounding|**n**|
|`gsr`|Replace Surrounding|**n**|
|`gsh`|Highlight Surrounding|**n**|
|`gsf` / `gsF`|Find Right / Left Surrounding|**n**|
|`gsn`|Update `MiniSurround.config.n_lines`|**n**|
|`gz`|+surround (with Leap extra)|**n**|

### Comments

|Key|Description|Mode|
|---|---|---|
|`gco`|Add Comment Below|**n**|
|`gcO`|Add Comment Above|**n**|

### Increment/Decrement (dial.nvim)

|Key|Description|Mode|
|---|---|---|
|`<C-a>`|Increment|**n**, **v**|
|`<C-x>`|Decrement|**n**, **v**|
|`g<C-a>` / `g<C-x>`|Increment / Decrement (Sequential)|**n**, **x**|

### Formatting & Cleanup

|Key|Description|Mode|
|---|---|---|
|`<leader>cf`|Format Document|**n**, **x**|
|`<leader>cF`|Format Injected Languages|**n**, **x**|

---

## 🔄 Search & Replace

### Search & Replace (grug-far.nvim)

|Key|Description|Mode|
|---|---|---|
|`<leader>sr`|Search and Replace|**n**, **x**|
|`<c-s>`|Toggle Flash Search (in command mode)|**c**|

### Search History & Command History

|Key|Description|Mode|
|---|---|---|
|`<leader>s/`|Search History|**n**|
|`<leader>:`|Command History|**n**|
|`<leader>sc`|Command History (Alternative)|**n**|

---

## 🌳 Git & Version Control

### Git Status, Diff & Hunks

|Key|Description|Mode|
|---|---|---|
|`<leader>gs`|Git Status|**n**|
|`<leader>gd`|Git Diff (hunks)|**n**|
|`<leader>gD`|Git Diff (origin)|**n**|
|`<leader>go`|Toggle mini.diff overlay|**n**|

### Git Log, Blame & History

|Key|Description|Mode|
|---|---|---|
|`<leader>gl`|Git Log (current file)|**n**|
|`<leader>gL`|Git Log (cwd)|**n**|
|`<leader>gb`|Git Blame Line|**n**|
|`<leader>gf`|Git Current File History|**n**|

### Git Browse & GitHub Integration

|Key|Description|Mode|
|---|---|---|
|`<leader>gB`|Git Browse (open in browser)|**n**, **x**|
|`<leader>gY`|Git Browse (copy URL)|**n**, **x**|
|`<leader>gi`|GitHub Issues (open) / List Issues (Octo)|**n**|
|`<leader>gI`|GitHub Issues (all) / Search Issues (Octo)|**n**|
|`<leader>gp`|GitHub Pull Requests (open) / List PRs (Octo)|**n**|
|`<leader>gP`|GitHub Pull Requests (all) / Search PRs (Octo)|**n**|
|`<leader>gr`|List Repos (Octo)|**n**|
|`<leader>gS`|Git Stash / Search (Octo)|**n**|

### Git Tools

|Key|Description|Mode|
|---|---|---|
|`<leader>gg`|GitUI (Root Dir)|**n**|
|`<leader>gG`|GitUI (cwd)|**n**|

---

## 💡 LSP & Code Intelligence

**Daily workflows for code navigation and manipulation**

### Core Navigation

|Key|Description|Mode|
|---|---|---|
|`gd`|Goto Definition|**n**|
|`gr`|References (Show all references)|**n**|
|`gI`|Goto Implementation|**n**|
|`gy`|Goto Type Definition|**n**|
|`gD`|Goto Declaration|**n**|
|`[[` / `]]`|Prev / Next Reference|**n**|
|`<a-p>` / `<a-n>`|Prev / Next Reference (Alternative)|**n**|

### Hover, Signature & Help

|Key|Description|Mode|
|---|---|---|
|`K`|Hover (Documentation, type info)|**n**|
|`gK`|Signature Help|**n**|
|`<c-k>`|Signature Help (Insert mode)|**i**|
|`<leader>K`|Keywordprg (Custom help lookup)|**n**|

### Code Actions & Refactoring

|Key|Description|Mode|
|---|---|---|
|`<leader>ca`|Code Action (Quick fix, suggestions)|**n**, **x**|
|`<leader>cA`|Source Action (Organize imports, etc)|**n**|
|`<leader>cr`|Rename Symbol|**n**|
|`<leader>cR`|Rename File|**n**|
|`<leader>co`|Organize Imports|**n**|

### Symbols & Navigation

|Key|Description|Mode|
|---|---|---|
|`<leader>ss`|LSP Symbols (Current file)|**n**|
|`<leader>sS`|LSP Workspace Symbols|**n**|
|`<leader>cs`|Symbols (Trouble) / Toggle Outline|**n**|
|`<leader>cS`|LSP references/definitions/... (Trouble)|**n**|

### Codelens & Calls

|Key|Description|Mode|
|---|---|---|
|`<leader>cc`|Run Codelens|**n**, **x**|
|`<leader>cC`|Refresh & Display Codelens|**n**|
|`gai`|Calls Incoming|**n**|
|`gao`|Calls Outgoing|**n**|

### LSP Info & Mason

|Key|Description|Mode|
|---|---|---|
|`<leader>cl`|LSP Info|**n**|
|`<leader>cm`|Mason (Install/manage tools)|**n**|

---

## 📋 Buffer & Tab Management

### Buffer Navigation

|Key|Description|Mode|
|---|---|---|
|`<S-h>` / `<S-l>`|Previous / Next Buffer|**n**|
|`[b` / `]b`|Previous / Next Buffer|**n**|
|`<leader>bb`|Switch to Other Buffer|**n**|
|`` <leader>` ``|Switch to Other Buffer (Alternative)|**n**|
|`<leader>,`|Buffers (Open picker)|**n**|

### Buffer Operations

|Key|Description|Mode|
|---|---|---|
|`<leader>bd`|Delete Buffer|**n**|
|`<leader>bD`|Delete Buffer and Window|**n**|
|`<leader>bo`|Delete Other Buffers|**n**|
|`<leader>bj`|Pick Buffer|**n**|

### Buffer Pin & Organize

|Key|Description|Mode|
|---|---|---|
|`<leader>bp`|Toggle Pin Buffer|**n**|
|`<leader>bP`|Delete Non-Pinned Buffers|**n**|
|`[B` / `]B`|Move Buffer Previous / Next|**n**|
|`<leader>bl`|Delete Buffers to the Left|**n**|
|`<leader>br`|Delete Buffers to the Right|**n**|

### Tab Management

|Key|Description|Mode|
|---|---|---|
|`<leader><tab><tab>`|New Tab|**n**|
|`<leader><tab>d`|Close Tab|**n**|
|`<leader><tab>]` / `<leader><tab>[`|Next / Previous Tab|**n**|
|`<leader><tab>f` / `<leader><tab>l`|First / Last Tab|**n**|
|`<leader><tab>o`|Close Other Tabs|**n**|

---

## 🔴 Diagnostics & Issues

### Diagnostic Navigation

|Key|Description|Mode|
|---|---|---|
|`]d` / `[d`|Next / Previous Diagnostic|**n**|
|`]e` / `[e`|Next / Previous Error|**n**|
|`]w` / `[w`|Next / Previous Warning|**n**|

### Diagnostic Display

|Key|Description|Mode|
|---|---|---|
|`<leader>cd`|Line Diagnostics|**n**|
|`<leader>xx`|Diagnostics (Trouble)|**n**|
|`<leader>xX`|Buffer Diagnostics (Trouble)|**n**|

### Quickfix & Location Lists

|Key|Description|Mode|
|---|---|---|
|`]q` / `[q`|Next / Previous Quickfix|**n**|
|`<leader>xq`|Quickfix List|**n**|
|`<leader>xQ`|Quickfix List (Trouble)|**n**|
|`<leader>xl`|Location List|**n**|
|`<leader>xL`|Location List (Trouble)|**n**|

---

## 🎚️ UI Toggles & Settings

### Visibility Toggles

|Key|Description|Mode|
|---|---|---|
|`<leader>uf`|Toggle Auto Format (Global)|**n**|
|`<leader>uF`|Toggle Auto Format (Buffer)|**n**|
|`<leader>us`|Toggle Spelling|**n**|
|`<leader>uw`|Toggle Wrap|**n**|
|`<leader>ud`|Toggle Diagnostics|**n**|
|`<leader>ul`|Toggle Line Numbers|**n**|
|`<leader>uL`|Toggle Relative Number|**n**|
|`<leader>uc`|Toggle Conceal Level|**n**|

### UI & Theme

|Key|Description|Mode|
|---|---|---|
|`<leader>ub`|Toggle Dark Background|**n**|
|`<leader>uC`|Colorschemes|**n**|
|`<leader>uD`|Toggle Dimming|**n**|
|`<leader>ua`|Toggle Animations|**n**|
|`<leader>uA`|Toggle Tabline|**n**|
|`<leader>uT`|Toggle Treesitter Highlight|**n**|
|`<leader>ug`|Toggle Indent Guides|**n**|
|`<leader>uS`|Toggle Smooth Scroll|**n**|
|`<leader>uz`|Toggle Zen Mode|**n**|
|`<leader>uZ`|Toggle Zoom Mode|**n**|

### Debugging & Inspector

|Key|Description|Mode|
|---|---|---|
|`<leader>ui`|Inspect Pos|**n**|
|`<leader>uI`|Inspect Tree|**n**|
|`<leader>uh`|Toggle Inlay Hints|**n**|
|`<leader>dpp`|Toggle Profiler|**n**|
|`<leader>dph`|Toggle Profiler Highlights|**n**|

### Editor UI

|Key|Description|Mode|
|---|---|---|
|`<leader>ue`|Edgy Toggle|**n**|
|`<leader>uE`|Edgy Select Window|**n**|
|`<leader>n`|Notification History|**n**|
|`<leader>un`|Dismiss All Notifications|**n**|

---

## 🧪 Testing & Debugging

### Testing (Neotest)

|Key|Description|Mode|
|---|---|---|
|`<leader>tt`|Run File (Neotest)|**n**|
|`<leader>tr`|Run Nearest (Neotest)|**n**|
|`<leader>tl`|Run Last (Neotest)|**n**|
|`<leader>tT`|Run All Test Files (Neotest)|**n**|
|`<leader>ta`|Attach to Test (Neotest)|**n**|
|`<leader>ts`|Toggle Summary (Neotest)|**n**|
|`<leader>tO`|Toggle Output Panel (Neotest)|**n**|
|`<leader>to`|Show Output (Neotest)|**n**|
|`<leader>tS`|Stop (Neotest)|**n**|
|`<leader>tw`|Toggle Watch (Neotest)|**n**|

### Debugging (nvim-dap)

|Key|Description|Mode|
|---|---|---|
|`<leader>dc`|Run/Continue|**n**|
|`<leader>db`|Toggle Breakpoint|**n**|
|`<leader>dB`|Breakpoint Condition|**n**|
|`<leader>di`|Step Into|**n**|
|`<leader>dO`|Step Over|**n**|
|`<leader>do`|Step Out|**n**|
|`<leader>dC`|Run to Cursor|**n**|
|`<leader>dg`|Go to Line (No Execute)|**n**|
|`<leader>dj`|Down|**n**|
|`<leader>dk`|Up|**n**|
|`<leader>dr`|Toggle REPL|**n**|
|`<leader>dl`|Run Last|**n**|
|`<leader>da`|Run with Args|**n**|
|`<leader>dP`|Pause|**n**|
|`<leader>dt`|Terminate|**n**|
|`<leader>ds`|Session|**n**|
|`<leader>dw`|Widgets|**n**|
|`<leader>du`|Dap UI|**n**|
|`<leader>de`|Eval|**n**, **x**|
|`<leader>td`|Debug Nearest (Neotest)|**n**|

---

## 📝 Snippets, Annotations & Documentation

### Documentation

|Key|Description|Mode|
|---|---|---|
|`<leader>cn`|Generate Annotations (Neogen)|**n**|
|`<leader>cp`|Markdown Preview|**n**|

### Refactoring

|Key|Description|Mode|
|---|---|---|
|`<leader>r`|+refactor|**n**, **x**|
|`<leader>rs`|Select Refactor|**n**, **x**|
|`<leader>rf`|Extract Function|**n**, **x**|
|`<leader>rF`|Extract Function To File|**n**, **x**|
|`<leader>rx`|Extract Variable|**n**, **x**|
|`<leader>ri`|Inline Variable|**n**, **x**|
|`<leader>rp`|Debug Print Variable|**n**, **x**|
|`<leader>rP`|Debug Print Location|**n**|
|`<leader>rc`|Debug Cleanup|**n**|

---

## 🤖 AI Tools & Assistants

### Avante (Claude/OpenAI)

|Key|Description|Mode|
|---|---|---|
|`<leader>aa`|Ask Avante|**n**|
|`<leader>ac`|Chat with Avante|**n**|
|`<leader>ae`|Edit Avante|**n**|
|`<leader>af`|Focus Avante|**n**|
|`<leader>ah`|Avante History|**n**|
|`<leader>am`|Select Avante Model|**n**|
|`<leader>an`|New Avante Chat|**n**|
|`<leader>ap`|Switch Avante Provider|**n**|
|`<leader>ar`|Refresh Avante|**n**|
|`<leader>as`|Stop Avante|**n**|
|`<leader>at`|Toggle Avante|**n**|

### Claude Code

|Key|Description|Mode|
|---|---|---|
|`<leader>a`|+ai|**n**, **v**|
|`<leader>aa`|Accept diff|**n**|
|`<leader>ad`|Deny diff|**n**|
|`<leader>ab`|Add current buffer|**n**|
|`<leader>as`|Add file / Send to Claude|**n**, **v**|
|`<leader>ac`|Toggle Claude|**n**|
|`<leader>aC`|Continue Claude|**n**|
|`<leader>af`|Focus Claude|**n**|
|`<leader>ar`|Resume Claude|**n**|

### Copilot Chat

|Key|Description|Mode|
|---|---|---|
|`<leader>a`|+ai|**n**, **x**|
|`<leader>aa`|Toggle (CopilotChat)|**n**, **x**|
|`<leader>aq`|Quick Chat (CopilotChat)|**n**, **x**|
|`<leader>ap`|Prompt Actions (CopilotChat)|**n**, **x**|
|`<leader>ax`|Clear (CopilotChat)|**n**, **x**|
|`<c-s>`|Submit Prompt|**n**|

### Sidekick

|Key|Description|Mode|
|---|---|---|
|`<leader>a`|+ai|**n**, **v**|
|`<leader>aa`|Sidekick Toggle CLI|**n**|
|`<leader>ad`|Detach a CLI Session|**n**|
|`<leader>af`|Send File|**n**|
|`<leader>ap`|Sidekick Select Prompt|**n**, **x**|
|`<leader>as`|Select CLI|**n**|
|`<leader>at`|Send This|**n**, **x**|
|`<leader>av`|Send Visual Selection|**x**|
|`<c-.>`|Sidekick Focus|**n**, **i**, **t**, **x**|

---

## 🛠️ Specialized (Language/Plugin Extras)

### Projects & Navigation

|Key|Description|Mode|
|---|---|---|
|`<leader>fp`|Projects|**n**|
|`<leader>fT`|Terminal (cwd)|**n**|
|`<leader>ft`|Terminal (Root Dir)|**n**|
|`<c-/>`|Terminal (Root Dir)|**n**, **t**|

### Harpoon (Quick File Navigation)

|Key|Description|Mode|
|---|---|---|
|`<leader>1` through `<leader>9`|Harpoon to File 1-9|**n**|
|`<leader>h`|Harpoon Quick Menu|**n**|
|`<leader>H`|Harpoon File|**n**|

### Scratch & History

|Key|Description|Mode|
|---|---|---|
|`<leader>.`|Toggle Scratch Buffer|**n**|
|`<leader>S`|Select Scratch Buffer|**n**|
|`<leader>.dps`|Profiler Scratch Buffer|**n**|
|`<leader>su`|Undotree|**n**|
|`<leader>sj`|Jumps|**n**|
|`<leader>sm`|Marks|**n**|

### Search Helpers

|Key|Description|Mode|
|---|---|---|
|`<leader>sb`|Buffer Lines|**n**|
|`<leader>sd`|Diagnostics|**n**|
|`<leader>sD`|Buffer Diagnostics|**n**|
|`<leader>sh`|Help Pages|**n**|
|`<leader>sH`|Highlights|**n**|
|`<leader>si`|Icons|**n**|
|`<leader>sk`|Keymaps|**n**|
|`<leader>sM`|Man Pages|**n**|
|`<leader>sp`|Search for Plugin Spec|**n**|
|`<leader>sR`|Resume|**n**|
|`<leader>sa`|Autocmds|**n**|
|`<leader>sC`|Commands|**n**|

### Todo Comments

|Key|Description|Mode|
|---|---|---|
|`<leader>st`|Todo|**n**|
|`<leader>sT`|Todo/Fix/Fixme|**n**|
|`<leader>xt`|Todo (Trouble)|**n**|
|`<leader>xT`|Todo/Fix/Fixme (Trouble)|**n**|
|`[t` / `]t`|Previous / Next Todo Comment|**n**|

### Notifications & Noice

|Key|Description|Mode|
|---|---|---|
|`<c-b>` / `<c-f>`|Scroll Backward / Forward|**n**, **i**, **s**|
|`<leader>sn`|+noice|**n**|
|`<leader>sna`|Noice All|**n**|
|`<leader>snd`|Dismiss All|**n**|
|`<leader>snh`|Noice History|**n**|
|`<leader>snl`|Noice Last Message|**n**|
|`<leader>snt`|Noice Picker (Telescope/FzfLua)|**n**|
|`<S-Enter>`|Redirect Cmdline|**c**|

### Session Management

|Key|Description|Mode|
|---|---|---|
|`<leader>qs`|Restore Session|**n**|
|`<leader>qS`|Select Session|**n**|
|`<leader>ql`|Restore Last Session|**n**|
|`<leader>qd`|Don't Save Current Session|**n**|

### REST Client (kulala.nvim)

|Key|Description|Mode|
|---|---|---|
|`<leader>R`|+Rest|**n**|
|`<leader>Rs`|Send the request|**n**|
|`<leader>Rr`|Replay the last request|**n**|
|`<leader>Rn`|Jump to next request|**n**|
|`<leader>Rp`|Jump to previous request|**n**|
|`<leader>Rb`|Open scratchpad|**n**|
|`<leader>Rc`|Copy as cURL|**n**|
|`<leader>RC`|Paste from curl|**n**|
|`<leader>Re`|Set environment|**n**|
|`<leader>Rg`|Download GraphQL schema|**n**|
|`<leader>Ri`|Inspect current request|**n**|
|`<leader>Rt`|Toggle headers/body|**n**|
|`<leader>RS`|Show stats|**n**|
|`<leader>Rq`|Close window|**n**|

### SQL (dadbod-ui)

|Key|Description|Mode|
|---|---|---|
|`<leader>D`|Toggle DBUI|**n**|

### Tasks & Overseer

|Key|Description|Mode|
|---|---|---|
|`<leader>oo`|Run task|**n**|
|`<leader>ot`|Task action|**n**|
|`<leader>ow`|Task list|**n**|

### Python-Specific

|Key|Description|Mode|
|---|---|---|
|`<leader>cv`|Select VirtualEnv|**n**|
|`<leader>dPc`|Debug Class|**n**|
|`<leader>dPt`|Debug Method|**n**|

### Ansible

|Key|Description|Mode|
|---|---|---|
|`<leader>ta`|Ansible Run Playbook/Role|**n**|

### Scala

|Key|Description|Mode|
|---|---|---|
|`<leader>mc`|Metals compile cascade|**n**|
|`<leader>me`|Metals commands|**n**|
|`<leader>mh`|Metals hover worksheet|**n**|

### Haskell

|Key|Description|Mode|
|---|---|---|
|`<localleader>r`|REPL (Package)|**n**|
|`<localleader>R`|REPL (Buffer)|**n**|
|`<localleader>e`|Evaluate All|**n**|
|`<localleader>h`|Hoogle Signature|**n**|
|`<localleader>H`|Hoogle|**n**|

### LaTeX & Markup

|Key|Description|Mode|
|---|---|---|
|`<localLeader>l`|+vimtex|**n**|
|`<leader>cp`|Toggle Typst Preview|**n**|

### Chezmoi

|Key|Description|Mode|
|---|---|---|
|`<leader>sz`|Chezmoi|**n**|

### GitHub Integration (gh.nvim)

|Key|Description|Mode|
|---|---|---|
|`<leader>G`|+Github|**n**|
|`<leader>Gc`|+Commits|**n**|
|`<leader>Gi`|+Issues|**n**|
|`<leader>Gp`|+Pull Request|**n**|
|`<leader>Gr`|+Review|**n**|
|`<leader>Gt`|+Threads|**n**|

---

## ⚙️ General Utilities

### File Operations

|Key|Description|Mode|
|---|---|---|
|`<C-s>`|Save File|**i**, **x**, **n**, **s**|
|`<esc>`|Escape and Clear hlsearch|**i**, **n**, **s**|
|`<leader>ur`|Redraw / Clear hlsearch / Diff Update|**n**|

### Help & Info

|Key|Description|Mode|
|---|---|---|
|`<leader>l`|Lazy|**n**|
|`<leader>L`|LazyVim Changelog|**n**|
|`<leader>?`|Buffer Keymaps (which-key)|**n**|

### Exit

|Key|Description|Mode|
|---|---|---|
|`<leader>qq`|Quit All|**n**|

---

## Notes

- **Mode Legend:** `n` = normal, `i` = insert, `v` = visual, `x` = visual block, `o` = operator-pending, `s` = select, `c` = command, `t` = terminal
- **Default Leader:** `<space>` can be customized in `~/.config/nvim/init.lua`
- **Which-key Integration:** Press `<leader>` to see available commands grouped by category
- This organization prioritizes practical workflow frequency, not alphabetical or categorical arrangement