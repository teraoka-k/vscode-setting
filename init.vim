set clipboard+=unnamedplus

call plug#begin()
  if !exists('g:vscode')
    Plug 'easymotion/vim-easymotion'
  else
    Plug 'asvetliakov/vim-easymotion'
  endif
call plug#end()

let mapleader = " "

let g:EasyMotion_smartcase = 1
map s <Plug>(easymotion-s)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

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

  "fix error
  nnoremap f :call VSCodeNotify("editor.action.quickFix")<CR>

endif
