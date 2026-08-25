## Inlay Hints and Semantic Tokens


### Overview

Inlay hints and semantic tokens are advanced features provided through the Language Server Protocol (LSP) integration, enhancing code readability and developer productivity. Inlay hints display inline annotations directly in the editor buffer, such as parameter names, type inferences, or virtual text that provides additional context without cluttering the code. Semantic tokens, on the other hand, enable more nuanced syntax highlighting by categorizing code elements based on their semantic meaning (e.g., distinguishing between variables, functions, and types), allowing for richer color schemes and styling compared to traditional syntax highlighting.

These features rely on the capabilities of the attached language server. For instance, servers like rust-analyzer or typescript-language-server commonly support them. Behavior can vary depending on the Neovim version, the specific language server, and configuration settings, as updates to Neovim or servers may introduce changes or improvements.

### Enabling Inlay Hints

To enable inlay hints, you typically interact with the LSP API after the language server attaches to a buffer. LazyVim includes `nvim-lspconfig` for LSP setup and `mason.nvim` for server management, making it straightforward to configure these features globally or per-buffer.

In your `init.lua` or a relevant configuration file (e.g., under `lua/config/` in a LazyVim setup), you can add a hook in the LSP on_attach function to toggle inlay hints. Here's a basic setup:

```lua
-- In lua/config/lazy.lua or a similar file
require("lazy").setup({
  -- ... other plugins ...
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- Example for a server like lua_ls
      lspconfig.lua_ls.setup({
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      })
    end,
  },
})
```

This checks if the server supports inlay hints and enables them for the current buffer. Note that Neovim 0.10 and later versions have built-in support for inlay hints via `vim.lsp.inlay_hint`, which may behave differently in earlier versions where plugins like `lsp-inlayhints.nvim` were needed [Inference: Based on Neovim release notes up to 0.10]. To toggle them manually, use commands like `:lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())`.

For global enabling across all supported buffers, you can wrap this in a user command or autocmd. Behavior might vary if the language server does not provide hints or if there are conflicts with other plugins.

**Key Points**
- Ensure the language server is installed via Mason (e.g., `:MasonInstall lua-language-server`).
- Inlay hints can impact performance in large files; monitor CPU usage as it may increase rendering overhead.
- Customization options include filtering hint types (e.g., parameters only) via server-specific settings.

**Example**
Consider a TypeScript file where inlay hints show parameter types:

```typescript
function greet(name: string, age: number) {
  console.log(`Hello, ${name}! You are ${age} years old.`);
}

greet("Alice", 30);  // With inlay hints: greet(name: "Alice", age: 30);
```

When enabled, the editor might display inferred types or labels inline, depending on the server.

### Configuring Semantic Tokens

Semantic tokens provide semantic-based highlighting, which is more precise than tree-sitter or regex-based syntax highlighting. In LazyVim, this is handled automatically if the language server supports it, but you can explicitly request it in the LSP setup.

Add this to your LSP configuration:

```lua
lspconfig.rust_analyzer.setup({
  on_attach = function(client, bufnr)
    if client.server_capabilities.semanticTokensProvider then
      vim.lsp.semantic_tokens.start(bufnr, client.id)
    end
  end,
})
```

This starts semantic token highlighting for the buffer. Neovim uses highlight groups like `@lsp.type.variable` for styling, which you can customize in your colorscheme or via `vim.api.nvim_set_hl`.

To disable or modify, use `vim.lsp.semantic_tokens.stop(bufnr, client_id)`. Some servers allow customizing token modifiers (e.g., readonly, static) through settings.

**Key Points**
- Not all language servers support semantic tokens; check with `:lua print(vim.inspect(vim.lsp.get_client_by_id(1).server_capabilities))` for a attached client.
- Semantic tokens can coexist with tree-sitter highlighting, but priorities may need adjustment via `vim.highlight.priorities`.
- Performance may vary; in dense codebases, it could lead to slower highlighting updates.

**Example**
In a Rust file with semantic tokens enabled:

```rust
fn main() {
    let message = "Hello, world!";
    println!("{}", message);
}
```

Semantic tokens might highlight `main` as a function, `message` as a variable, and `println!` as a macro, allowing for distinct colors (e.g., variables in blue, functions in green).

**Output**
When viewing the buffer with `:Inspect`, you might see token types like:
- Token: "fn" - type: keyword
- Token: "main" - type: function
This output depends on the server's response and Neovim's processing.

### Integration and Customization

For deeper integration, consider plugins like `lsp-zero.nvim` (though LazyVim has its own defaults) or custom keymaps. To toggle features dynamically:

```lua
vim.keymap.set("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle Inlay Hints" })

vim.keymap.set("n", "<leader>st", function()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  if client then
    if vim.lsp.semantic_tokens.is_active(0, client.id) then
      vim.lsp.semantic_tokens.stop(0, client.id)
    else
      vim.lsp.semantic_tokens.start(0, client.id)
    end
  end
end, { desc = "Toggle Semantic Tokens" })
```

These keymaps can be added to `lua/config/keymaps.lua`. Customize hint appearance with options like `vim.lsp.inlay_hint.config({ prefix = ' » ', })` for styling [Unverified: Specific prefix styling may require Neovim nightly builds].

If using a colorscheme, ensure it defines LSP highlight groups:

```lua
vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = "LightBlue" })
```

### Troubleshooting Common Issues

- **Hints not appearing**: Verify server capabilities with `:LspInfo`. Restart the server with `:LspRestart`.
- **Overlapping text**: Adjust padding or virtual text alignment via `vim.opt.virtualedit` or server settings.
- **Performance degradation**: Disable for specific filetypes in on_attach checks.
- Behavior may differ across Neovim versions or servers; test in a minimal config if issues persist.

### Advanced Usage

For multi-language support, use a loop over multiple servers in your setup. Combine with other LSP features like code lenses for enhanced workflows.

Inlay hints can be filtered by type:

```lua
vim.lsp.inlay_hint.enable(true, { filter = { typeHints = true, parameterHints = false } })
```

[Speculation: Future Neovim updates might expand filter options.] Semantic tokens can be refreshed manually with `vim.lsp.semantic_tokens.refresh()`.

**Conclusion**
Inlay hints and semantic tokens significantly improve code comprehension by providing contextual annotations and precise highlighting. With proper configuration in LazyVim, they integrate seamlessly into your workflow, though testing with your specific languages and servers is recommended to observe actual behavior.

**Next Steps**
- Install a language server via `:Mason` and test in a sample file.
- Explore Neovim's `:help lsp` for more API details.
- Customize your colorscheme to leverage semantic token groups for better visuals.

---

