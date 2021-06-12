set clipboard+=unnamedplus

call plug#begin()
  if !exists('g:vscode')
    Plug 'easymotion/vim-easymotion'
  else
    Plug 'asvetliakov/vim-easymotion'
  endif
call plug#end()

map s <Plug>(easymotion-s2)
nmap j gj
nmap k gk

"vscode keybindings
if exists('g:vscode')

  "use vs-code featrues instead
  :filetype plugin off

  "close
  nnoremap x :call VSCodeNotify("workbench.action.closeActiveEditor")<CR>
  nnoremap X :call VSCodeNotify("workbench.action.reopenClosedEditor")<CR>
  nnoremap <c-x> :call VSCodeNotify("workbench.action.closeAllEditors")<CR>

  "tab
  autocmd FileType * nnoremap <nowait> ] :call VSCodeNotify("workbench.action.nextEditor")<CR>
  autocmd FileType * nnoremap <nowait> [ :call VSCodeNotify("workbench.action.previousEditor")<CR>
  nnoremap <c-]> :call VSCodeNotify("workbench.action.moveEditorRightInGroup")<CR>
  nnoremap <c-[> :call VSCodeNotify("workbench.action.moveEditorLeftInGroup")<CR>
  
  "navigation
  nnoremap ; :call VSCodeNotify("editor.action.revealDefinition")<CR>
  nnoremap , :call VSCodeNotify("workbench.action.navigateBack")<CR>

endif

