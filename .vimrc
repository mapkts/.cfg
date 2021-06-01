"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                        " Enable syntax highlighting
filetype plugin indent on        " Enable filetype plugins
set nocompatible                 " Enter current millenium
set history=500                  " History VIM has to remember
set nobackup                     " Turn backup off
set nowritebackup
set noswapfile
set winaltkeys=no                " Don't use ALT keys for menus.
set backspace=eol,start,indent   " Configure backspace so it acts as it should act
set whichwrap+=<,>,h,l
set autoread                     " Auto read when a file is changed from the outside
set expandtab                    " Use spaces instead of tabs
set smarttab                     " Be smart when using tabs
set shiftwidth=4                 " 1 tab == 4 spaces by default
set tabstop=4
set softtabstop=4
set autoindent                   " Auto indent
set smartindent                  " Smart indent
set nolist                       " Set no listchars by default
set wrap                         " Wrap text
set linebreak                    " Soft wrap
set textwidth=100                " Automatically wrap text as close to 80 characters
set colorcolumn=100
set relativenumber               " Set relative numbers
set number                       " Also show current absolute line
set ruler                        " Always show current position
set scrolloff=3                  " Keep three lines below the cursor
set showmatch                    " Show matching brackets when text indicator is over them
set matchtime=2                  " How many tenths of a second to blink when matching brackets
set lazyredraw                   " Don't redraw while executing macros (good for performance)
set incsearch                    " Search configurations
set nohlsearch
set ignorecase
set smartcase
set path+=**                     " Search down into subfolders, Provides tab-completion
set wildmenu                     " Turn on the WiLd menu(command line auto-completion)
set magic                        " For regular expressions turn magic on
set hidden                       " A buffer becomes hidden when it is abandoned
set ffs=unix,dos,mac             " Use Unix as the standard file type
set laststatus=2                 " Always show statusline
"set autochdir                    " Automatically change current working directory
set completeopt=menu             " Change completeopt
set shortmess+=c                 " Don't give ins-completion-menu messages.
set timeoutlen=300               " http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
set signcolumn=yes               " Always draw sign column. Prevent buffer moving when adding/deleting sign.
set undofile                     " Permanent undo
set undodir=~/.undodir
set foldmethod=manual            " Fold manually
set updatetime=100               " Reducing update time
set termguicolors                " Enable 24-bit RGB true color
set background=dark              " Set background color to dark

if has("nvim") && has("win32")
    " Use windows cmd as default shell.
    set shell=cmd

    " Set up provider paths
    let g:python_host_prog = 'C:\dev\python27\python2.exe'
    let g:python3_host_prog = 'C:\Users\mapkts\AppData\Local\Programs\Python\Python39\python.exe'
    let g:node_host_prog = 'C:\Users\mapkts\AppData\Roaming\npm\node_modules\neovim\bin\cli.js'
elseif has("nvim") && has("unix")
    set shell=/bin/bash

    let g:python_host_prog = '/usr/bin/python2'
    let g:python3_host_prog = '/usr/bin/python3'
    let g:node_host_prog = '/usr/bin/node'
elseif has("win32")
    " Use git bash as default shell.
    set shell=\"C:\Program\ Files\Git\bin\sh.exe\"

    " Change gui cursor style.
    set gcr=a:block-blinkon0,i-ci:ver15
endif

" Share system clipboard.
if has('win32')
    set clipboard+=unnamed
elseif has('unix')
    set clipboard=unnamedplus
endif

" Wrapping options
set formatoptions=tc " wrap text and comments using textwidth
set formatoptions+=r " continue comments when pressing ENTER in I mode
set formatoptions+=q " enable formatting of comments with gq
set formatoptions+=n " detect lists for formatting
set formatoptions+=b " auto-wrap in insert mode, and do not wrap old long lines

" Set different tab size for some files.
autocmd Filetype html,css,xml,javascript,md setlocal ts=2 sts=2 sw=2
autocmd Filetype rust setlocal ts=4 sts=4 sw=4

" Encoding & language
set encoding=utf-8
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
let $LANG='en_US.UTF-8'
set termencoding=utf-8

