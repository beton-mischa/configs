"                       __   _ _ _ __ ___  _ __ ___
"                       \ \ / / | '_ ` _ \| '__/ __|
"                        \ V /| | | | | | | | | (__ 
"                         \_/ |_|_| |_| |_|_|  \___|

" Be iMproved
set nocompatible

"=====================================================
"" Vundle settings
"=====================================================
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
    "-------------------=== Vundle ===-------------------------------
    Plugin 'VundleVim/Vundle.vim'
    "-------------------=== Style ===-------------------------------
    Plugin 'morhetz/gruvbox'
    Plugin 'luochen1990/rainbow'
    "-------------------=== Other ===-------------------------------
    Plugin 'bling/vim-airline'
    Plugin 'vim-airline/vim-airline-themes'
    "-------------------=== GIT ===-------------------------------
    Plugin 'tpope/vim-fugitive'
    Plugin 'airblade/vim-gitgutter'
    Plugin 'mhinz/vim-signify'
    call vundle#end()
" keep indentation disabled - fucks shit up every time
"filetype plugin indent on

"" VIM settings
"=====================================================
set backspace=indent,eol,start
syntax enable
" tabs
set tabstop=4
set expandtab
set ruler
set ttyfast
set cursorline
set showmatch
set enc=utf-8
set exrc
set secure
" toggle paste mode
set pastetoggle=<F3>
" enable numbers by default
set number
" toggle line numbers
noremap <F4> :set invnumber<CR>
inoremap <F4> <C-O>:set invnumber<CR>
" Always show the status line
set laststatus=2
set nobackup
set nowb
set noswapfile
" make special chars visible
" - line breaks
set listchars=eol:¶
" - spaces
set lcs+=space:·
"set list 
" toggle set list
nnoremap <F2> :set list!<CR>

"" Style settings
"=====================================================
set termguicolors
colorscheme gruvbox
set background=dark
"set cpoptions+=n
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

"" Search settings
"=====================================================
set incsearch	                            " incremental search
set hlsearch	                            " highlight search results

"" AirLine settings
"=====================================================
let g:airline_powerline_fonts=1
"let g:Powerline_symbols='unicode'
"let g:airline_theme='badwolf'
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail'
"let g:airline#extensions#hunks#enabled=1
"let g:airline#extensions#branch#enabled=1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline_section_z = "%3p%% %l:%c"

"" GIT settings
"=====================================================
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = '^'
let g:gitgutter_sign_modified_removed = '<'
let g:gitgutter_override_sign_column_highlight = 1
highlight SignColumn guibg=bg
highlight SignColumn ctermbg=bg

