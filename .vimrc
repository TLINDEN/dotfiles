" Main vimrc for programming
" Thomas Linden <tom@daemon.de> 
" 
" Turn syntax-highlighting on, if supported
set t_Co=256

"if &t_Co > 1
" syntax off
"endif

syntax on

" allow backspacing over everything in insert mode
set bs=2

" indent automatically after new blocks
" (if, while, for and so on...)
set nosmartindent
set noautoindent

autocmd FileType perl   set smartindent
autocmd FileType python set smartindent
autocmd FileType shell  set smartindent
autocmd FileType c      set smartindent

" paste mode - this will avoid unexpected effects when you
" cut or copy some text from one window and paste it in Vim.
set pastetoggle=<F11>

" sometimes smartindent is worsty, make it possible
" to turn it off / on
" these are for normal mode
"nm aus :set nosmartindent
"nm ein :set smartindent
" and these for command mode (after the : )
"cm aus set nosmartindent
"cm ein set smartindent


" indent shifts 2 spaces to right
set expandtab
set shiftwidth=2
set softtabstop=2

" search is case insensitive
set ignorecase

" highlight matches
set hlsearch

" not case insensitive if term contains upper letters
set smartcase

" show cursor position in statusline
set ruler

" show matching bracket after typing a closing bracket
set showmatch

" show current mode in statusline
set showmode

" show last command in statusline
set showcmd

" show status line
set laststatus=2

" set xterm title to "VIM <file>", while <file> is
" the currently opened buffer
set title

" do not beep (doh!)
set visualbell

" don't ask for :x!
set writeany

" just enter Q to exit
map Q :q!<Cr>

" 990503: I have to set the "term" explicitly
" because the standard setups are broken.
" set   term=builtin_pcansi
set term=xterm

" using dark terminals always
set background=dark

" color scheme astronaut
" http://vimcolorschemetest.googlecode.com/svn/colors/astronaut.vim
color astronaut

" dont bother
set noswapfile

" emacs emulation:
" CTRL-UP    scrolls one paragraph up
" CTRL-DOWN  scrolls one paragraph down
" CTRL-RIGHT scrolls one word right
" CTRL-LEFT  scrolls one word left
" Enter unrecognized controll keys with
" inoremap <press ctrl-v><press control key>

