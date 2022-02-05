call plug#begin('~/.vim/plugged')

Plug 'sainnhe/gruvbox-material'  " Gruvbox theme
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'          " Fuzzy search, required by dashboard-nvim
Plug 'glepnir/dashboard-nvim'    " Vim startup screen
Plug 'folke/which-key.nvim'      " Show possible keybinds
Plug 'kyazdani42/nvim-tree.lua'  " File tree side bar
Plug 'beauwilliams/focus.nvim'   " Auto-resizing focused splits/windows
Plug 'karb94/neoscroll.nvim'     " Smooth scrolling
Plug 'nvim-lualine/lualine.nvim' " Status line
Plug 'romgrk/barbar.nvim'        " Tablines
Plug 'wfxr/minimap.vim'          " Minimap for code (requires code-minimap executable)
Plug 'SmiteshP/nvim-gps'         " Status component to show context of current cursor position
Plug 'mhinz/vim-signify'         " Signifiy: sign colum to indicate VCS diffs
Plug 'AndrewRadev/splitjoin.vim' " Switch between single- and multi-line forms
Plug 'folke/todo-comments.nvim'  " Highlight todo comments
Plug 'monaqa/dial.nvim'          " Increment/decrement numbers
Plug 'norcalli/nvim-colorizer.lua' " Highlight colour codes in their colour
Plug 'winston0410/cmd-parser.nvim' " Required by range-highlight.nvim
Plug 'winston0410/range-highlight.nvim' " Highlights ranges in commandline
Plug 'lukas-reineke/indent-blankline.nvim' " Show indent levels
Plug 'RRethy/vim-illuminate'     " Highlight same words under cursor
Plug 'sunjon/shade.nvim'         " Dim unfocused windows
Plug 'junegunn/vim-easy-align'   " Align elements with spaces
Plug 'tpope/vim-surround'        " Surround text objects with text
Plug 'windwp/nvim-autopairs'     " Autopair plugin
Plug 'numToStr/Comment.nvim'     " Easy commenting plugin
Plug 'nvim-lua/plenary.nvim'     " Required by neorg
Plug 'nvim-neorg/neorg'          " Neovim Emacs-like org mode
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Advanced syntax highlighting
Plug 'neovim/nvim-lspconfig'     " Enable LSP for most of every language
Plug 'simrat39/rust-tools.nvim'  " Extra Rust LSP support
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'} " Autocompletion on steroids
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'ellisonleao/glow.nvim'     " Markdown support

call plug#end()

" General options
" -----------------------------------------------------------------------------

syntax on
let mapleader=" "
filetype plugin indent on
set ttyfast
set encoding=utf-8
set clipboard=unnamedplus
set updatetime=250
set timeoutlen=250
set number relativenumber
set splitbelow splitright
set noerrorbells
set noswapfile
set nobackup
set undofile
set textwidth=119
set colorcolumn=120
set list
set listchars=tab:█▒,trail:▒
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set scrolloff=4
set sidescrolloff=5

" Theme configuration
" -----------------------------------------------------------------------------

set termguicolors
set background=dark
let g:gruvbox_material_enable_bold = 1
let g:gruvbox_material_palette = 'original'
let g:gruvbox_material_statusline_style = 'original'
colorscheme gruvbox-material " Has to be last

" Remappings & keybinds
" -----------------------------------------------------------------------------

map <PageUp> <C-b>
map <PageDown> <C-f>
nmap <C-a> <Plug>(dial-increment)
nmap <C-x> <Plug>(dial-decrement)
vmap <C-a> <Plug>(dial-increment)
vmap <C-x> <Plug>(dial-decrement)

" Startup & autocmd
" -----------------------------------------------------------------------------

autocmd FileType dashboard set showtabline=0 | autocmd WinLeave <buffer> set showtabline=2

" Plugin options
" -----------------------------------------------------------------------------

