local lsp = require('lspconfig')
local lsp_installer = require("nvim-lsp-installer")

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

require('lspkind').init({
  mode = 'symbol_text',
  symbol_map = {
    Text = '',
    Method = 'ƒ',
    Function = '',
    Constructor = '',
    Variable = '',
    Field = '',
    Class = '',
    Interface = 'ﰮ',
    Module = '',
    Property = '',
    Unit = '',
    Value = '',
    Enum = '了',
    Keyword = '',
    Snippet = '﬌',
    Color = '',
    File = '',
    Folder = '',
    EnumMember = '',
    Constant = '',
    Struct = ''
  },
})

--require('lsp_signature').on_attach({
  --bind = false,
  --doc_lines = 10, -- only show one line of comment set to 0 if you do not want API comments be shown

  --hint_enable = true, -- virtual hint enable
  --fix_pos = true,
  --hint_prefix = "🐼 ",  -- Panda for parameter
  --hint_scheme = "String",
  --hi_parameter = "Search",
  --handler_opts = {
    --border = "shadow"   -- double, single, shadow, none
  --},
  --decorator = {"***", "***"}  -- or decorator = {"***", "***"}  decorator = {"**", "**"} see markdown help
--})

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

  require('mine.diagnostics').set_diagnostic_level('full')
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

  if config.resolveSupport ~= false then
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      'documentation',
      'detail',
      'additionalTextEdits',
    }
  end

  return capabilities
end
-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
  if server.name == 'sumneko_lua' then
    server:setup {
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
  elseif server.name == 'rust_analyzer' then
    server:setup {
      on_attach = on_attach,
      capabilities = make_capabilities({'snippets', resolveSupport = false}),
    }
  elseif server.name == 'terraformls' then
    server:setup {
      on_attach = on_attach,
      capabilities = make_capabilities({'snippets', resolveSupport = false}),
    }
  else
    server:setup {
      on_attach = on_attach,
      capabilities = make_capabilities({'snippets'}),
    }
  end
end)
