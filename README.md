# LSP Loader

> [!IMPORTANT]
> Requires Neovim 0.11+

Since Neovim 0.11 it is possible to define your LSP configs in the `~/.config/nvim/lsp/` directory.

This small plugin loads those LSP configs automatically for you! Then you no longer need to call `vim.lsp.enable` for each one.

Plus this plugin contains some nifty LSP-related extras to help you setup LSP within Neovim more easily.

## Setup

If you just want to load the language servers automatically and nothing else you can setup the plugin like so:

```lua
require("lsp-loader").setup()
```

### Example (with all available options)

```lua
require("lsp-loader").setup({
	-- Disable specific language servers.
	disabled = {
		"lua_ls", -- Disables `~/.config/nvim/lsp/lua_ls.lua`
	},
	-- Set options for the floating documentation window when pressing K.
	-- For example if you have cmp or blink.cmp configured to have window borders, then this will fit in nicely.
	hover = {
		border = "rounded",
	},
	-- Setup builtin LSP completion.
	-- Contains an extra option to trigger the completion menu on all characters, normally it would only trigger when pressing the '.' character (depends on the language server).
	-- Not needed if you have already have a completion plugin like cmp or blink.cmp.
	completion = {
		trigger_on_all_characters = true,
	},
	-- Disable LSP semantic tokens, to prevent race conditions with Treesitter.
	disable_semantic_tokens = true,
	-- On attach function for all language servers, set keymaps here for example.
	on_attach = function(client, bufnr)
		vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, { buffer = bufnr, desc = "LSP code action" })
		vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, { buffer = bufnr, desc = "LSP rename" })
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
