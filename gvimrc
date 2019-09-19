if has('gui_macvim')
    set guifont=Source\ Code\ Pro\ Medium:h18
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
set guiheadroom=0
"
" Remove balloon
set noballooneval
let g:netrw_nobeval = 1

" show console dialogs
set guioptions+=c

" Silent bell
autocmd GUIEnter * set vb t_vb=
