set fileformat=unix

let $MYPLUGDIRECTORY = "~/.vim/plugged"

if empty(glob($MYPLUGDIRECTORY))
  echo "Installing plug.vim ...\n"
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin($MYPLUGDIRECTORY)
Plug 'neovim/nvim-lspconfig'
Plug 'vim-scripts/a.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'main', 'do': ':TSUpdate'}

call plug#end()

filetype plugin indent on

autocmd BufWritePost *vimrc source %

set hidden
set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Remove all trailing whitespace on save
autocmd BufWritePre FileType c,cpp,h,js,java,php,ruby,python,sh :%s/\s\+$//e

highlight UnwantedTab ctermbg=darkred guibg=darkred
highlight TrailSpace ctermbg=red guibg=red
autocmd ColorScheme * highlight UnwantedTab ctermbg=darkred guibg=darkred
autocmd ColorScheme * highlight TrailSpace ctermbg=red guibg=red
call matchadd('TrailSpace', '\s\+$')

function! s:setup_unwanted_tab() abort
  for m in getmatches()
    if m.group ==# 'UnwantedTab'
      call matchdelete(m.id)
    endif
  endfor
  if index(['c','cpp','h','js','java','php','ruby','python','sh'], &filetype) >= 0
    call matchadd('UnwantedTab', '\t')
  endif
endfunction
augroup unwanted_tab
  autocmd!
  autocmd BufWinEnter,FileType * call s:setup_unwanted_tab()
augroup END

set lazyredraw
set ttimeout
set ttimeoutlen=50

set relativenumber
set number

set noswapfile

set enc=utf-8
set fenc=utf-8

set autoindent
set smartindent

set tabstop=2
set shiftwidth=2
set expandtab

set formatoptions-=cro

silent! set colorcolumn=80
syntax on

set nofoldenable

lua <<EOF
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

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
  debounce_text_changes = 150,
}
local common = { on_attach = on_attach, flags = lsp_flags }

vim.lsp.config('pyright', common)

vim.lsp.config('ts_ls', common)

vim.lsp.config('rust_analyzer', vim.tbl_deep_extend('force', common, {
    settings = { ["rust-analyzer"] = {} }
}))

vim.lsp.config('gopls', vim.tbl_deep_extend('force', common, {
    settings = { gopls = { gofumpt = true } }
}))

vim.lsp.config('ccls', {
  on_attach = on_attach,
  init_options = {
    index = { threads = 0 },
    clang = { excludeArgs = { "-frounding-math" } },
  }
})

vim.lsp.enable({ 'pyright', 'ts_ls', 'rust_analyzer', 'gopls', 'ccls' })
require'nvim-treesitter'.install {
  'c', 'cpp', 'go', 'java', 'json', 'python', 'toml', 'tsx', 'vim', 'yaml',
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp', 'go', 'java', 'json', 'python', 'toml', 'tsx', 'vim', 'yaml' },
  callback = function()
    vim.treesitter.start()
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'
  end,
})
EOF

silent! colorscheme default

highlight ColorColumn ctermbg=236

set hlsearch
set showmatch
set comments=sl:/*,mb:\ *,elx:\ */
set wildmode=longest:full
set wildmenu

set showcmd
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set ruler
set laststatus=2
set confirm
set visualbell

command! Q q
command! W update

silent! set undofile
silent! set undodir=$HOME/.vim/undo
silent! set undolevels=1000
silent! set undoreload=10000
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

nnoremap <leader>p :GFiles<cr>
nnoremap <leader>o :Lines<cr>
nnoremap <leader>t :Tags<cr>
nnoremap <leader>r :Buffers<cr>
nnoremap <c-p> :GFiles<cr>

let g:netrw_banner=0
let g:netrw_winsize=20
let g:netrw_liststyle=3
let g:netrw_localrmdir='rm -r'
nnoremap <leader>n :Lexplore<CR>
