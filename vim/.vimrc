call plug#begin('~/.vim/plugged')

Plug 'mhinz/vim-startify'       " Vim startup screen
Plug 'Valloric/YouCompleteMe'   " Python, C#, Go, Rust auto-complete
Plug 'dense-analysis/ale'       " ALE: Real-time syntax checking, linting, etc.
Plug 'preservim/nerdcommenter'  " Easy commenting plugin
Plug 'plasticboy/vim-markdown'  " Markdown support
Plug 'lervag/vimtex'            " LaTeX support
Plug 'junegunn/goyo.vim'        " Distraction-free writing
Plug 'nvie/vim-flake8'          " Python PEP8 feedback
Plug 'vimwiki/vimwiki'          " Wiki / 'org-mode' plugin
Plug 'preservim/nerdtree'       " File tree side bar
Plug 'tpope/vim-surround'       " Surround text objects with text
Plug 'godlygeek/tabular'        " Align elements with spaces

call plug#end()

" General options
" -----------------------------------------------------------------------------
syntax on
let mapleader = " "
set encoding=utf-8
set number relativenumber
set splitbelow splitright
set noerrorbells
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set textwidth=119
set colorcolumn=120
set list
set listchars=tab:█▒,trail:▒
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set scrolloff=4
set sidescrolloff=5
nnoremap <CR> :noh<CR>
hi ColorColumn ctermbg=3

" Copy to system clipboard
" -----------------------------------------------------------------------------
let @c = ':w !xclip -selection clipboard'

" Status bar options
" -----------------------------------------------------------------------------
au InsertEnter * hi StatusLine ctermfg=4
au InsertLeave * hi StatusLine ctermfg=15

" NERDTree options
" -----------------------------------------------------------------------------
au User StartifyBufferOpened NERDTree

" NERD Commenter options
" -----------------------------------------------------------------------------
let g:NERDCreateDefaultMappings = 1

" YouCompleteMe options
" -----------------------------------------------------------------------------
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
let g:ycm_autoclose_preview_window_after_completion=1
let python_highlight_all=1