let g:dashboard_default_executive ='fzf'
let g:dashboard_custom_shortcut_icon = {}
let g:dashboard_custom_shortcut_icon['last_session'] = ' '
let g:dashboard_custom_shortcut_icon['find_history'] = ' '
let g:dashboard_custom_shortcut_icon['find_file'] = ' '
let g:dashboard_custom_shortcut_icon['new_file'] = ' '
let g:dashboard_custom_shortcut_icon['change_colorscheme'] = ' '
let g:dashboard_custom_shortcut_icon['find_word'] = ' '
let g:dashboard_custom_shortcut_icon['book_marks'] = ' '
let g:dashboard_custom_header =<< trim END
⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⣤⡤
⠘⢿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠛⠛⣛⣛⣻⣿⣿⠟⠁⠀⠀⢀⣤⢤⣤⣤⡤⠀⠀⠀⠀⢤⣤⣤⣤⣤⡄⠀⠀⠈⠻⣿⣿⣿⣛⣛⡛⠛⠛⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿⡿⠋⠀
⠀⠀⠀⣤⣤⣤⣤⣤⣤⣴⣶⣶⣶⣶⣶⣾⣿⣿⡿⠿⠿⣛⣻⣿⣿⡏⠀⠀⠀⣤⣴⠝⠺⢿⢫⣶⣄⡀⠀⣠⣴⣌⢿⠟⠫⢵⣤⡀⠀⠀⠘⣿⣿⣟⣛⡿⠿⠿⣿⣿⣿⣶⣶⣶⣶⣶⣦⣤⣤⣤⣤⣤⣤⠀⠀⠀⠀
⠀⠀⠀⠈⠻⣿⣿⣿⠿⠿⠟⠛⠛⠉⣉⣩⣤⣴⣶⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠙⠀⠀⠀⠀⠙⢿⣿⠃⡌⢿⣿⠏⠀⠀⠀⠀⠋⠀⠀⠀⢀⣿⣿⡿⣿⣿⣿⣶⣶⣤⣌⣉⡉⠛⠛⠻⠿⠿⣿⣿⣿⠟⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⣶⣿⣿⣿⣿⣿⠿⠟⢋⣩⣴⣾⢿⣿⣿⣦⣀⣀⣀⣠⣤⣶⣾⣷⣌⠋⣼⣷⠘⢁⣴⣿⣶⣦⣄⣀⣀⣀⣤⣾⣿⣿⣿⣶⣭⡙⠛⠿⣿⣿⣿⣿⣿⣶⣶⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⠿⠟⠋⠉⣀⣤⣾⣿⡿⢟⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⣿⡟⢰⣿⣿⣧⠸⣿⣟⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣮⡙⢿⣿⣷⣦⣄⡈⠙⠛⠿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⣀⣤⣶⣿⣿⣿⠿⠋⣠⣿⣿⠟⣽⣿⡟⣽⣿⢹⣿⠘⣣⣿⡿⢠⣿⣿⣿⣿⡆⢻⣿⣮⠃⣿⣿⢿⣿⠹⣿⣷⡹⣿⣿⣦⡉⠻⣿⣿⣿⣷⣦⣀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣿⡿⠟⠁⣠⣾⣿⡿⢋⣼⣿⡟⢰⣿⡏⢸⠟⣴⣿⣿⠃⣾⣿⣿⣿⣿⣿⡌⢿⣿⣧⡙⢿⠸⣿⣇⢹⣿⣷⡈⢿⣿⣿⣦⡈⠙⢿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠠⣾⣿⣿⠟⢁⣾⣿⡿⢁⣿⣿⠃⠁⠈⠙⠿⠇⣸⣿⣿⣿⣿⣿⣿⣷⠘⡿⠛⠁⠀⠀⢿⣿⡄⢻⣿⣿⡄⠙⣿⣿⣿⠆⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠃⠠⠾⠿⡿⠁⠸⠋⠀⠀⠀⠀⠀⠀⠰⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠙⠳⠀⢻⡿⠿⠄⠈⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣦⡌⢻⣿⣿⣿⣿⡟⢁⣴⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡟⢀⡾⣹⣿⡿⣯⢻⡄⠹⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⢛⣿⣿⣄⠸⢣⡿⣼⣿⢹⡆⠟⢠⣿⣿⡟⠻⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠃⠾⠋⠀⠀⠁⣿⣿⠇⠁⠀⠙⠻⡈⢿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠧⠀⠀⠀⠀⠀⠀⠈⠃⠀⠀⠀⠀⠀⠀⠴⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
              \\+++ T H E  E M P E R O R  P R O T E C T S +++//
               \\+++-+++-+++-+++ N E O V I M +++-+++-+++-+++//
END
let g:dashboard_custom_section={
  \ 'buffer_list': {
    \ 'description': ['Recently opened files'],
    \ 'command': 'DashboardFindHistory' },
  \ 'new_file': {
    \ 'description': ['Create new file'],
    \ 'command': 'DashboardNewFile' },
  \ 'last_session': {
    \ 'description': ['Open last session'],
    \ 'command': 'SessionLoad' },
  \ 'find_file': {
    \ 'description': ['Find file'],
    \ 'command': 'DashboardFindFile' },
  \ 'find_word': {
    \ 'description': ['Find word'],
    \ 'command': 'DashboardFindWord' },
  \ }

