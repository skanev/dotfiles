vim.api.nvim_exec("set completeopt=menu,menuone,noselect", false)

local cmp = require('cmp')
local types = require('cmp.types')

require('mine.completion.rails_http_status_codes')

require('cmp_nvim_ultisnips').setup {
  --filetype_source = "ultisnips_default",
  filetype_source = "treesitter",
  show_snippets = "expandable",
  documentation = function(snippet)
    return snippet.description
  end
}

local function toggle_as_you_type()
  if require('cmp.config').get().completion.autocomplete == false then
    cmp.setup { completion = { autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged } } }
  else
    cmp.setup { completion = { autocomplete = false } }
    cmp.abort()
  end
end

vim.api.nvim_create_user_command(
  'AutocompleteToggle',
  function() toggle_as_you_type() end,
  {
    nargs = 0,
    desc = 'Toggle as-you-type completion',
  }
)

vim.fn.IMapLeader('imap', {}, '<Space>', '<Cmd>AutocompleteToggle<CR>')

cmp.setup {
  snippet = {
    expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end,
  },
  window = {
    --completion = cmp.config.window.bordered(),
    --documentation = cmp.config.window.bordered(),
  },
  preselect = cmp.PreselectMode.None,
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete({}),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  }),
  formatting = {
    format = (vim.g.tweaks.devicons == 1 and require('lspkind').cmp_format() or nil),
  },
  sources = cmp.config.sources({
    { name = 'ultisnips', priority = 10 },
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
}

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('ruby', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'ultisnips' },
    { name = 'rails_http_status_codes' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('go', {
  preselect = cmp.PreselectMode.Item,
});

cmp.setup.filetype('rust', {
  sorting = {
    comparators = {
      -- Sort snippets below everything else
      function(a, b)
        local a_kind = a:get_kind()
        local b_kind = b:get_kind()
        local snippet_type = types.lsp.CompletionItemKind.Snippet

        if a_kind == snippet_type and b_kind ~= snippet_type then
          return false
        elseif a_kind ~= snippet_type and b_kind == snippet_type then
          return true
        else
          return nil
        end
      end
    }
  }
})
