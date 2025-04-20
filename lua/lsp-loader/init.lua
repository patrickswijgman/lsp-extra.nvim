local M = {}

--- @class lsp_loader.HoverOpts : vim.lsp.buf.hover.Opts

--- @class lsp_loader.SignatureHelpOpts : vim.lsp.buf.signature_help.Opts

--- @class lsp_loader.CompletionOpts : vim.lsp.completion.BufferOpts
--- @field trigger_on_all_characters? boolean

--- @class lsp_loader.Keymaps
--- @field definition? string
--- @field type_definition? string
--- @field references? string
--- @field implementations? string
--- @field document_symbols? string
--- @field workspace_symbols? string
--- @field code_action? string
--- @field rename? string
--- @field signature_help? string
--- @field diagnostics? string
--- @field hover? string

--- @class lsp_loader.Opts
--- @field disabled? string[]
--- @field hover? lsp_loader.HoverOpts
--- @field signature_help? lsp_loader.SignatureHelpOpts
--- @field completion? lsp_loader.CompletionOpts
--- @field keymaps? lsp_loader.Keymaps
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

--- Set keymap.
--- @param mode string
--- @param keymap? string
--- @param bufnr integer
--- @param desc string
local function set_keymap(mode, keymap, fn, bufnr, desc, remap)
  if keymap then
    vim.keymap.set(mode, keymap, fn, { buffer = bufnr, desc = desc, remap = remap })
  end
end

--- Setup LSP keymaps.
--- @param opts lsp_loader.Opts
--- @param bufnr integer
local function setup_keymaps(opts, bufnr)
  local function hover()
    vim.lsp.buf.hover(opts.hover)
  end

  local function signature_help()
    vim.lsp.buf.signature_help(opts.signature_help)
  end

  local function workspace_symbols()
    vim.lsp.buf.workspace_symbol("")
  end

  local function diagnostics()
    vim.diagnostic.setqflist({ open = true })
  end

  local hover_keymap = "K"
  if opts.keymaps and opts.keymaps.hover then
    hover_keymap = opts.keymaps.hover
  end

  local signature_help_keymap = "<c-s>"
  if opts.keymaps and opts.keymaps.signature_help then
    signature_help_keymap = opts.keymaps.signature_help
  end

  set_keymap("n", hover_keymap, hover, bufnr, "LSP hover", true)
  set_keymap("i", signature_help_keymap, signature_help, bufnr, "LSP signature help")

  if opts.keymaps then
    set_keymap("n", opts.keymaps.definition, vim.lsp.buf.definition, bufnr, "LSP definition")
    set_keymap("n", opts.keymaps.type_definition, vim.lsp.buf.type_definition, bufnr, "LSP type definition")
    set_keymap("n", opts.keymaps.references, vim.lsp.buf.references, bufnr, "LSP references")
    set_keymap("n", opts.keymaps.implementations, vim.lsp.buf.implementation, bufnr, "LSP implementations")
    set_keymap("n", opts.keymaps.document_symbols, vim.lsp.buf.document_symbol, bufnr, "LSP document symbols")
    set_keymap("n", opts.keymaps.workspace_symbols, workspace_symbols, bufnr, "LSP workspace symbols")
    set_keymap("n", opts.keymaps.code_action, vim.lsp.buf.code_action, bufnr, "LSP code action")
    set_keymap("n", opts.keymaps.rename, vim.lsp.buf.rename, bufnr, "LSP rename")
    set_keymap("n", opts.keymaps.diagnostics, diagnostics, bufnr, "Diagnostics")
  end
end

--- Setup LSP on attach autocmd.
--- @param opts lsp_loader.Opts
local function setup_on_attach(opts)
  local group = vim.api.nvim_create_augroup("LspLoader", { clear = true })

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

        vim.lsp.completion.enable(true, client.id, args.buf, opts.completion)
      end

      if opts.disable_semantic_tokens then
        client.server_capabilities.semanticTokensProvider = nil
      end

      setup_keymaps(opts, args.buf)

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
  setup_on_attach(opts)
end

return M