let bufferline = get(g:, 'bufferline', {})
let bufferline.icons = v:false
let bufferline.icon_separator_active = '█'
let bufferline.icon_separator_inactive = '▎'
let bufferline.icon_close_tab = 'X'
let bufferline.icon_close_tab_modified = '?'
let bufferline.icon_pinned = 'O'

let g:nvim_tree_icons = {
  \ 'default': ".",
  \ 'symlink': "@",
  \ 'git': {
  \   'unstaged': "X",
  \   'staged': "V",
  \   'unmerged': "U",
  \   'renamed': "/",
  \   'untracked': "*",
  \   'deleted': "D",
  \   'ignored': "I"
  \   },
  \ 'folder': {
  \   'arrow_open': ">",
  \   'arrow_closed': "|",
  \   'default': "-",
  \   'open': "0",
  \   'empty': "E",
  \   'empty_open': "O",
  \   'symlink': "@",
  \   'symlink_open': "£",
  \   }
  \ }
let g:nvim_tree_respect_buf_cwd = 1

let g:minimap_width = 16
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1
let g:minimap_highlight_range = 1
let g:minimap_close_filetypes = ['startify', 'netrw', 'vim-plug', 'dashboard']

" Lua configuration & keybindings
" -----------------------------------------------------------------------------

lua << END
-- Initialise which-key and keybinds
local wk = require("which-key")
-- NORMAL MODE which-keys
wk.register({

  -- GENERAL BINDINGS
  -- Top level
  ["<leader>d"] = { "<cmd>Dashboard<cr>", "Open Dashboard" },
  ["<leader>n"] = { "<cmd>NvimTreeToggle<cr>", "Toggle NvimTree" },
  ["<leader>|"] = { "<cmd>vsplit<cr>", "Vertical split" },
  ["<leader>-"] = { "<cmd>split<cr>", "Horizontal split" },
  -- splitjoin.vim
  ["gS"] = {"One line to multiple" },
  ["gJ"] = {"Multiple lines to one" },
  -- vim-easy-align
  ["ga"] = { "<cmd>EasyAlign<cr>", "Easy align" },
  -- Utilities
  ["<leader>u"] = { name = "Utilities"},
  ["<leader>up"] = { "<cmd>PlugUpdate<cr>", "Plug Update" },
  ["<leader>ug"] = { "<cmd>Glow<cr>", "Markdown preview" },
  -- buffers
  ["<leader>b"] = { name = "Buffer" },
  ["<leader>be"] = { "<cmd>new<cr>", "New buffer" },
  ["<leader>bd"] = { "<cmd>bd<cr>", "Delete buffer" },
  ["<leader>bn"] = { "<cmd>bn<cr>", "Next buffer" },
  ["<leader>bp"] = { "<cmd>bp<cr>", "Previous buffer" },
  -- windows
  ["<leader>w"] = { name = "Window" },
  ["<leader>wd"] = { "<cmd>q<cr>", "Delete window" },
  ["<leader>wf"] = { "<cmd>q!<cr>", "Force delete window" },
  ["<leader>wa"] = { "<cmd>qa<cr>", "Quit" },
  ["<leader>w!"] = { "<cmd>qa!<cr>", "Force quit" },

  -- PLUGIN BINDINGS
  -- Comment.nvim
  ["gc"] = { name = "Comment line" },
  ["gcc"] = { "Comment line linewise" },
  ["gb"] = { name = "Comment block" },
  ["gbc"] = { "Comment line blockwise" },
  -- vim-surround
  ["ds"] = { "Surroundings" },
  ["cs"] = { "Surroundings" },
  ["cS"] = { "Surroundings own line" },
  ["ys"] = { "Surroundings" },
  ["yS"] = { "Surroundings own line" },
  ["yss"] = { "Ignore leading whitespace" },
  ["ySS"] = { "Ignore leading whitespace" },
  -- rust-tools.nvim
  ["<leader>r"] = { name = "Rust" },
  ["<leader>rd"] = { "<cmd>lua require'rust-tools.hover_actions'.hover_actions()<cr>", "Show ref/doc" },
  ["<leader>re"] = { "<cmd>lua require'rust-tools.expand_macro'.expand_macro()<cr>", "Expand macro" },
  ["<leader>ri"] = { "<cmd>RustToggleInlayHints<cr>", "Toggle inlay hints" },
  ["<leader>rj"] = { "<cmd>lua require'rust-tools.join_lines'.join_lines()<cr>", "Join lines" },
})

