" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

set backspace=indent,eol,start   " Allow backspacing over everything in insert mode          

set history=1000                 " Store lots of :cmdline history

set title                        " Set the terminal's title
set number                       " Turn on line numbering 

set tags=./tags;                 " Set the tag file search order

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
" remove trainling whitespace
autocmd BufWritePre * :%s/\s\+$//e

" Quick, jump out of insert mode while no one is looking
imap ii <Esc>

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"indent settings
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab
set autoindent
set smarttab

"folding settings
set foldmethod=indent       "fold based on indent
set foldnestmax=3           "deepest fold is 3 levels
set nofoldenable            "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing

set formatoptions-=o "dont continue comments when pushing o/O

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"load ftplugins and indent files
filetype plugin on
filetype indent on

syntax on                    "turn on syntax highlighting

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

set t_Co=256                 "tell the term has 256 colors

set hidden                   "hide buffers when not displayed

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal g`\""
        endif
    end
endfunction

"define :HighlightExcessColumns command to highlight the offending parts of
"lines that are "too long". where "too long" is defined by &textwidth or an
"arg passed to the command
command! -nargs=? HighlightExcessColumns call s:HighlightExcessColumns('<args>')
function! s:HighlightExcessColumns(width)
    let targetWidth = a:width != '' ? a:width : &textwidth
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth+1) . 'v/'
    else
        echomsg "HighlightExcessColumns: set a &textwidth, or pass one in"
    endif
endfunction

" theme
set background=dark
if has("gui_running")
  colorscheme ir_black
  set columns=101 lines=60
  set transparency=8
endif

set guifont=Inconsolata:h18
set guioptions=egmrLt

" store backups in .vim-tmp
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" scroll the viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" ack
set grepprg=ack
set grepformat=%f:%l:%m

" Highlight search terms...
set hlsearch
set incsearch " ...dynamically as they are typed.

let mapleader = ','

" Shortcut to rapidly toggle `set list`
nmap <leader>l :set list!<CR>                
set list                                    " Show tabs, trailing spaces, eol
set listchars=tab:▸\ ,trail:⋅,nbsp:⋅,eol:¬  " Change the symbols for tabs, etc

map <leader>f :FuzzyFinderTextMate<CR>
map <leader>, :NERDTreeToggle<CR>

" Vim will show the ^M line-endings. A quick search and replace works wonders
map <leader>m mz:%s/\r$//g<cr>`z

map <leader>ew :e <C-R>=expand("%:p:h") . '/' <CR>
map <leader>es :sp <C-R>=expand("%:p:h") . '/' <CR>
map <leader>ev :vsp <C-R>=expand("%:p:h") . '/' <CR>
map <leader>et :tabe <C-R>=expand("%:p:h") . '/' <CR>

" Autotest support
compiler rubyunit
nmap <Leader>at :cf /tmp/autotest.txt<CR> :compiler rubyunit<CR>

" Tab mappings.
map <leader>tt :tabnew<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>
map <leader>tf :tabfirst<cr>
map <leader>tl :tablast<cr>
map <leader>tm :tabmove

" Simplify window navigation
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

set laststatus=2                                     " Always hide the statusline

set statusline=Line:\ \ %l/%L:%c\ \ \ %F%m%r%h\ %w  " Format the statusline

let g:bufExplorerShowRelativePath=1                 " Show relative paths for BufExplorer
