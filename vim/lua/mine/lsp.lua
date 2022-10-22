local lspconfig = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local neodev = require('neodev')

mason.setup()
mason_lspconfig.setup()
neodev.setup {}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

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
  buf_set_keymap('n', '<Leader>.d', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',               opts)
  buf_set_keymap('n', '<Leader>.k', '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)
  buf_set_keymap('n', '<Leader>.o', '<Cmd>lua require("telescope.builtin").lsp_document_symbols()<CR>',      opts)
  buf_set_keymap('n', '<Leader>.q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',                         opts)
  buf_set_keymap('n', '<Leader>.r', '<Cmd>lua vim.lsp.buf.rename()<CR>',                                     opts)
  buf_set_keymap('n', '<Leader>.s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>',                             opts)
  buf_set_keymap('n', '<Leader>.t', '<Cmd>lua vim.lsp.buf.type_definition()<CR>',                            opts)
--buf_set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                       opts)
--buf_set_keymap('n', '<Leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--buf_set_keymap('n', '<Leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                    opts)
  buf_set_keymap('n', '[d',         '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',                           opts)
  buf_set_keymap('n', ']d',         '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>',                           opts)
  buf_set_keymap('n', 'yot',        '<Cmd>lua toggle_diagnostics()<CR>',                                     opts)

  buf_set_keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)

  vim.cmd[[IMapMeta <buffer> i <Cmd>lua require('mine').toggle_signature_help()<CR>]]

  if client.server_capabilities.documentFormattingProvider then
    buf_set_keymap("n", "<Leader>.f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
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

local function make_capabilities(config)
  local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

  config = config or {}

  if config.snippets == true then
    capabilities.textDocument.completion.completionItem.snippetSupport = true
  elseif config.snippets == false then
    capabilities.textDocument.completion.completionItem.snippetSupport = false
  end

  if config.resolveSupport ~= false then
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  end

  return capabilities
end

mason_lspconfig.setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      on_attach = on_attach,
      capabilities = make_capabilities { snippets = true },
    }
  end,

  rust_analyzer = function()
    lspconfig.rust_analyzer.setup {
      on_attach = on_attach,
      capabilities = make_capabilities { snippets = true, resolveSupport = false },
    }
  end,

  sumneko_lua = function()
    lspconfig.sumneko_lua.setup {
      on_attach = on_attach,
      capabilities = make_capabilities({ snippets = true }),
    }
  end,
}
