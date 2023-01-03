" Use vim settings, rather then vi
set nocompatible

" Enamble Pathgen plugin manager
execute pathogen#infect()

" save swap files to $HOME/.vimswap
" automatic dir create only works on linux
silent !mkdir -p $HOME/.vimswap
set directory=$HOME/.vimswap//

set tabpagemax=300

"--------------------------
" --  Default formating  --
"--------------------------
set autoindent "Auto indent
set smartindent "Smart indent
set shiftwidth=2 "indent width (for << , >>)
set softtabstop=2 " how many columns when hit Tab in insert mode
set tabstop=2 " tab width
set expandtab "expand tabs
set guifont=Monospace\ 13 " Bigger font than normal
syntax on " Syntax highlight
set colorcolumn=81
set textwidth=80

"-------------------------
" --  Editor behavior   --
"-------------------------
set number " Line numbers
set showmode " always show what mode we're currently editing in
set visualbell " don't beep
set noerrorbells " don't beep

filetype plugin on " Enable filetype plugin
set showmode " Always show current mode
set display=lastline
set cursorline
set hlsearch
set incsearch " show search matches as you type
set mousemodel=popup
set ruler " show the cursor position all the time
set conceallevel=0 " prevent conceal characters

" colorscheme
colorscheme molokai_noitalic
set t_Co=256
hi Search guibg=DarkGreen guifg=White

" Hide gui elements
set go-=m
set go-=T
set go-=r
set go-=L

" Reload changes to .vimrc automatically
autocmd BufWritePost  ~/.vimrc source ~/.vimrc

" Set to auto read when a file is changed from the outside
set autoread

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" ---------------------------------------
" -- Settings for different file types --
" ---------------------------------------

" In Makefiles DO NOT use spaces instead of tabs
autocmd FileType make setlocal noexpandtab

" txt files
autocmd BufRead,BufNewFile *.txt setlocal wrap linebreak nolist wm=0 cc=0 tw=0 syntax=off noexpandtab

" bash files
autocmd BufRead,BufNewFile *.sh setlocal wrap shiftwidth=2 softtabstop=2 tabstop=2 expandtab

" story files, TODO:expand settings for norm page
autocmd BufRead,BufNewFile *.st setlocal wrap linebreak nolist wm=0 cc=0 tw=0 syntax=off noexpandtab columns=80

" yaml files
autocmd BufRead,BufNewFile *.yml,*.yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab

autocmd BufRead,BufNewFile CMakeLists.txt set filetype=cmake
autocmd BufRead,BufNewFile CMakeSettings.txt set filetype=cmake
autocmd BufNewFile,BufRead Jenkinsfile* setf groovy

" prevent conceal characters in latex
let g:tex_conceal = ""

" ---------------------------------
" -- Delete trailing whitespaces --
" ---------------------------------
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

autocmd BufWritePre <buffer> :call DeleteTrailingWS()

" --------------------
" --   Key Macros   --
" --------------------

" Quickly get out of insert mode, press jj
inoremap jj <Esc>

" remap leader key to ,
let mapleader = ","

" Execute macro in q by pressing Q in normal & visual mode
nnoremap Q @q
vnoremap Q @q

" search for visually selected text
vnoremap <c-f> y<ESC>/<c-r>"<CR>

" Tab navigation with Ctrl-Arrow
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

" Merge a tab into a split in the previous window
function! MergeTabs()
  if tabpagenr() == 1
    return
  endif
  let bufferName = bufname("%")
  if tabpagenr("$") == tabpagenr()
    close!
  else
    close!
    tabprev
  endif
  vs
  execute "buffer " . bufferName
endfunction

"Map mergetabs to CtrlW u
nmap <C-W>u :call MergeTabs()<CR>

" Split navigation wth ALT-Arrow
nnoremap <A-Down> <C-W><C-J>
nnoremap <A-Up> <C-W><C-K>
nnoremap <A-Right> <C-W><C-L>
nnoremap <A-Left> <C-W><C-H>

" Folding with space
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

func! FoldIndent()
	set foldmethod=indent
endfunc

" change to directory of current file
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" line movement even in line wrapped state
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

set spelllang=de,en
"Enabeling Spellchecking with Ctrl-S
:map <C-s> :setlocal spell! <cr>

" quickly correct last spell error with first suggested
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <C-l> [s1z=<c-o>

" In visual mode: Copy into selection register with Ctrl-C
vmap <C-c> "+y

" In visual mode: Cut into selection register with Ctrl-X
vmap <C-x> "+d

"In visual mode paste from  with Ctrl-V
vmap <C-v> <ESC> "+p

" Word Completion with Ctrl-Space
if has("gui_running")
    inoremap <C-Space> <C-n>
else " no gui
  if has("unix")
    inoremap <Nul> <C-n>
  endif
endif

" underlining macro
nnoremap <leader>u YpVr

" write to file if not opened with sudo with :w!!
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

nmap <leader>p "0p
nmap <leader>P "0P

"------------------------------------------------------------------------------
"-----------------------------PLUGIN SPECIFIC ---------------------------------
"------------------------------------------------------------------------------

"Nerdtree toggle On Ctrl-N
map <C-n> :NERDTreeToggle<CR>

" Toggle from absolute to relative line numbers with Ctrl-I
nnoremap <silent> <C-i> :set relativenumber!<cr>

" IndentLine :Exclude filetypes to prevent conceal characters
let  g:indentLine_fileTypeExclude = ['json']
