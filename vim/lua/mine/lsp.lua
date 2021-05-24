local lsp = require('lspconfig')
require('lspinstall').setup()

vim.g.diagnostics_active = true

function _G.toggle_diagnostics()
  if vim.g.diagnostics_active then
    vim.g.diagnostics_active = false
    vim.lsp.diagnostic.clear(0)
    vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
  else
    vim.g.diagnostics_active = true
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      }
    )
  end
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
  buf_set_keymap('n', 'yot',        '<Cmd>lua toggle_diagnostics()<CR>',                                     opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<Leader>.f", "<Cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end

  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<Leader>.f", "<Cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  -- Disable Diagnostcs globally
  --vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
end

local function make_capabilities(config)
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  if not config then
    config = {}
  end

  for _, value in ipairs(config) do
    if value == 'snippets' then
      capabilities.textDocument.completion.completionItem.snippetSupport = true
    else
      error("Unknown capability: " .. value, 2)
    end
  end

  capabilities.textDocument.completion.completionItem.resolveSupport = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }

  return capabilities
end

lsp.vimls.setup {
  on_attach = on_attach,
  capabilities = make_capabilities({'snippets'})
}

lsp.lua.setup {
  on_attach = on_attach,
  capabilities = make_capabilities({'snippets'}),
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = vim.split(package.path, ';'),
      },
      completion = {
        callSnippet = 'Replace',
      },
      diagnostics = {
        globals = {'vim', 'it', 'describe'},
      },
      workspace = {
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
      telemetry = {enable = false},
    },
  },
}

lsp.python.setup {
  on_attach = on_attach,
  capabilities = make_capabilities({'snippets'}),
}

lsp.tsserver.setup {
  on_attach = on_attach,
  capabilities = make_capabilities({'snippets'}),
}

require('lspsaga').init_lsp_saga()
