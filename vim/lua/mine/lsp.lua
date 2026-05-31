local cmp_nvim_lsp = require('cmp_nvim_lsp')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local neodev = require('neodev')

mason.setup()
mason_lspconfig.setup()
neodev.setup {}

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
      [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
      [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
    },
  },
})

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>',                                opts)
  buf_set_keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>',                                 opts)
  buf_set_keymap('n', 'gR',         '<Cmd>lua vim.lsp.buf.references()<CR>',                                 opts)
  buf_set_keymap('n', 'gI',         '<Cmd>lua vim.lsp.buf.implementation()<CR>',                             opts)
  buf_set_keymap('n', '<Leader>.a', '<Cmd>lua vim.lsp.buf.code_action()<CR>',                                opts)
  buf_set_keymap('n', '<Leader>.d', '<Cmd>lua vim.diagnostic.open_float()<CR>',                              opts)
  buf_set_keymap('n', '<Leader>.k', '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)
  buf_set_keymap('n', '<Leader>.o', '<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',      opts)
  buf_set_keymap('n', '<Leader>.q', '<Cmd>lua vim.diagnostic.setloclist()<CR>',                              opts)
  buf_set_keymap('n', '<Leader>.r', '<Cmd>lua vim.lsp.buf.rename()<CR>',                                     opts)
  buf_set_keymap('n', '<Leader>.s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>',                             opts)
  buf_set_keymap('n', '<Leader>.t', '<Cmd>lua vim.lsp.buf.type_definition()<CR>',                            opts)
--buf_set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                       opts)
--buf_set_keymap('n', '<Leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--buf_set_keymap('n', '<Leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                    opts)
  buf_set_keymap('n', '[d',         '<Cmd>lua require("mine.diagnostics").goto_prev()<CR>',                  opts)
  buf_set_keymap('n', ']d',         '<Cmd>lua require("mine.diagnostics").goto_next()<CR>',                  opts)

  buf_set_keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)

  vim.cmd[[IMapMeta <buffer> i <Cmd>lua require('mine').toggle_signature_help()<CR>]]

  if client.server_capabilities.documentFormattingProvider then
    buf_set_keymap("n", "<Leader>.f", "<Cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    buf_set_keymap("v", "<Leader>.f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_exec([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  require('mine.diagnostics').set_diagnostic_level('full')
  -- Disable Diagnostcs globally
  --vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
end

local function make_capabilities()
  return cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

vim.lsp.config('rubocop', {
  cmd = { "bundle", "exec", "rubocop", "--lsp" },
})
vim.lsp.enable('rubocop')

vim.lsp.config('ruby_lsp', {
  cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
  init_options = {
    linters = {},
    addonSettings = {
      ["Ruby LSP Rails"] = {
        enablePendingMigrationsPrompt = false,
      },
    },
  },
})
vim.lsp.enable('ruby_lsp')

local aug = vim.api.nvim_create_augroup("LspKeymaps", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = aug,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap=true, silent=true }

    buf_set_keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>',                                opts)
    buf_set_keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>',                                 opts)
    buf_set_keymap('n', 'gR',         '<Cmd>lua vim.lsp.buf.references()<CR>',                                 opts)
    buf_set_keymap('n', 'gI',         '<Cmd>lua vim.lsp.buf.implementation()<CR>',                             opts)
    buf_set_keymap('n', '<Leader>.a', '<Cmd>lua vim.lsp.buf.code_action()<CR>',                                opts)
    buf_set_keymap('n', '<Leader>.d', '<Cmd>lua vim.diagnostic.open_float()<CR>',                              opts)
    buf_set_keymap('n', '<Leader>.k', '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)
    buf_set_keymap('n', '<Leader>.o', '<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',      opts)
    buf_set_keymap('n', '<Leader>.q', '<Cmd>lua vim.diagnostic.setloclist()<CR>',                              opts)
    buf_set_keymap('n', '<Leader>.r', '<Cmd>lua vim.lsp.buf.rename()<CR>',                                     opts)
    buf_set_keymap('n', '<Leader>.s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>',                             opts)
    buf_set_keymap('n', '<Leader>.t', '<Cmd>lua vim.lsp.buf.type_definition()<CR>',                            opts)
  --buf_set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                       opts)
  --buf_set_keymap('n', '<Leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  --buf_set_keymap('n', '<Leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                    opts)
    buf_set_keymap('n', '[d',         '<Cmd>lua require("mine.diagnostics").goto_prev()<CR>',                  opts)
    buf_set_keymap('n', ']d',         '<Cmd>lua require("mine.diagnostics").goto_next()<CR>',                  opts)

    buf_set_keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)

    vim.cmd[[IMapMeta <buffer> i <Cmd>lua require('mine').toggle_signature_help()<CR>]]

    if client.server_capabilities.documentFormattingProvider then
      buf_set_keymap("n", "<Leader>.f", "<Cmd>lua vim.lsp.buf.format { async = true }<CR>", opts)
    end

    if client.server_capabilities.documentRangeFormattingProvider then
      buf_set_keymap("v", "<Leader>.f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
    end

    if client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_exec([[
        augroup lsp_document_highlight
          autocmd! * <buffer>
          autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
          autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]], false)
    end

    require('mine.diagnostics').set_diagnostic_level('full')
  end,
})

--mason_lspconfig.setup_handlers {
--}
  ----clangd = function()
    ----lspconfig.clangd.setup {
      ----on_attach = function(client)
        ----local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

        ----if project == 'qmk-keymaps' then
          ----vim.lsp.stop_client(client.id)
        ----end
      ----end,
      ----capabilities = make_capabilities(),
      ----cmd = {
        ----"clangd",
        ----"--offset-encoding=utf-16",
      ----},
    ----}
  ----end,

  ----rust_analyzer = function()
    ----lspconfig.rust_analyzer.setup {
      ----on_attach = on_attach,
      ----capabilities = make_capabilities(),
    ----}
  ----end,

  --rubocop = {
    --root_dir = lspconfig.util.root_pattern('.rubocop.yml'),
    --cmd = { 'bundle', 'exec', 'rubocop', '--lsp' },
  --}

  ----lua_ls = function()
    ----lspconfig.lua_ls.setup {
      ----on_attach = on_attach,
      ----capabilities = make_capabilities(),
      ----settings = {
        ----Lua = {
          ----completion = {
            ----callSnippet = 'Replace',
          ----},
          ----workspace = {
            ----checkThirdParty = false,
          ----}
        ----}
      ----}
    ----}
  ----end,
--}
