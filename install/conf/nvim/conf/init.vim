
syntax on
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Formatting, etc
"
set number

set nocompatible

" colorscheme duskfox

" Backup file settings
set nobackup
set nowritebackup
set noswapfile

" Tab settings
"set backspace=3
set tabstop=4       " Number of spaces that a <Tab> in the file counts for.
set shiftwidth=4    " Number of spaces to use for each step of (auto)indent.
set expandtab       " Use the appropriate number of spaces to insert a <Tab>.
set smarttab        " When on, a <Tab> in front of a line inserts blanks

" Status line
set laststatus=2
set statusline=%f         " Path to the file
set statusline+=\ -\      " Separator
set statusline+=file-type: " Label
set statusline+=%y        " Filetype of the file
set statusline+=%=        " Switch to the right side
set statusline+=colno:\ %-4c\ lineno:\ %-4l\ linecnt:\ %-4L " Line info

" Custom colors
hi StatusLine cterm=bold ctermfg=51 ctermbg=darkgray
hi IncSearch cterm=bold ctermfg=darkred ctermbg=NONE
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=grey ctermbg=darkred

set omnifunc=syntaxcomplete#Complete

" Clipboard
set clipboard+=unnamedplus

" Key remap settings
imap jj <esc>
imap cc <C-X><C-O>
cmap vnt   :NERDTree<CR>

" Commands
command Thtml  :%!tidy -q -i --indent-spaces 4 --show-errors 0
command Txml   :%!tidy -xml -q -i --indent-spaces 4 --show-errors 0

" Templates
au BufNewFile *.xml 0r ~/.vim/templates/skeleton.xml
au BufNewFile *.html 0r ~/.vim/templates/skeleton.html

:set guicursor=
" Workaround some broken plugins which set guicursor indiscriminately.
:autocmd OptionSet guicursor noautocmd set guicursor=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
" Managed via packer.nvim
" https://github.com/wbthomason/packer.nvim
:lua require('plugins')

source ~/.config/nvim/ale.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/colors.vim
