" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

" Always set unix line ending
set fileformat=unix

if empty(glob('~/.vim/autoload/plug.vim'))
  echo "Installing plug.vim ...\n"
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
call plug#begin('~/.vim/plugged')

" The ctrlp
Plug 'kien/ctrlp.vim'
" Alternate files quickly
Plug 'vim-scripts/a.vim'
" uber awesome syntax and errors highlighter
Plug 'Shougo/unite.vim'
" fzf, fast file lister
Plug 'junegunn/fzf'
" use vim-commentary to comment source code quickly
Plug 'tpope/vim-commentary'

" Initialize plugin system
call plug#end()

filetype plugin indent on    " required

inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>

noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

"auto reload .vimrc when changed, this avoids reopening vim
autocmd! bufwritepost .vimrc source %
autocmd! bufwritepost _vimrc source %

" Remove all trailing whitespace on save
" http://stackoverflow.com/questions/356126
autocmd BufWritePre FileType c,cpp,h,js,java,php,ruby,python :%s/\s\+$//e

" Highlight trailing space
highlight UnwanttedTab ctermbg=red guibg=darkred
highlight TrailSpace guibg=red ctermbg=darkred
autocmd ColorScheme * highlight UnwanttedTab ctermbg=red guibg=darkred
autocmd ColorScheme * highlight TrailSpace guibg=red ctermbg=darkred
match UnwanttedTab /\t/
" match TrailSpace / \+$/
match TrailSpace /\s\+$/

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

" show textwidth line
silent! set colorcolumn=80
" define ',' is leader key
let mapleader = ","

" Enable syntax highlighting
syntax on

silent! colorscheme desert
if has("gui_running")
    if has('gui_macvim')
        set guifont="Source\ Code\ Pro\ Medium:h18"
    elseif has('win32')
        set guifont=Source\ Code\ Pro\ Medium:h12:cANSI
        au GUIEnter * simalt ~x
    else
        set guifont=Source\ Code\ Pro\ Medium\ 12
    endif
    set guioptions-=m  "remove menu bar
    set guioptions-=T  "remove toolbar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=L  "remove left-hand scroll bar
    " Maximize gvim window (for an alternative on Windows, see simalt below).
    set lines=2000 columns=2000
else
    set t_Co=256
endif

" Make backspace working on Windows
if has("win32")
    set bs=2
endif
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
" fix the timout when leaving insert mode (see http://usevim.com/2013/07/24/powerline-escape-fix)
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=10
  augroup END
endif

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

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

command! Q q
command! W w

autocmd BufRead,BufNewFile,BufEnter Makefile,makefile,GNUMakefile,*.mk set filetype=make noexpandtab

autocmd FileType java set tabstop=4| set shiftwidth=4 | set expandtab

" autocmd FileType python set tabstop=4 shiftwidth=4 expandtab
" au BufEnter *.py set ai sw=4 ts=4 sta et fo=croql
autocmd FileType *.gyp,*.gypi set filetype=python syntax=python

silent! set undofile                " Save undo's after file closes
silent! set undodir=$HOME/.vim/undo " where to save undo histories
silent! set undolevels=1000         " How many undos
silent! set undoreload=10000        " number of lines to save for undo
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" CtrlP related mappings
let g:ctrlp_map = '<c-p>'
if !has('win32')
    let g:ctrlp_cmd = 'FZF'
else
    let g:ctrlp_cmd = 'CtrlP'
endif
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|a|o|jpg|jpeg|png|gif|bmp|JPG|class|jar|lib)$',
  \ }

let g:ctrlp_match_window = 'results:100' " overcome limit imposed by max height
let g:ctrlp_max_files = 0
let g:ctrlp_max_depth = 400

if executable('ag')
  " Use Ag over Grep
    set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    let g:ctrlp_user_command = {
      \ 'types': {
        \ 1: ['.git', 'git -C %s ls-files --cached --exclude-standard --others'],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
      \ 'fallback': 'ag -l --nocolor -g "" %s'
      \ }
    let $FZF_DEFAULT_COMMAND = 'ag -g "" --depth 20'
else
    let g:ctrlp_user_command = {
      \ 'types': {
        \ 1: ['.git', 'git -C %s ls-files --cached --exclude-standard --others'],
        \ 2: ['.hg', 'hg --cwd %s locate -I .'],
        \ },
      \ 'fallback': 'find %s -type f'
      \ }
endif
