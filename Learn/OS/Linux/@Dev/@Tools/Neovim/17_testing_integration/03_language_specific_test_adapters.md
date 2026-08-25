## Language-Specific Test Adapters


### Overview

In LazyVim, language-specific test adapters extend the neotest framework (enabled via the "test.core" extra) to support running and interacting with tests in various programming languages. These adapters parse test structures, execute tests, and display results within Neovim. Most language extras configure neotest adapters optionally, requiring the "test.core" extra to be enabled first. Additional adapters from the neotest ecosystem can be added manually for unsupported languages. Behavior may vary depending on project structure, test frameworks, and plugin versions.

**Key Points**
- "test.core" provides the base neotest setup.
- Language extras often include adapters like neotest-python or neotest-golang.
- Adapters are configurable via opts tables in plugin specs.
- Integration with nvim-dap allows debugging tests in some languages (e.g., Go, Python).

### Enabling Test Core and Language Extras

Enable "test.core" using `:LazyExtras` to install and configure neotest. Then, enable language-specific extras (e.g., "lang.go") for their adapters. Plugins like neotest are marked as optional and load only if installed.

In `lua/plugins/test.lua`, extend configurations:

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      status = { virtual_text = true },
      output = { open_on_run = true },
    },
  },
}
```

### Plugins Involved

- `nvim-neotest/neotest`: Core testing framework.
- Language-specific adapters (e.g., `nvim-neotest/neotest-python`, `stevanmilic/neotest-scala`).
- Optional: `nvim-dap` for test debugging.

The "test.core" extra includes neotest-plenary as an example adapter for Lua tests.

### Keymaps

LazyVim defines keymaps under the `<leader>t` prefix for neotest when "test.core" is enabled:

- `<leader>tt`: Run nearest test.
- `<leader>tT`: Run all tests in file.
- `<leader>ta`: Run all tests in suite.
- `<leader>tl`: Run last test.
- `<leader>ts`: Show test summary.
- `<leader>to`: Show test output.
- `<leader>tO`: Toggle test output panel.
- `<leader>tS`: Stop tests.

These may be extended in language extras. Behavior may vary if custom keymaps are set.

### Language-Specific Configurations

Language extras provide pre-configured adapters. Below are details for supported languages based on LazyVim extras.

#### Go

The "lang.go" extra configures `neotest-golang` for Go tests.

- Adapter: `neotest-golang`
- Supports: Standard Go tests, with optional DAP integration.

**Example** (Default opts)
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },  -- Custom args
          dap_go_enabled = true,  -- Requires nvim-dap-go
        },
      },
    },
  },
}
```

#### Python

The "lang.python" extra uses `neotest-python` for pytest or unittest.

- Adapter: `neotest-python`
- Supports: pytest, unittest.

**Example** (Customization)
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = ".venv/bin/python",
        },
      },
    },
  },
}
```

#### Rust

The "lang.rust" extra integrates `rustaceanvim.neotest` (part of rustaceanvim).

- Adapter: `rustaceanvim.neotest`
- Supports: Cargo tests.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["rustaceanvim.neotest"] = {},
      },
    },
  },
}
```

#### Elixir

The "lang.elixir" extra configures `neotest-elixir`.

- Adapter: `neotest-elixir`
- Supports: ExUnit tests.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-elixir"] = {},
      },
    },
  },
}
```

#### Ruby

The "lang.ruby" extra uses `neotest-rspec` for RSpec tests.

- Adapter: `neotest-rspec`
- Supports: RSpec, with Bundler option.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-rspec"] = {
          rspec_cmd = function()
            return vim.tbl_flatten({ "bundle", "exec", "rspec" })
          end,
        },
      },
    },
  },
}
```

#### Dart

The "lang.dart" extra configures `neotest-dart` for Dart/Flutter tests.

- Adapter: `neotest-dart`
- Supports: Dart tests.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-dart"] = {},
      },
    },
  },
}
```

#### PHP

The "lang.php" extra supports `neotest-pest` and `neotest-phpunit`.

- Adapters: `neotest-pest`, `neotest-phpunit`
- Supports: Pest, PHPUnit.

**Example**
```lua
return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-pest",
        ["neotest-phpunit"] = {
          root_ignore_files = { "tests/Pest.php" },
        },
      },
    },
  },
}
```

#### Java

The "lang.java" extra focuses on JDTLS for tests, not neotest. Includes Treesitter for java-test and DAP configs.

- No neotest adapter; uses LSP test features.
- Supports: JUnit via JDTLS.

**Example** (DAP for tests)
```lua
return {
  {
    "mfussenegger/nvim-dap",
    opts = {
      configurations = {
        java = {
          {
            type = "java",
            request = "attach",
            name = "Debug (Attach) - Remote",
            hostName = "127.0.0.1",
            port = 5005,
          },
        },
      },
    },
  },
}
```

#### Other Languages

For languages without built-in extras (e.g., JavaScript/TypeScript, Haskell, R, .NET), add adapters manually from the neotest ecosystem (e.g., neotest-vitest, neotest-jest for JS/TS).

**Example** (Adding neotest-vitest for TypeScript)
```lua
return {
  {
    "nvim-neotest/neotest",
    dependencies = { "marilari88/neotest-vitest" },
    opts = {
      adapters = {
        "neotest-vitest",
      },
    },
  },
}
```

### Customizing Adapters

Extend adapters in user configs under `lua/plugins/`. Use tables for opts to merge with defaults.

For uncertain integrations (e.g., new adapters), test in a project as behavior may vary.

### Practical Examples

#### Running Tests in Python

1. Enable "test.core" and "lang.python".
2. Open a test file, use `<leader>tt` to run nearest test.
3. View output with `<leader>to`.

**Output** (Sample)
```
✓ test_addition (0.01s)
✗ test_division (error: division by zero)
```

#### Debugging Tests in Go

With dap_go_enabled, use `<leader>td` (from DAP) to debug nearest test.

### Conclusion

LazyVim provides seamless integration for language-specific test adapters via neotest, with pre-configs for several languages. For others, manual addition is straightforward. Always verify adapter compatibility with your test framework.

### Next Steps

- Explore neotest GitHub for more adapters.
- Integrate with overseer.nvim for advanced test running.
- Customize keymaps in `lua/config/keymaps.lua` for workflow efficiency.

---

