" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Always set unix line ending
set fileformat=unix

if has('win32')
    let $MYPLUGDIRECTORY = "~/vimfiles/plugged"
else
    let $MYPLUGDIRECTORY = "~/.vim/plugged"
endif

if empty(glob($MYPLUGDIRECTORY))
  echo "Installing plug.vim ...\n"
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
call plug#begin($MYPLUGDIRECTORY)
"
" Configurations for Nvim LSP
Plug 'neovim/nvim-lspconfig'
" Alternate files quickly
Plug 'vim-scripts/a.vim'
" fzf, fast file lister
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'google/vim-jsonnet'
" use vim-commentary to comment source code quickly
Plug 'tpope/vim-commentary'
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'tpope/vim-sleuth'
Plug 'mattn/webapi-vim'
Plug 'mattn/vim-gist'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" for seamless navigation between vim and tmux
Plug 'christoomey/vim-tmux-navigator'

" Initialize plugin system
call plug#end()

filetype plugin indent on    " required

"auto reload .vimrc when changed, this avoids reopening vim
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost _vimrc source %

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Remove all trailing whitespace on save
" http://stackoverflow.com/questions/356126
autocmd BufWritePre FileType c,cpp,h,js,java,php,ruby,python,sh :%s/\s\+$//e

" Highlight trailing space
highlight UnwanttedTab ctermbg=red guibg=darkred
highlight TrailSpace guibg=red ctermbg=darkred
autocmd ColorScheme * highlight UnwanttedTab ctermbg=red guibg=darkred
autocmd ColorScheme * highlight TrailSpace guibg=red ctermbg=darkred
match UnwanttedTab /\t/
" match TrailSpace / \+$/
match TrailSpace /\s\+$/

" define space is leader key
autocmd InsertEnter * let mapleader = "<NOP>"
autocmd InsertLeave * let mapleader = "\<Space>"

set t_Co=256                        "enable 256 colors

set lazyredraw                                     "lazily redraw screen while executing macros, and other commands
set ttyfast                                        "more characters will be sent to the screen for redrawing
set ttimeout                                       "time waited for key press(es) to complete...
set ttimeoutlen=50                                 " ...makes for a faster key response

" set relative number display
set relativenumber
set number

" disable swap files
set noswapfile
set nobackup
set nowritebackup

" set UTF-8 encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8

" use indentation of previous line
set autoindent
" use intelligent indentation for C
set smartindent

" configure tabwidth and insert spaces instead of tabs
set tabstop=2        " tab width is 4 spaces
set shiftwidth=2     " indent also with 4 spaces
set expandtab        " expand tabs to spaces

set formatoptions-=cro                             "disable auto comments on new lines

" show textwidth line
silent! set colorcolumn=80
" Enable syntax highlighting
syntax on

set nofoldenable
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

lua <<EOF
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
local lspconfig = require'lspconfig'
lspconfig.pyright.setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
lspconfig.tsserver.setup{
    on_attach = on_attach,
    flags = lsp_flags,
}
lspconfig.rust_analyzer.setup{
    on_attach = on_attach,
    flags = lsp_flags,
    -- Server-specific settings...
    settings = {
      ["rust-analyzer"] = {}
    }
}
lspconfig.gopls.setup {
    on_attach = on_attach,
    flags = lsp_flags,
    settings = {
        gopls = {
            gofumpt = true
        }
    }
}
lspconfig.ccls.setup {
  on_attach = on_attach,
  init_options = {
    index = {
      threads = 0;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  }
}
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = false,
  },
  ensure_installed = {
    "c",
    "cpp",
    "go",
    "java",
    "json",
    "python",
    "toml",
    "tsx",
    "vim",
    "yaml",
  },
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
EOF

silent! colorscheme default

highlight ColorColumn ctermbg=236

" show trailing whitespaces
" match ExtraWS /\s\+$/
" highlight all search results
set hlsearch
" highlight matching braces
set showmatch
" intelligent comments
set comments=sl:/*,mb:\ *,elx:\ */
" use intelligent file completion like in the bash
set wildmode=longest:full
set wildmenu

" airline
" use powerline fonts to show beautiful symbols
let g:airline_powerline_fonts = 1
" enable tab bar with buffers
let g:airline#extensions#tabline#enabled = 1

"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Show partial commands in the last line of the screen
set showcmd

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline

"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
" set mouse=a

"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

command! Q q
command! W update

silent! set undofile                " Save undo's after file closes
silent! set undodir=$HOME/.vim/undo " where to save undo histories
silent! set undolevels=1000         " How many undos
silent! set undoreload=10000        " number of lines to save for undo
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" The Silver Searcher
if executable('rg')
  " Use rg over grep
  set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

function! RunCmd(cmd)
    :call system(a:cmd)
    return v:shell_error
endfunction

" A wrapper function to invoke FZF after setting right
" FZF_DEFAULT_COMMAND env variable based on the current
" working directory's VCS
function! InvokeFZF()
    " set fzf file finder based on the current working directory's VCS
    if RunCmd('hg root') == 0
        let $FZF_DEFAULT_COMMAND='hg files --include .'
    elseif RunCmd('git rev-parse --show-toplevel') == 0
      if has('win32')
          let $FZF_DEFAULT_COMMAND='(git ls-files --cached & git ls-files --others
                                    \ --exclude-standard)'
      else
          let $FZF_DEFAULT_COMMAND='{ git ls-files --cached & git ls-files --others
                                    \ --exclude-standard; }'
      endif
    elseif executable('rg')
        let $FZF_DEFAULT_COMMAND='rg --files --smart-case'
    endif
    :FZF
endfunction

" fuzzy finder
nnoremap <leader>p :call InvokeFZF()<cr>
nnoremap <leader>o :Lines<cr>
nnoremap <leader>t :Tags<cr>
nnoremap <leader>r :Buffers<cr>
nnoremap <c-p> :call InvokeFZF()<cr>

"netrw
let g:netrw_banner=0
let g:netrw_winsize=20
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'
nnoremap <leader>n :Lexplore<CR>

