set clipboard+=unnamedplus
call plug#begin()
if !exists('g:vscode')
Plug 'easymotion/vim-easymotion'
else
Plug 'asvetliakov/vim-easymotion'
call plug#end()
map s <Plug>(easymotion-s2)
map f <Plug>(easymotion-w)
map F <Plug>(easymotion-b)
