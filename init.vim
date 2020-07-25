syntax on
filetype plugin indent on

set ts=4 sw=4

" Relative numbering
set rnu
" Current line number
set number
" Smart Indenting
set smartindent
" Don't wrap text
set nowrap
" Undo specs
set undodir=~/.config/nvim/undodir
set undofile
" No backup, for speed
set nobackup
" Don't show current mode cuz of vim-lightline
set noshowmode
" New windowsplits appear at the bottom
set splitbelow

" SETTINGS FOR YCM
" Start autocompletion from 3 characters
let g:ycm_min_num_of_chars_for_completion = 3
let g:ycm_min_num_identifier_candidate_chars = 3
let g:ycm_enable_diagnostic_highlighting = 0

" Don't show YCM's preview window
set completeopt-=preview
let g:ycm_add_preview_to_completeopt = 0

" Auto Formatting for Rust
let g:rustfmt_autosave = 1

" RustPlay link
let g:rust_clip_command = 'xclip -selection clipboard'

call plug#begin()
"	Plug 'pangloss/vim-javascript'
"	Plug 'heavenshell/vim-jsdoc
	Plug 'mattn/webapi-vim'
	Plug 'Valloric/YouCompleteMe'
	Plug 'rust-lang/rust.vim'
	Plug 'morhetz/gruvbox'
	Plug 'itchyny/lightline.vim'
	Plug 'junegunn/fzf.vim'
	Plug 'junegunn/fzf'
	Plug 'frazrepo/vim-rainbow'
	Plug 'preservim/nerdcommenter'
	Plug 'airblade/vim-gitgutter'
call plug#end()

" vim-rainbow
let g:rainbow_active = 1
let g:rainbow_ctermfgs = ['lightblue', 'lightgreen', 'yellow']
let g:rainbow_guifgs = ['RoyalBlue3', 'DarkOrange3', 'DarkOrchid3']

" Function for Rust Outline typedefs
function! s:outline_format(lists)
  for list in a:lists
    let linenr = list[2][:len(list[2])-3]
    let line = getline(linenr)
    let idx = stridx(line, list[0])
    let len = len(list[0])
    let fg = synIDattr(synIDtrans(hlID("LineNr")), 'fg', 'cterm')
    let bg = synIDattr(synIDtrans(hlID("LineNr")), 'bg', 'cterm')
    let list[0] = ''
          \ . printf("\x1b[%sm %4d \x1b[m ", '38;5;'.fg.';48;5;'.bg, linenr)
          \ . line[:idx-1]
          \ . printf("\x1b[%sm%s\x1b[m", "34", line[idx:idx+len-1])
          \ . line[idx+len:]
    let list = list[:2]
  endfor
  return a:lists
endfunction
function! s:outline_source(tag_cmds)
  if !filereadable(expand('%'))
    throw 'Save the file first'
  endif
  for cmd in a:tag_cmds
    let lines = split(system(cmd), "\n")
    if !v:shell_error
      break
    endif
  endfor
  if v:shell_error
    throw get(lines, 0, 'Failed to extract tags')
  elseif empty(lines)
    throw 'No tags found'
  endif
  return map(s:outline_format(map(lines, 'split(v:val, "\t")')), 'join(v:val, "\t")')
endfunction
function! s:outline_sink(lines)
  if !empty(a:lines)
    let line = a:lines[0]
    execute split(line, "\t")[2]
  endif
endfunction
function! s:outline(...)
  let args = copy(a:000)
  let tag_cmds = [
    \ printf('ctags -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', &filetype, expand('%:S')),
    \ printf('ctags -f - --sort=no --excmd=number %s 2>/dev/null', expand('%:S'))]
  try
    return fzf#run(fzf#wrap('outline', {
      \ 'source':  s:outline_source(tag_cmds),
      \ 'sink*':   function('s:outline_sink'),
      \ 'options': '--tiebreak=index --reverse +m -d "\t" --with-nth=1 -n 1 --ansi --extended --prompt "Outline> "'}))
  catch
    echohl WarningMsg
    echom v:exception
    echohl None
  endtry
endfunction

" Outline command
command! -bang Outline call s:outline()

colorscheme gruvbox
set background=dark

" Vim Lightline theme
" let g:lightline = { 'colorscheme': 'jellybeans' }

" Disable arrow keys cuz fuck that
map  <up>    <nop>
imap <up>    <nop>
map  <down>  <nop>
imap <down>  <nop>
map  <left>  <nop>
imap <left>  <nop>
map  <right> <nop>
imap <right> <nop>

let mapleader = " "

" Key maps
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q!<cr>
nnoremap <leader>wq :wq<cr>

" Outline map
nnoremap <leader>o :Outline<cr>

" Window switching
nnoremap <leader>h :wincmd h<cr>
nnoremap <leader>j :wincmd j<cr>
nnoremap <leader>k :wincmd k<cr>
nnoremap <leader>l :wincmd l<cr>

" Window Switching with resizing
nnoremap <leader>rh :wincmd h<cr> :vertical resize 125<cr>
nnoremap <leader>rj :wincmd j<cr> :resize 80<cr>
nnoremap <leader>rk :wincmd k<cr> :resize 80<cr>
nnoremap <leader>rl :wincmd l<cr> :vertical resize 125<cr>

" Tabbing
nnoremap tn :tabnew<space>
nnoremap tj :tabnext<cr>
nnoremap tk :tabprev<cr>
nnoremap th :tabfirst<cr>
nnoremap tl :tablast<cr>

" Directory tree
nnoremap <leader>od :wincmd v <bar> :Ex <bar> :vertical resize 30 <cr>

" Bracketing
inoremap <C-x> {<cr><bs>}<esc>ko

" Horizontal panning
nnoremap <leader>a zH
nnoremap <leader>d zL

" Vertical panning
nnoremap <leader>s zz

" Open Terminal
nnoremap <leader>ot :split<cr>:resize 20<bar>:terminal<cr>i

" Multiline comments
inoremap <C-a> /*<cr>/<esc>ka<space>

" Cargo check and run
nnoremap <leader>cc :Ccheck<cr>
nnoremap <leader>cr :Crun<cr>
