" Settings for LSP-enabled NVIM
"
lua << EOF
local nvim_lsp = require('lspconfig')
local nvim_lspinstall = require('lspinstall')

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>',                                opts)
  buf_set_keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>',                                 opts)
  buf_set_keymap('n', 'gR',         '<Cmd>lua vim.lsp.buf.references()<CR>',                                 opts)
  buf_set_keymap('n', 'gI',         '<Cmd>lua vim.lsp.buf.implementation()<CR>',                             opts)
  buf_set_keymap('n', '<Leader>.D', '<Cmd>lua require("lspsaga.diagnostic").show_cursor_diagnostics()<CR>',  opts)
  buf_set_keymap('n', '<Leader>.K', '<Cmd>Lspsaga hover_doc<CR>',                                            opts)
--buf_set_keymap('n', '<Leader>.a', '<Cmd>lua vim.lsp.buf.code_action()<CR>',                                opts)
  buf_set_keymap('n', '<Leader>.a', '<Cmd>lua require("lspsaga.codeaction").code_action()<CR>',              opts)
  buf_set_keymap('n', '<Leader>.d', '<Cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>',    opts)
  buf_set_keymap('n', '<Leader>.e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',               opts)
  buf_set_keymap('n', '<Leader>.h', '<Cmd>lua require("lspsaga.provider").lsp_finder()<CR>',                 opts)
  buf_set_keymap('n', '<Leader>.k', '<Cmd>lua vim.lsp.buf.hover()<CR>',                                      opts)
  buf_set_keymap('n', '<Leader>.p', '<Cmd>lua require"lspsaga.provider".preview_definition()<CR>',           opts)
  buf_set_keymap('n', '<Leader>.q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>',                         opts)
--buf_set_keymap('n', '<Leader>.r', '<Cmd>lua vim.lsp.buf.rename()<CR>',                                     opts)
  buf_set_keymap('n', '<Leader>.r', '<Cmd>lua require("lspsaga.rename").rename()<CR>',                       opts)
--buf_set_keymap('n', '<Leader>.s', '<Cmd>lua vim.lsp.buf.signature_help()<CR>',                             opts)
  buf_set_keymap('n', '<Leader>.s', '<Cmd>lua require("lspsaga.signaturehelp").signature_help()<CR>',        opts)
  buf_set_keymap('n', '<Leader>.t', '<Cmd>lua vim.lsp.buf.type_definition()<CR>',                            opts)
--buf_set_keymap('n', '<Leader>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',                       opts)
--buf_set_keymap('n', '<Leader>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--buf_set_keymap('n', '<Leader>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',                    opts)
--buf_set_keymap('n', '[d',         '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',                           opts)
--buf_set_keymap('n', ']d',         '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>',                           opts)
  buf_set_keymap('n', '[d',         '<Cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>', opts)
  buf_set_keymap('n', ']d',         '<Cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<Leader>.f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<Leader>.f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

nvim_lspinstall.setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { 'documentation', 'detail', 'additionalTextEdits' }
}

local servers = { "vimls", "tsserver" }

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach, capabilities = capabilities }
end

for _, server in pairs(nvim_lspinstall.installed_servers()) do
  nvim_lsp[server].setup { on_attach = on_attach, capabilities = capabilities }
end

local saga = require('lspsaga')
saga.init_lsp_saga()
EOF

nnoremap <silent> <C-f> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>
nnoremap <silent> <C-b> <cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>

"nnoremap <silent> <D-d> <cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>
"tnoremap <silent> <D-d> <C-\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>
