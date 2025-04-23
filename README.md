# LSP Extra

> [!IMPORTANT]
> Requires Neovim 0.11+

Some nifty features to help you setup the Neovim LSP more easily.

## Features

1. Automatically load your LSP configs in the `~/.config/nvim/lsp/` directory.
1. Setup builtin auto completion with LSP capabilities.
1. Set options for the floating windows such as hover and signature help.
1. Disable LSP semantic tokens if you use Treesitter.
1. Conveniently set LSP keymaps.

## Installation

### With lazy.nvim

```lua
{
  'patrickswijgman/lsp-extra.nvim',
  --- @module 'lsp-extra'
  --- @type lsp_extra.Opts
  opts = {
    -- See setup options below.
  },
}
```

### Without package manager (if you use Nix)

Create the `lsp-extra.lua` file in the `~/.config/nvim/after/plugin/` directory. See [configuration](#configuration) below for setup instructions.

## Configuration

```lua
require("lsp-extra").setup({
  -- Automatically enable specific language servers from the `lsp/` directory.
  auto_enable = true,

  -- Do not automatically enable specific language servers.
  auto_enable_ignore = {
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
  --
  -- REQUIRES that it is added in the `keymaps` option for it to work.
  hover = {
    -- For example if you have cmp or blink.cmp configured to have window borders,
    -- then this will fit in nicely.
    border = "rounded",
  },

  -- Set options for the signature help window.
  --
  -- REQUIRES that it is added in the `keymaps` option for it to work.
  signature_help = {
    -- For example if you have cmp or blink.cmp configured to have window borders,
    -- then this will fit in nicely.
    border = "rounded", -- "single" | "double" | "rounded" | "solid" | "shadow"
  },

  -- Disable LSP semantic tokens, to prevent race conditions with Treesitter.
  disable_semantic_tokens = true,

  -- Set this to true to remove default LSP keymaps.
  --
  -- Be sure to add your own mappings in the `keymaps` option.
  -- See `:h lsp-defaults-disable` for more info.
  --
  -- For example 'grr' and 'gra' are mapped by default which does not play
  -- nicely if we want to map 'gr' to 'references' (see below).
  remove_default_keymaps = true,

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
    completion = "<c-space>",
    diagnostics = "<leader>d",
    signature_help = "<c-s>", -- Required if `signature_help` option is set.
    hover = "K", -- Required if `hover` option is set.
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
