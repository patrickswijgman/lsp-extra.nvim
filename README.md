# LSP Loader

> [!IMPORTANT]
> Requires Neovim 0.11+

Since Neovim 0.11 it is possible to define your LSP configs in the `~/.config/nvim/lsp/` directory.

This small plugin loads those LSP configs automatically for you! Then you no longer need to call `vim.lsp.enable` for each one.

Plus this plugin contains some nifty LSP-related extras to help you setup LSP within Neovim more easily.

## Installation

### With lazy.nvim

```lua
{
  'patrickswijgman/lsp-loader.nvim',
  --- @module 'lsp-loader'
  --- @type lsp_loader.Opts
  opts = {
    -- See setup options below.
  },
}
```

### Without package manager (if you use Nix)

Create the `lsp-loader.lua` file in the `~/.config/nvim/after/plugin/` directory. See [configuration](#configuration) below for setup instructions.

## Configuration

If you just want to load the language servers automatically and nothing else you can setup without passing `opts`.

```lua
require("lsp-loader").setup()
```

See below for setup with all available options.

```lua
require("lsp-loader").setup({
  -- Disable specific language servers.
  disabled = {
    "lua_ls", -- Disables `~/.config/nvim/lsp/lua_ls.lua`
  },

  -- Setup builtin LSP completion.
  --
  -- Not needed if you have already have a completion plugin like cmp or blink.cmp.
  completion = {
    autotrigger = true,
    -- Contains an extra option to trigger the completion menu on all characters, normally
    -- it only triggers when pressing the dot character (depends on the language server).
    trigger_on_all_characters = true,
  },

  -- Set options for the hover window.
  hover = {
    -- For example if you have cmp or blink.cmp configured to have window borders,
    -- then this will fit in nicely.
    border = "rounded", -- "single" | "double" | "rounded" | "solid" | "shadow"
  },

  -- Set options for the signature help window.
  signature_help = {
    -- For example if you have cmp or blink.cmp configured to have window borders,
    -- then this will fit in nicely.
    border = "rounded", -- "single" | "double" | "rounded" | "solid" | "shadow"
  },

  -- Disable LSP semantic tokens, to prevent race conditions with Treesitter.
  disable_semantic_tokens = true,

  -- Setup keymaps for LSP actions.
  --
  -- If you're like me and don't like the builtin LSP keymaps, this plugin provides a
  -- convenient way to set some or all of them.
  keymaps = {
    -- Below is an example (Helix style)
    definition = "gd",
    type_definition = "gy",
    references = "gr",
    implementations = "gi",
    document_symbols = "gs",
    workspace_symbols = "gS",
    code_action = "<leader>a",
    rename = "<leader>r",
    signature_help = "<c-s>",
    completion = "<c-space>",
    diagnostics = "<leader>d",
    hover = "K",
  },

  -- On attach function for all language servers.
  on_attach = function(client, bufnr)
  end,
})
```

## Setting up language servers

> [!TIP]
> See [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md) for language server configs.

To setup language servers, for each one you can create a file in `~/.config/nvim/lsp/`. For example `lua_ls.lua`:

```lua
--- @type vim.lsp.Config
return {
  cmd = { "lua-language-server" },
  filetypes = {
    "lua",
  },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
    ".git",
  },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
    },
  },
}
```

> [!TIP]
> Execute the `:checkhealth lsp` command to see if your language servers have loaded correctly.
