vim.api.nvim_exec("set completeopt=menu,menuone,noselect", false)

require("cmp_nvim_ultisnips").setup {
  --filetype_source = "ultisnips_default",
  filetype_source = "treesitter",
  show_snippets = "expandable",
  documentation = function(snippet)
    return snippet.description
  end
}

local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end,
  },
  window = {
    --completion = cmp.config.window.bordered(),
    --documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  formatting = {
    format = (vim.g.tweaks.devicons == 1 and require('lspkind').cmp_format() or nil),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
  }, {
    { name = 'buffer' },
  })
})
