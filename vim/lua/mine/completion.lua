local cmp = require('cmp')
local types = require('cmp.types')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

vim.api.nvim_exec("set completeopt=menu,menuone,noselect", false)

-- LuaSnip configuration --

luasnip.config.set_config {
  history = false,
  --delete_check_events = 'TextChanged',
  --update_events = 'TextChanged,TextChangedI',
  --region_check_events = 'CursorMoved,CursorHold,InsertEnter',
  enable_autosnippets = true,
  ext_opts = {
    [require('luasnip.util.types').choiceNode] = {
      active = {
        virt_text = { { 'o', 'Substitute' } }
      }
    }
  }
}

require('luasnip.loaders.from_vscode').load { paths = { '~/.vim/snippets/vscode' } }
require('luasnip.loaders.from_lua').load { paths = { '~/.vim/snippets/luasnippets' } }

do
  local keymap = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }

  keymap('i', '<c-j>', "<cmd>lua require('luasnip').jump(1)<CR>", opts)
  keymap('s', '<c-j>', "<cmd>lua require('luasnip').jump(1)<CR>", opts)
  keymap('i', '<c-k>', "<cmd>lua require('luasnip').jump(-1)<CR>", opts)
  keymap('s', '<c-k>', "<cmd>lua require('luasnip').jump(-1)<CR>", opts)
end

-- Custom completions --

require('mine.completion.rails_http_status_codes')

-- Toggle as you type completion --

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

-- General setup --

cmp.setup {
  snippet = {
    expand = function(args) require('luasnip').lsp_expand(args.body) end,
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

    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expandable() then
        luasnip.expand({})
      elseif luasnip.locally_jumpable(1) and cmp.get_entries()[1] and cmp.get_entries()[1].exact then -- don't force me to tab twice when matched
        luasnip.jump(1)
      elseif cmp.get_active_entry() then
        cmp.comfirm()
      elseif cmp.visible() then
        cmp.confirm { select = true }
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  formatting = {
    format = lspkind.cmp_format {
      mode = (vim.g.tweaks.devicons == 1 and 'symbol_text' or 'text'),
      max_width = 50,
      ellipsis_char = '...',
      menu = {
        buffer = "[buffer]",
        nvim_lsp = "[lsp]",
        luasnip = "[luasnip]",
        rails_http_status_codes = "[mine]",
        cmp_git = "[git]",
      }
    }
  },
  sources = cmp.config.sources({
    { name = 'luasnip', priority = 10 },
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
}

-- Custom filetypes --

cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.filetype('ruby', {
  sources = cmp.config.sources({
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
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
