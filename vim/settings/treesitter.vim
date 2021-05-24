lua <<EOF
  disabled_languages = { "ruby" }

  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      disable = disabled_languages,
    },
    incremental_selection = {
      enable = true,
      disable = disabled_languages,
      keymaps = {
        init_selection = ",tj",
        node_incremental = ",tn",
        scope_incremental = ",ts",
        node_decremental = ",td",
      }
    },
    playground = {
      enable = true,
      disable = disabled_languages,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      },
    }
  }
EOF