augroup Wrapping
    autocmd!

    autocmd Filetype txt,markdown
        \ set textwidth=0 |
        \ set colorcolumn="" |
        \ setlocal ffs=dos
augroup END

" Trigger `autoread` when files changes on disk
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
        \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

" Show notification if file changed on disk
autocmd FileChangedShellPost *
  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

" Show those damn hidden caracters
" Verbose: set listchars=nbsp:¬,eol:¶,extends:»,precedes:«,trail:•
set listchars=nbsp:¬,extends:»,precedes:«,trail:•

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move by displayed line
nnoremap <silent> j gj
nnoremap <silent> k gk

" Auto-center when navigate
nnoremap G Gzz
nnoremap n nzz
nnoremap N Nzz
nnoremap } }zz
nnoremap { {zz

" Search results centered please
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz

" Remap mapleader to ,
let mapleader = ","
let g:mapleader = ","
noremap \ ,

" Exit 
inoremap <c-j> <esc>
inoremap jk <esc>

" Jump to start and end of line using the home row keys
map H ^
map L $

" Save
nnoremap <leader>w :w!<cr>
" Delete current buffer
nnoremap <leader>d :bw!<cr>

" Jump out ) } ]
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap } <c-r>=ClosePair('}')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>

function! ClosePair(char)        
    if getline('.')[col('.') - 1] == a:char                
        return "\<Right>"
    else
        return a:char
    endif
endf

" Overload Space
if has('nvim') && has('win32')
    nnoremap <expr> <space> BufNr("cmd.EXE") > 0 ? (&buftype == 'terminal' ? '<c-^>' : ':b '. BufNr("cmd.EXE") . '<cr>') : ':terminal<cr>'
elseif has('win32')
    nnoremap <expr> <space> BufNr("sh.exe") > 0 ? (&buftype == 'terminal' ? '<c-^>' : ':b '. BufNr("sh.exe") . '<cr>') : ':terminal ++curwincr>'
elseif has('unix')
    nnoremap <expr> <space> BufNr("/bin/bash") > 0 ? (&buftype == 'terminal' ? '<c-^>' : ':b '. BufNr("/bin/bash") . '<cr>') : ':terminal<cr>'
endif

" BufNr definition
function! BufNr(pattern)
    let bufcount = bufnr("$")
    let currbufnr = 1
    let nummatches = 0
    let firstmatchingbufnr = 0
    while currbufnr <= bufcount
        if(bufexists(currbufnr))
            let currbufname = bufname(currbufnr)
            if(match(currbufname, a:pattern) > -1)
                let nummatches += 1
                let firstmatchingbufnr = currbufnr
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
    return firstmatchingbufnr
endf

" Goto newer position in jumplist
nnoremap <c-p> <c-i>

" Select all
nnoremap <leader>a ggVG
" Select all and copy
nnoremap <C-a> ggVGy

" Move between windows
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" Create new window with current buffer
nnoremap <leader>s :split<cr><c-w>j
nnoremap <leader>v :vsplit<cr><c-w>l

" Tab related
nnoremap <leader>tn :tabnext<cr>
nnoremap <leader>tp :tabprevious<cr>
nnoremap <leader>to :tabonly<cr>
nnoremap <leader>tc :tabclose<cr>
nnoremap <leader>tm :tabmove

" Jump to last buffer
nnoremap <leader><leader> :bn<cr>
" Jump to next buffer
nnoremap <leader>` :bp<cr>
" Toggle between buffers
nnoremap <leader><leader> <c-^>

" Open a new tab with the current buffer's path
nnoremap <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/
" Open a file within the current buffer's path
nnoremap <leader>e :edit <c-r>=expand("%:p:h")<cr>/

" Open and edit vimrc file
if has('win32')
    "nnoremap <leader>ev :e $MYVIMRC<cr>
    nnoremap <leader>ev :e ~/Dropbox/Dev/.cfg/.vimrc<cr>
    " Expand Ultisnips' snippet folder in command line
    nnoremap <leader>es :e ~\Dropbox\Dev\Vim\vimfiles\ultisnips\
    " Open file explorer under cwd.
    nnoremap <leader>ex :terminal explorer.exe .<cr> \| :bd<cr>
    " Open code base 
    nnoremap <leader>ec :e d:\dev\code\
elseif has('unix')
    nnoremap <leader>ev :e ~/.vimrc<cr>
endif

" Redo last command
nnoremap <leader>; :<up><cr>

" Switch CWD to the directory of the open buffer:
" nnoremap <leader>cd :Cd %:p:h<cr>:pwd<cr>

" Switch between two background colors
nnoremap <Leader>bg :let &background = ( &background == "dark" ? "light" : "dark" )<CR>

" Toggle relativenumber
nnoremap <leader>nb :set relativenumber!<cr>

" Toggle cursorline and cursorcolumn
nnoremap <leader>. :set cursorline! cursorcolumn!<cr>

" Paste yanked text multiple times
nnoremap <leader>p "0p

" Toggle `set list`
nnoremap <leader>sl :set list!<CR>

" Toggle speak checking
nnoremap  <leader>sc :setlocal spell!<cr> 
" Go back to last misspelled word and pick first suggestion.
nnoremap fw i<C-G>u<Esc>[s1z=`]a<C-G>u<Esc>
" Select last misspelled word (typing will edit).
nnoremap gw <Esc>[sve<C-G>
inoremap <leader>gw <Esc>[sve<C-G>
snoremap <leader>gw <Esc>b[sviw<C-G>

" Quickly change word to uppercase in insert mode
inoremap <c-u> <esc>gUiwea

" Moving current line or selected text up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Moving current line or selected text to the beginning/ending of current file
nnoremap <A-J> VxGp==<c-o>
nnoremap <A-K> VxggP==<c-o>
vnoremap <A-J> xGp==<c-o>
vnoremap <A-K> xggP==<c-o>

" Move the letter under cursor left and right
nnoremap <A-h> hxph
nnoremap <A-l> xp
inoremap <A-h> <Esc>xphi
inoremap <A-l> <Esc>lxpi

" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

" Command mode replacements
xnoremap <leader>rb :s/^/
xnoremap <leader>re :s/$/

" Cargo doc
nnoremap <leader>cd :!cargo doc --open<cr>

" Shows stats
nnoremap <leader>st g<c-g>

" Quickly paste system clipboard text
inoremap <c-\> <c-r>*
cnoremap <c-\> <c-r>*

" Operator-pendding mode mappings
onoremap p :execute "normal! /)\rvi("<cr>
onoremap ap :execute "normal! /)\rva("<cr>
onoremap P :execute "normal! ?(\rvi("<cr>
onoremap aP :execute "normal! ?(\rva("<cr>

onoremap o :execute "normal! /}\rvi{"<cr>
onoremap ao :execute "normal! /}\rva{"<cr>
onoremap O :execute "normal! ?{\rvi{"<cr>
onoremap aO :execute "normal! {(\rva{"<cr>

xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
  echo "@".getcmdline()
  execute ":'<,'>normal @".nr2char(getchar())
endfunction

" Toggle quickfix window
" nnoremap <leader>q :call QuickfixToggle()<cr>

" let g:quickfix_is_open = 0
" function! QuickfixToggle()
"     if g:quickfix_is_open
"         cclose
"         let g:quickfix_is_open = 0
"         execute g:quickfix_return_to_window . "wincmd w"
"     else
"         let g:quickfix_return_to_window = winnr()
"         copen
"         let g:quickfix_is_open = 1
"     endif
" endfunction

" Resize buffer (vertical)
nnoremap <leader>rs :vertical resize 

" Set foldmethod to indent
nnoremap <leader>zf :set foldmethod=indent!<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Terminal Mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('win32') || has('unix')
    if has('nvim')
        tnoremap <C-j> <C-\><C-n>
        tnoremap <Esc> <C-\><C-n>
    else
        tnoremap <C-j> <C-w>N
        tnoremap <C-v> <C-r>*
    endif
endif 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
" Essentials
Plug 'sirver/ultisnips'
Plug 'ervandew/supertab'
Plug 'mapkts/enwise'
Plug 'justinmk/vim-sneak'

" Enhancements
Plug 'airblade/vim-rooter'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'godlygeek/tabular'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Language supports
Plug 'rust-lang/rust.vim', { 'for': ['rust'] }
"Plug 'racer-rust/racer', { 'for': ['rust'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'typescript'] }
Plug 'marijnh/tern_for_vim', { 'for': ['javascript', 'typescript'], 'do': 'npm install' }
Plug 'leafgarland/typescript-vim', { 'for': ['javascript', 'typescript'] }
Plug 'mattn/emmet-vim', { 'for': ['css', 'html'] }
Plug 'cespare/vim-toml', { 'for': ['toml'] }
Plug 'stephpy/vim-yaml', { 'for': ['yml'] }
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" GUI enhancements
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme gruvbox

if has("gui_running") || exists("g:neovide")
    " winpos is a vim only thing.
    if !has('nvim')
        winpos 210 80
        set lines=35 columns=120
        " Set extra options when running in GUI mode
        set guioptions-=T
        set guioptions-=m
        set guioptions-=l
        set guioptions-=L
        set guioptions-=r
        set guioptions-=R
        set guioptions-=e
        set guioptions-=T
        set guioptions-=e
        set guitablabel=%M\ %t
    endif

    " Set font and font-size
    " Nerd fonts: https://github.com/ryanoasis/nerd-fonts
    "set guifont=FiraMono_NF  " Medium
    set guifont=SauceCodePro_NF:b " Semi-bold

    "Invisible character colors
    highlight NonText guifg=#4a4a59
    highlight SpecialKey guifg=#4a4a59
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Utilities and AutoCommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
endif
if executable('rg')
    set grepprg=rg\ --no-heading\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

" Remember foldings
augroup remember_folds
    autocmd!
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
augroup END

" Turn line wrapping off when editting an HTML file
augroup nowrap_html
    autocmd!
    autocmd BufNewFile,BufRead *.html setlocal nowrap
augroup END

" Return to last edit position when opening files (super useful)
augroup goto_last_position
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup END

" Follow Rust code style rules
augroup rust_codestyles
    autocmd!
    autocmd Filetype rust set colorcolumn=100
    autocmd BufLeave,BufNewFile *.rs set fileformat=unix
augroup END

" Vimscript file settings
augroup vim_settings
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    " Unmap " auto-pair when editting vimrc
    autocmd BufEnter _vimrc,.vimrc :inoremap " "
    " Open vim help in a vertical split
    autocmd BufEnter *.txt if &buftype == 'help' | wincmd L | endif
    " Source vimrc after writing vimrc file
    autocmd BufWritePost _vimrc,.vimrc source $MYVIMRC
augroup END

" Save session on exit, and load last saved session if vim was entered without any argument.
function! MakeSession(overwrite)
  let b:sessiondir = $HOME . "/.vim/sessions" " . getcwd()
  if (filewritable(b:sessiondir) != 2)
    exe 'silent !mkdir -p ' b:sessiondir
    redraw!
  endif
  let b:filename = b:sessiondir . '/session.vim'
  if a:overwrite == 0 && !empty(glob(b:filename))
    return
  endif
  exe "mksession! " . b:filename
endfunction

function! LoadSession()
  let b:sessiondir = $HOME . "/.vim/sessions" " . getcwd()
  let b:sessionfile = b:sessiondir . "/session.vim"
  if (filereadable(b:sessionfile))
    exe 'source ' b:sessionfile
  else
    echo "No session loaded."
  endif
endfunction

" Adding automatons for when entering or leaving Vim
if(argc() == 0)
  au VimEnter * nested :call LoadSession()
  au VimLeave * :call MakeSession(1)
else
  au VimLeave * :call MakeSession(0)
endif

if has("nvim")
    augroup terminal_settings
        autocmd!

        "autocmd BufWinEnter,WinEnter term://* startinsert
        "autocmd BufLeave term://* stopinsert
        autocmd VimLeavePre * :call WipeoutTerminal()

        " Ignore various filetypes as those will close terminal automatically
        " Ignore fzf, ranger, coc
        autocmd TermClose term://*
                    \ if (expand('<afile>') !~ "fzf")
                    \ && (expand('<afile>') !~ "coc") |
                    \   call nvim_input('<CR>')  |
                    \ endif
    augroup END
endif

function! WipeoutTerminal()
  " Wipes out terminal buffer before making session.
  if has('nvim') && has('win32')
      let b:termbufnr = BufNr("cmd.EXE")
  elseif has('win32')
      let b:termbufnr = BufNr("sh.exe")
  else
      let b:termbufnr = 0
  endif
  if b:termbufnr > 0
      exe 'bwipeout! ' . b:termbufnr 
  endif
endfunction


" Sort alphabetically
command! -nargs=0 -range SortAlphabet :'<,'>!LC_ALL=C sort

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin settings and key-bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" => Vim-rooter
""""""""""""""""""""""""""""""
let g:rooter_patterns = ['.git', 'Cargo.toml']
let g:rooter_silent_chdir = 1
let g:rooter_change_directory_for_non_project_files = 'current'

""""""""""""""""""""""""""""""
" => Airline
""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#tab_nr_formatter = '2'
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#show_tab_nr = 1

nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>0 <Plug>AirlineSelectTab0

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

if has("gui_running") || exists("g:neovide")
    let g:airline_symbols.space = "\ua0"
endif

" powerline-extra-symbols: https://github.com/ryanoasis/powerline-extra-symbols
let g:airline_left_sep = "\uE0C0"
let g:airline_right_sep = "\uE0C7"

" set the CN (column number) symbol:
" let g:airline_section_z = airline#section#create(["\uE0A1" . '%{line(".")}' . "\uE0A3" . '%{col(".")}'])

if !has("gui_running") && !exists("g:neovide")
    let g:airline#extensions#tabline#left_sep = ''
    let g:airline#extensions#tabline#left_alt_sep = '|'
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_symbols.crypt = '🔒'
    let g:airline_symbols.linenr = '☰'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.maxlinenr = ''
    let g:airline_symbols.maxlinenr = '㏑'
    let g:airline_symbols.branch = ''
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.spell = 'Ꞩ'
    let g:airline_symbols.notexists = ''
    let g:airline_symbols.whitespace = 'Ξ'
endif

""""""""""""""""""""""""""""""
" => Supertab
""""""""""""""""""""""""""""""
let g:SuperTabDefaultCompletionType = "<c-x><c-o>"

""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH

""""""""""""""""""""""""""""""
" => Coc
""""""""""""""""""""""""""""""
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
"inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
    else
        call CocAction('doHover')
    endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>q  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" /search + gn text object can mimic multi-cursor behavior.

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
"nmap <silent> <C-s> <Plug>(coc-range-select)
"xmap <silent> <C-s> <Plug>(coc-range-select)
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
"nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
"" Manage extensions.
"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
"" Show commands.
"nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
"" Find symbol of current document.
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
"" Search workspace symbols.
"nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
"" Do default action for next item.
"nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
"" Do default action for previous item.
"nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
"" Resume latest coc list.
"nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

""""""""""""""""""""""""""""""
" => Racer
""""""""""""""""""""""""""""""
let g:racer_cmd = "~/.cargo/bin/racer"

""""""""""""""""""""""""""""""
" => Git gutter
""""""""""""""""""""""""""""""
nnoremap <silent> <leader>gd :GitGutterToggle<cr>

""""""""""""""""""""""""""""""
" => Emmet
""""""""""""""""""""""""""""""
" Enable just for html/css
let g:user_emmet_install_global = 0

augroup emmet_install
    autocmd!
    autocmd FileType html,css EmmetInstall
augroup END

" Remap the default <C-Y> leader
let g:user_emmet_leader_key= "<leader>"

""""""""""""""""""""""""""""""
" => Rust-vim
""""""""""""""""""""""""""""""
let g:rustfmt_autosave = 0
let g:rustfmt_command = 'rustfmt +nightly'
let g:rustfmt_options = '--unstable-features'

augroup merge_imports
    autocmd!
    autocmd FileType rust nnoremap <leader>w :call FormatWrite()<cr>
    autocmd FileType rust command! -nargs=0 MergeImports :call MergeImports()
augroup END

function! FormatWrite()
    if &filetype ==# 'rust'
        execute ':RustFmt'
    endif
    execute ':w!'
endfunction

function! MergeImports()
    let g:rustfmt_options = '--unstable-features --config merge_imports=true'
    execute ':RustFmt'
    let g:rustfmt_options = '--unstable-features'
endfunction

""""""""""""""""""""""""""""""
" => UltiSnips
""""""""""""""""""""""""""""""
let g:UltiSnipsSnippetDirectories = [$HOME.'/Dropbox/Dev/Vim/vimfiles/ultisnips']

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

""""""""""""""""""""""""""""""
" => Tagbar
""""""""""""""""""""""""""""""
nmap <leader>tb :TagbarToggle<CR>
let g:tagbar_autofocus = 0

""""""""""""""""""""""""""""""
" => Vim-javascript
""""""""""""""""""""""""""""""
let g:javascript_plugin_jsdoc = 1

""""""""""""""""""""""""""""""
" => Tabular
""""""""""""""""""""""""""""""
nmap <Leader>t= :Tabularize /=<CR>
vmap <Leader>t= :Tabularize /=<CR>
nmap <Leader>t: :Tabularize /:\zs<CR>
vmap <Leader>t: :Tabularize /:\zs<CR>

" call the :Tabularize command each time you insert a | character.
inoremap <silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
function! s:align()
    let p = '^\s*|\s.*\s|\s*$'
    if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
        let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
        let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
        Tabularize/|/l1
        normal! 0
        call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
    endif
endfunction

""""""""""""""""""""""""""""""
" => Vim-Markdown
""""""""""""""""""""""""""""""
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0
let g:vim_markdown_frontmatter = 1

""""""""""""""""""""""""""""""
" => LeaderF
""""""""""""""""""""""""""""""
" don't show the help in normal mode
let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
" let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2"}
let g:Lf_PreviewResult = {'Function': 0, 'BufTag': 0 }
let g:Lf_GtagsAutoUpdate = 0

" Do not show icons in console.
if !has("gui_running")
    let g:Lf_ShowDevIcons = 0
endif

let g:Lf_ShortcutF = "<leader>f"
" noremap <leader>g :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap <C-B> :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
noremap <leader>g :<C-U><C-R>=printf("Leaderf! rg -e %s ", "")<CR>
" search visually selected text literally
"xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F -e %s ", leaderf#Rg#visual())<CR>

""""""""""""""""""""""""""""""
" => Vim-Sneak
""""""""""""""""""""""""""""""
let g:sneak#label = 1

""""""""""""""""""""""""""""""
" => Vim-Enwise
""""""""""""""""""""""""""""""
let g:enwise_enable_globally = 1
let g:enwise_close_multiline = 1

""""""""""""""""""""""""""""""
" => Go
""""""""""""""""""""""""""""""
" vim-go
" let g:go_def_mode='gopls'
" let g:go_info_mode='gopls'

" autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')


""""""""""""""""""""""""""""""
" => Neovide (Nvim GUI)
""""""""""""""""""""""""""""""
let g:neovide_transparency=1.0

" Animations
let g:neovide_cursor_animation_length=0.06
let g:neovide_cursor_trail_length=0.8

" Particles
let g:neovide_cursor_vfx_mode = ""      " pixiedust / torpedo / railgun
let g:neovide_cursor_vfx_opacity=200.0         " default: 200.0
let g:neovide_cursor_vfx_particle_lifetime=1.2 " default: 1.2
let g:neovide_cursor_vfx_particle_density=7.0  " default: 7.0
let g:neovide_cursor_vfx_particle_speed=10.0   " default: 10.0


" key mappings
nnoremap <F11> :let g:neovide_fullscreen = ( neovide_fullscreen == v:false ? v:true : v:false )<CR><CR>

""""""""""""""""""""""""""""""
" => netrw 
""""""""""""""""""""""""""""""
let g:netrw_fastbrowse = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Abbreviations and auto-corrections
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Common typos
iab waht what
iab taht that
iab lenght length
iab retrun return
iab chidren children
iab widht width

" JavaScript
iab fuction function
iab funciton function
iab fucntion function

" Rust
iab uszie usize
iab iszie isize
iab sturct struct
iab pritln println
