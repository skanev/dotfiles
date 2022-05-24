local lower_keys = [[abcdefghijklmnopqrstuvwxyz`1234567890-=[]\;,./']]
local upper_keys = [[ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:<>?"]]

local layout = {
  all_keys = vim.split(lower_keys .. upper_keys, ''),
  modifiable_keys = vim.split([[abcdefghijklmnopqrstuvwxyz1234567890-=[];',./]], ""),
  images = {
    double_wide = [[
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬────────┐
│ ` ~ │ 1 ! │ 2 @ │ 3 # │ 4 $ │ 5 % │ 6 ^ │ 7 & │ 8 * │ 9 ( │ 0 ) │ - _ │ = + │ delete │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬─────┤
│ tab    │ q Q │ w W │ e E │ r R │ t T │ y Y │ u U │ i I │ o O │ p P │ [ { │ ] } │ \ | │
├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┤
│ caps     │ a A │ s S │ d D │ f F │ g G │ h H │ j J │ k K │ l L │ ; : │ ' " │  return │
├──────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────┤
│ shift       │ z Z │ x X │ c C │ v V │ b B │ n N │ m M │ , < │ . > │ / ? │      shift │
├─────┬─────┬─┴───┬─┴───┬─┴─────┴─────┴─────┴─────┴─────┴┬────┴┬────┴┬────┴┬─────┬─────┤
│ fn  │  ⌃  │  ⌥  │  ⌘  │              space             │  ⌘  │  ⌥  │  ◀︎  ├─────┤  ▶︎  │
└─────┴─────┴─────┴─────┴────────────────────────────────┴─────┴─────┴─────┴─────┴─────┘
]],
    double_narrow = [[
┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────────┐
│ `~ │ 1! │ 2@ │ 3# │ 4$ │ 5% │ 6^ │ 7& │ 8* │ 9( │ 0) │ -_ │ =+ │ delete │
├────┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──────┤
│ tab  │ qQ │ wW │ eE │ rR │ tT │ yY │ uU │ iI │ oO │ pP │ [{ │ ]} │  \|  │
├──────┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴─┬──┴──────┤
│ caps   │ aA │ sS │ dD │ fF │ gG │ hH │ jJ │ kK │ lL │ ;: │ '" │  return │
├────────┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴──┬─┴─────────┤
│ shift     │ zZ │ xX │ cC │ vV │ bB │ nN │ mM │ ,< │ .> │ /? │     shift │
├────┬─────┬┴──┬─┴───┬┴────┴────┴────┴────┴────┴───┬┴────┼───┬┴──┬────┬───┤
│ fn │  ⌃  │ ⌥ │  ⌘  │             space           │  ⌘  │ ⌥ │ ◀︎ ├────┤ ▶︎ │
└────┴─────┴───┴─────┴─────────────────────────────┴─────┴───┴───┴────┴───┘
]],
    single_wide = [[
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬────────┐
│  `  │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │  -  │  =  │ delete │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬─────┤
│ tab    │  q  │  w  │  e  │  r  │  t  │  y  │  u  │  i  │  o  │  p  │  [  │  ]  │  \  │
├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┤
│ caps     │  a  │  s  │  d  │  f  │  g  │  h  │  j  │  k  │  l  │  ;  │  '  │  return │
├──────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────┤
│ shift       │  z  │  x  │  c  │  v  │  b  │  n  │  m  │  ,  │  .  │  /  │      shift │
├─────┬─────┬─┴───┬─┴───┬─┴─────┴─────┴─────┴─────┴─────┴┬────┴┬────┴┬────┴┬─────┬─────┤
│ fn  │  ⌃  │  ⌥  │  ⌘  │             space              │  ⌘  │  ⌥  │  ◀︎  ├─────┤  ▶︎  │
└─────┴─────┴─────┴─────┴────────────────────────────────┴─────┴─────┴─────┴─────┴─────┘
]],
    single_narrow = [[
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────────┐
│ ` │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │ 9 │ 0 │ - │ = │ delete │
├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬──────┤
│ tab │ q │ w │ e │ r │ t │ y │ u │ i │ o │ p │ [ │ ] │   \  │
├─────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴──────┤
│ caps  │ a │ s │ d │ f │ g │ h │ j │ k │ l │ ; │ ' │ return │
├───────┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴────────┤
│ shift   │ z │ x │ c │ v │ b │ n │ m │ , │ . │ / │    shift │
├────┬───┬┴──┬┴──┬┴───┴───┴───┴───┴───┴─┬─┴─┬─┴─┬─┴─┬────┬───┤
│ fn │ ⌃ │ ⌥ │ ⌘ │         space        │ ⌘ │ ⌥ │ ◀︎ ├────┤ ▶︎ │
└────┴───┴───┴───┴──────────────────────┴───┴───┴───┴────┴───┘
]]
  },
  named_keys = { 'shift', 'space', 'tab', 'delete', 'caps', 'fn' }
}

return layout