" C-Down: leave insert mode, press }, enter insert mode
inoremap <C-Down> <Esc>}i
" C-Up:   leave insert mode, press {, enter insert mode}
inoremap <C-Up> <Esc>{i
" same as above for normal mode
nnoremap <C-Down> }
nnoremap <C-Up> {
" C-Right: leave insert mode, press w(jump one word right), enter insert mode)
"          in this case we send 2x the 'w' command, otherwise it doesnt move
inoremap Oc <Esc>wwi
" C-Left:  leave insert mode, press b(jump one word left), enter insert mode)
inoremap Od <Esc>bi
" same as above for normal mode
nnoremap Oc w
nnoremap Od b

" CTRL-ENTF: leave insert mode, press 'b' (one word back), press 'dw' (delete word), enter insert mode
inoremap  <Esc>bdwi

" allow to leave a buffer while it is modified
set hidden

" CTRL-X opens a bufferlist on the left
" uses plugin http://www.vim.org/scripts/script.php?script_id=1325
map <silent>  :call BufferList()<CR>

" split helpers
" ALT-S    split horizontal
" ALT-V    split vertical
" ALT-2    split horizontal
" ALT-3    split vertical
" ALT-1    no splits anymore
" ALT-+    increase height
" ALT--    decrease height
" ALT-*    increase height  (ALT-SHIFT-+)
" ALT-_    decrease height  (ALT-SHIFT--)
noremap <silent> s :split<CR>
noremap <silent> v :vsplit<CR>
noremap <silent> + :resize +1<CR>
noremap <silent> - :resize -1<CR>
noremap <silent> * <C-w>><CR>
noremap <silent> _ <C-w><<CR>
noremap <silent> o <C-w><C-w>
noremap <silent> 1 :only<CR>
noremap <silent> 2 :split<CR>
noremap <silent> 3 :vsplit<CR>

" *scratch* buffer
" will only opened if started without a file, otherwise
" start it manually
" uses plugin http://www.vim.org/scripts/script.php?script_id=664
let curbuf = bufname("%")
if curbuf == ''
  autocmd VimEnter * Scratch
endif

" abbreviations
" same as I use in emacs
autocmd FileType perl  iab if       if( ) {<CR>}<Up><Up>
autocmd FileType perl  iab elsif    elsif( ) {<CR>}<Up><Up>
autocmd FileType perl  iab else     else {<CR>}<Up>
autocmd FileType perl  iab foreach  foreach( ) {<CR>}<Up><Up>
autocmd FileType perl  iab while    while( ) {<CR>}<Up><Up>

" just to memoize:
" CTRL-P same as CTRL-TAB = inner complete based on words of current file
" CTRL-P finds previous match, CTRL-N next. CTRL-N might be enough

" emulate emacs' behavior of indenting something by using <tab> anywhere on a line
autocmd FileType perl   inoremap <Tab> <Esc>=^i
autocmd FileType shell  inoremap <Tab> <Esc>=^i

" same as CTRL-K: remove current line, aka D in vim but from anywhere within a line
autocmd FileType perl   inoremap  <Esc>cc<Tab>
autocmd FileType shell  inoremap  <Esc>cc<Tab>
autocmd FileType python inoremap  <Esc>cc
autocmd FileType perl   nnoremap  <Esc>cc<Tab>
autocmd FileType shell  nnoremap  <Esc>cc<Tab>
autocmd FileType python nnoremap  <Esc>cc

" same as META-x indent-regiion, but with complete buffer
" must start with uppercase letter, for what ever *cking reason...
"
" Note: enter visual mode with 'V', move cursor to mark lines, enter '=' to re-indent them,
"       which would be the same as intent-region. 'y' can be used to copy, and other commands
"       can be applied from there too.
command! IndentBuffer exe "normal! gg=G"

" CTRL-L moves window so that the current line ends up in the middle of the screen
" for insert mode only, so in normal mode still does repaint the screen
inoremap  <Esc>zzi

" so that's something special. it defines a variable which will be used
" later for status output. that variable will be put into the statusline
" and it remains there until the user moves the cursor or leaves input
" mode.
" therefore I define my own statusline here.
let g:msg = ''
autocmd CursorMovedI * let g:msg = ''
autocmd InsertLeave  * let g:msg = ''
set statusline=%F%m%r%h%w\ %y\ Buffer:\ %n\ %{msg}%=(Line:\ %5l\ Column:\ %3c\ (%3p%%)


" File commands mimicing emacs, a nightmare for vim enthusiasts but cool for me
" CTRL-f opens a new file in a new buffer (aka CTRL-X-F, which doesn't work)
" CTRL-w saves current buffer (aka CTRL-X-S, which doesn't work as well)
" CTRL-ww saves current buffer and exits vim (aka CTRL-X-S, which doesn't work as well)
inoremap  <Esc>:e<Space>
nnoremap  <Esc>:e<Space>
inoremap <silent>  <Esc>:w!<Cr>:let g:msg='file saved'<Cr>i

" other variant, using ',' as the command key instead of : (which requires me to enter shift-q)
" ,w   - write and continue
let mapleader = ','
nnoremap <Leader>w <Esc>:w!<Cr>i

" toggle cursorline and cursorcolumn
nnoremap <silent> <Leader>cc :set cursorline<Cr>:set cursorcolumn<Cr>
nnoremap <silent> <Leader>cn :set nocursorline<Cr>:set nocursorcolumn<Cr>
" Highlight cursorline ein- ausschalten mit F3
" map <F3> :set cursorline!<CR><Bar>:echo 'Highlight active cursor line: ' . strpart('OffOn', 3 * &cursorline, 3)<CR>

" CTRL-G  aka abort, here for: remove highlighting from previous searhes
noremap  :silent nohl<cr>i



