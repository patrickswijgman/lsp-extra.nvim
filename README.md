# LSP Loader

> [!IMPORTANT]
> Requires Neovim 0.11+

Since Neovim 0.11 it is possible to define your LSP configs in the `~/.config/nvim/lsp/` directory.

This small plugin loads those LSP configs automatically for you! Then you no longer need to call `vim.lsp.enable` for each one.

## Setup

All options are optional, to simply load the language servers automatically you can do:

```lua
require("lsp-loader").setup()
```

### Example (with all available options)

```lua
require("lsp-loader").setup({
    -- Disable specific language servers.
    disabled = {
        "lua_ls" -- Disabled `~/.config/nvim/lsp/lua_ls.lua`
    },
    -- Set options for the floating documentation window when pressing K.
    -- For example if you have cmp or blink.cmp configured to have window borders, this will then fit in nicely.
	hover = {
		border = "rounded",
	},
    -- Disable LSP semantic tokens, for example to prevent race conditions with Treesitter.
	disable_semantic_tokens = true,
    -- On attach function for each language server, set keymaps here for example.
    on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP code action" })
        vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP rename" })
    end
})
```
