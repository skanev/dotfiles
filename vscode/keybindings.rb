bind 'ctrl+l', 'type', args: {text: ' => '}, when: 'editorLangId == typescript || editorLangId == typescriptreact || editorLangId == javascript || editorLangId = javascriptreact'
bind 'meta+m', 'workbench.action.togglePanel'
bind 'meta+j', '-workbench.action.togglePanel'

bind 'meta+j meta+e', 'editor.action.codeAction', args: {kind: 'refactor.extract.constant'}

bind 'ctrl+up',   'editor.action.smartSelect.expand', when: 'editorTextFocus'
bind 'ctrl+down', 'editor.action.smartSelect.shrink', when: 'editorTextFocus'

bind 'meta+[Slash]', 'editor.action.commentLine',  when: 'editorTextFocus && !editorReadOnly'
bind 'shift+cmd+8',  '-editor.action.commentLine', when: 'editorTextFocus && !editorReadOnly'

# tabs
1.upto(9) do |i|
  bind "meta+#{i}", "workbench.action.openEditorAtIndex#{i}"
end

if VSCode.mod_key == 'cmd'
  ordinals = %w(_Zeroeth First Second Third Fourth Fifth Sixth Seventh Eighth)

  1.upto(8) do |i|
    bind "ctrl+#{i}", "-workbench.action.openEditorAtIndex#{i}"
  end

  1.upto(8) do |i|
    bind "cmd+#{i}", "-workbench.action.focus#{ordinals[i]}EditorGroup"
  end

  bind 'cmd+9', '-workbench.action.lastEditorInGroup'
end
