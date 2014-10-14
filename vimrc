
" Default to NERDtree if a particular file wasn't specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" make CTRL + N shortcut for opening NERDtree
map <C-n> :NERDTreeToggle<CR>

" load Pathogen packages
execute pathogen#infect()

" JS-VIM plugin settings
syntax on
filetype plugin indent on
set backspace=indent,eol,start
set tabstop=2 shiftwidth=2 expandtab
set number

" Solarized theme settings
syntax enable
set background=dark
colorscheme solarized
