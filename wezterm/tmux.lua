local function is_running_tmux(pane)
  return pane:get_title() == 'tmux' or pane:get_lines_as_text(1):sub(2,4) == "❐"
end

return {
  is_running_tmux = is_running_tmux
}
