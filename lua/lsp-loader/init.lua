local M = {}

--- @class lsp_loader.HoverOpts : vim.lsp.buf.hover.Opts

--- @class lsp_loader.CompletionOpts : vim.lsp.completion.BufferOpts
--- @field trigger_on_all_characters? boolean

--- @class lsp_loader.Opts
--- @field disabled? string[]
--- @field hover? lsp_loader.HoverOpts
--- @field completion? lsp_loader.CompletionOpts
--- @field disable_semantic_tokens? boolean
--- @field on_attach? fun(client: vim.lsp.Client, bufnr: integer)

--- Automatically load language servers in the lsp config directory.
--- @param opts lsp_loader.Opts
local function setup_language_servers(opts)
  local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
  local lsp_files = vim.fn.readdir(lsp_dir) --- @type string[]

  for _, file in ipairs(lsp_files) do
    local name = file:gsub("%.lua$", "")
    local enabled = not opts.disabled or not vim.tbl_contains(opts.disabled, name)
    vim.lsp.enable(name, enabled)
  end
end

--- Override default LSP keymaps with options.
--- @param opts lsp_loader.Opts
local function setup_keymaps(opts)
  local function hover()
    vim.lsp.buf.hover(opts.hover)
  end

  vim.keymap.set("n", "K", hover, { desc = "LSP hover", remap = true })
end

--- Setup LSP on attach autocmd.
--- @param opts lsp_loader.Opts
local function setup_on_attach(opts)
  local group = vim.api.nvim_create_augroup("LspLoader", { clear = true })

  -- Common characters.
  -- See |lsp-attach|
  local triggerCharacters = {}
  for i = 32, 126 do
    table.insert(triggerCharacters, string.char(i))
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if not client then
        return
      end

      if opts.completion and client:supports_method("textDocument/completion") then
        if opts.completion.trigger_on_all_characters then
          client.server_capabilities.completionProvider.triggerCharacters = triggerCharacters
        end

        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end

      if opts.disable_semantic_tokens then
        client.server_capabilities.semanticTokensProvider = nil
      end

      if opts.on_attach then
        opts.on_attach(client, args.buf)
      end
    end,
    group = group,
    desc = "LSP on attach",
  })
end

--- @param opts? lsp_loader.Opts
function M.setup(opts)
  if not opts then
    opts = {}
  end

  setup_language_servers(opts)
  setup_keymaps(opts)
  setup_on_attach(opts)
end

return M