-- VISUAL MODE which-keys
wk.register({
  -- vim-easy-align
  ["ga"] = { "<cmd>EasyAlign<cr>", "Easy align" },
  -- Comment.nvim
  ["gc"] = { "Comment line" },
  ["gb"] = { "Comment block" },
  -- vim-surround
  ["gS"] = { "Surroundings" },
}, { mode = "v" })

-- Initialise and configure plugins
require('focus').setup{}
require('nvim-gps').setup{ disable_icons = true }
require("indent_blankline").setup { filetype_exclude = { "dashboard", "NvimTree" } }
require('range-highlight').setup{}
require('colorizer').setup{}
require('shade').setup{}
require('Comment').setup{}
require('neorg').setup{ load = { ["core.defaults"] = {} } }

local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()
-- These two are optional and provide syntax highlighting
-- for Neorg tables and the @document.meta tag
parser_configs.norg_meta = {
  install_info = {
    url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
    files = { "src/parser.c" },
    branch = "main"
  },
}
parser_configs.norg_table = {
  install_info = {
    url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
    files = { "src/parser.c" },
    branch = "main"
  },
}
require('nvim-treesitter.configs').setup{
  ensure_installed = { "bash", "rust", "python", "go", "norg", "norg_meta", "norg_table", "markdown"},
  highlight = { enable = true }
}

require('todo-comments').setup{
  keywords = {
    FIX = { icon = "@", color = "info", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
    TODO = { icon = "#", color = "info" },
    HACK = { icon = "%", color = "warning" },
    WARN = { icon = "!", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = "~", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = "?", color = "hint", alt = { "INFO" } },
  }
}

require('nvim-tree').setup{
 view = {
  mappings = {
    custom_only = false,
    list = {
      { key = {"<C-r>"}, action = "cd" },
      { key = {"gr"}, action = "full_rename" },
      },
    },
  },
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
  auto_close = true,
  open_on_tab = true,
}

require('neoscroll').setup{}
local t = {}
t['gg'] = {'scroll', {'-2*vim.api.nvim_buf_line_count(0)', 'true', '1', '5', e}}
t['G'] = {'scroll', {'2*vim.api.nvim_buf_line_count(0)', 'true', '1', '5', e}}
require('neoscroll.config').set_mappings(t)

local get_color = require'lualine.utils.utils'.extract_highlight_colors
local gps = require('nvim-gps')
require('lualine').setup {
  options = {
    theme = 'gruvbox-material', 
    disabled_filetypes = { 'minimap', 'NvimTree' },
  },
  sections = {
  lualine_b = {
    { 'branch' }, { 'diff' }, { gps.get_location, cond = gps.is_available },
    {
      'diagnostics',
      -- Table of diagnostic sources, available sources are:
      --   'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp'.
      -- or a function that returns a table as such:
      --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
      sources = { 'nvim_lsp' },

      -- Displays diagnostics for the defined severity types
      sections = { 'error', 'warn', 'info', 'hint' },

      diagnostics_color = {
      -- Same values as the general color option can be used here.
        error = {fg = get_color("DiagnosticError", "fg")},
        warn = {fg = get_color("DiagnosticWarn", "fg")},
        info = {fg = get_color("DiagnosticInfo", "fg")},
        hint = {fg = get_color("DiagnosticHint", "fg")},
      },
      symbols = {error = 'E', warn = 'W', info = 'I', hint = 'H'}
    }
  },
  lualine_x = {
    { 'encoding' },
    {
      'fileformat',
      symbols = {
        unix = 'UNIX',  -- e712
        dos = 'MS-DOS', -- e70f
        mac = 'macOS',  -- e711
      }
    },
    { 'filetype' }
  }
}
}

-- nvim-autopairs configuration to work with coq_nvim
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false } }

remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

_G.MUtils= {}

MUtils.CR = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<c-y>')
    else
      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
    end
  else
    return npairs.autopairs_cr()
  end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
    return npairs.esc('<c-e>') .. npairs.autopairs_bs()
  else
    return npairs.autopairs_bs()
  end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })

vim.g.coq_settings = {
  auto_start = true,
  display = { icons = { mode = 'none'} }
}

-- LSP configuration
local lsp = require "lspconfig"
local coq = require "coq"
require('lspconfig').rust_analyzer.setup{}
require('rust-tools').setup{}
lsp.rust_analyzer.setup{coq.lsp_ensure_capabilities()}

END
