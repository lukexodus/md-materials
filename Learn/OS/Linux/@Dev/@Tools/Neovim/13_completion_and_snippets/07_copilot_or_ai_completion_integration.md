## Copilot or AI Completion Integration


### Overview

LazyVim supports AI-powered code completion through various plugins, with GitHub Copilot being one of the most prominent options. These integrations enhance productivity by providing inline suggestions, code generation, and chat-based assistance. LazyVim organizes these as "extras" that can be enabled via the `:LazyExtras` command, allowing users to opt-in without bloating the core configuration. For instance, the `ai.copilot` extra integrates GitHub Copilot, while others like `ai.copilot-chat` add conversational features.

Other AI tools, such as Codeium, TabNine, or open-source alternatives like avante.nvim, can be added manually or through community extras. These rely on external services or local models, and their performance can vary based on API availability, model quality, and hardware. As of 2026, with advancements in LLMs, plugins like codecompanion.nvim and minuet.nvim support local inference with models like Qwen2.5-coder via Ollama.

Behavior may differ across languages; dynamically typed languages might see less accurate suggestions compared to statically typed ones. Users need an account or API key for proprietary services like Copilot.

**Key Points**
- Copilot provides real-time suggestions triggered by typing or comments.
- Alternatives include free options like Codeium or self-hosted LLMs.
- Integration typically uses `nvim-cmp` for completion sources.
- Keybindings like `<Tab>` for accepting suggestions are common.
- Potential drawbacks: Network latency for cloud-based AI, or higher resource use for local models.

### Enabling GitHub Copilot

LazyVim's `ai.copilot` extra simplifies setup. Enable it with `:LazyExtras` and select `ai.copilot`. This installs `zbirenbaum/copilot.lua`, a Lua-based client for Copilot's API. Authentication requires running `:Copilot auth` to link your GitHub account.

Configuration is handled in `lua/plugins/extras/ai/copilot.lua`, but defaults work for most cases. Suggestions appear in a ghost text overlay, accepted with `<Tab>` or configured keys.

For lazy loading, add conditions like `event = "InsertEnter"` to delay loading until needed, reducing startup time.

**Example**
In `lua/config/lazy.lua`, ensure extras are loaded:

```lua
require("lazy").setup({
  -- ... other options
  extras = {
    "ai.copilot",
  },
})
```

After installation, in a code file, type a comment like `-- Function to add two numbers` and watch for suggestions.

**Output**
Suggestions appear as dimmed text inline; pressing `<Tab>` inserts the code. If no suggestion, it might indicate authentication issues or unsupported language.

### Copilot Chat Integration

The `ai.copilot-chat` extra adds a chat interface for explaining code, generating tests, or refactoring. It uses `CopilotChat.nvim` plugin. Enable via `:LazyExtras ai.copilot-chat`.

Keybindings include `<leader>cc` for opening the chat window. Queries can reference selected code via visual mode.

**Example**
Select a function in visual mode, then `:CopilotChat Explain this code`. The response appears in a split window.

```lua
-- Selected code
local function factorial(n)
  if n == 0 then return 1 end
  return n * factorial(n - 1)
end
```

Chat response might detail recursion and base case.

**Output**
A markdown-formatted explanation in the chat buffer, editable for follow-ups.

### Other AI Completion Options

Beyond Copilot, LazyVim users often integrate alternatives for cost or privacy reasons. Codeium, a free AI completion tool, has `extras.coding.codeium` in some community configs, but as of 2026, it's commonly added manually via `Exantastic/codeium.nvim`.

For open-source, avante.nvim emulates Cursor AI, providing sidebar chats and code edits with local or remote LLMs. Install via lazy spec:

```lua
{
  "yetone/avante.nvim",
  event = "VeryLazy",
  opts = {
    provider = "claude", -- or openai, etc.
  },
  dependencies = { "nvim-lua/plenary.nvim" },
}
```

Other plugins from 2026 discussions include:
- codecompanion.nvim: For Ollama or Anthropic integrations.
- minuet.nvim or supermaven.nvim: Lightweight for local models like Qwen2.5-coder.
- mcphub.nvim: Mentioned in setups replacing Cursor AI.

[Inference]: Based on trends, by 2026, more plugins support multimodal inputs, but this depends on Neovim's API evolution.

**Example**
For Codeium setup:

```lua
{
  "Exantastic/codeium.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
  config = function()
    require("codeium").setup({})
  end,
}
```

Add to cmp sources:

```lua
require("cmp").setup({
  sources = {
    { name = "codeium" },
  },
})
```

Suggestions trigger similarly to Copilot.

**Output**
Inline completions with accept/reject options; status in lualine if configured.

### Customization and Best Practices

Customize completions in `lua/plugins/cmp.lua` to prioritize AI sources or filter noise. For example, set `priority = 1000` for Copilot in cmp.

Combine with LSP for hybrid suggestions: LSP for definitions, AI for creative code.

For performance, use local models on capable hardware to avoid API calls. Monitor with `:Copilot status` or equivalent.

Behavior may vary with Neovim versions; test in a minimal config if issues arise.

**Key Points**
- Authenticate services promptly to avoid delays.
- Use mappings like `<C-]>` for next suggestion.
- Disable in sensitive files via buffer options.

### Troubleshooting

Common issues: No suggestions – check authentication with `:Copilot status`. Slow responses – switch to local AI. Conflicts with other completions – adjust cmp sorting.

Update plugins regularly via `:Lazy update`. If extras fail, reinstall with `:Lazy clean`.

[Unverified]: Some users report intermittent outages with cloud AI due to service changes.

**Next Steps**
- Explore `ai.copilot-chat` for advanced workflows.
- Try avante.nvim for a Cursor-like experience.
- Review community forums for 2026-specific tweaks.

---

