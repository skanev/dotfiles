local gitsigns = require('gitsigns')

gitsigns.setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', 'yog', '<Cmd>Gitsigns toggle_signs<CR>')
    map('n', '<leader>hp', '<Cmd>Gitsigns preview_hunk<CR>')
    map('n', '<leader>hP', function() gs.blame_line { full = true } end)
    map('n', '<leader>hb', '<Cmd>Gitsigns toggle_current_line_blame<CR>')
    map('n', '<leader>hd', '<Cmd>Gitsigns diffthis<CR>')
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>hc', '<Cmd>Gitsigns toggle_deleted<CR>')
  end
}
