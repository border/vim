"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ModifiedBy:   Bian Jiang - http://www.wifihack.net
" Email: borderj-AT-gmail-com
" Version: 1.9
" Last Change: 2012-07-20
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Start vim by using: vim -u /path/to/portable/vim/.vimrc
"" set default 'runtimepath' (without ~/.vim folders)
"let &runtimepath = printf('%s/vimfiles,%s,%s/vimfiles/after', $VIM, $VIMRUNTIME, $VIM)
"
"" what is the name of the directory containing this file?
"let s:portable = expand('<sfile>:p:h')
"
"" add the directory to 'runtimepath'
"let &runtimepath = printf('%s,%s,%s/after', s:portable, &runtimepath, s:portable)


"Sets how many lines of history VIM har to remember
set history=500
set modeline

"Enable filetype plugin
filetype plugin on
filetype indent on
set completeopt=longest,menu

"set list                       " 显示制表符
"set listchars = tab:>-,trail:- " 将制表符显示为'>---',将行尾空格显示为'-'
set listchars=tab:.\ ,trail:.   " 将制表符显示为'.   '

set autochdir                   " 自动设置目录为正在编辑的文件所在的目录

"Set to auto read when a file is changed from the outside
set autoread

"Have the mouse enabled all the time:
set mouse=a

"Set mapleader
let mapleader = ","
let g:mapleader = ","
"Fast saving
nmap <leader>w :w!<cr>
"Fast Quit
map <leader>q :q<cr>
"Undolist 
map <leader>u :undolist<cr>
"Open Files Dir
map <leader>f :Ex<cr>
"Remap VIM 0
map 0 ^
"Switch to current dir
map <leader>cd :cd %:p:h<cr>
inoremap ;; <Esc>
nmap :X :x
nmap :W :w
nmap :Q :q
nmap :qa :quitall
nmap :QA :quitall

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Enable syntax
syntax enable

set guifont=DejaVu\ Sans\ Mono\ 9

if has("gui_running")
    set guioptions-=T
    set t_Co=256
    set background=dark
    colorscheme desert
else
    colorscheme zellner
    set background=dark
endif

"Highlight current
if has("gui_running")
    set cursorline
    hi cursorline guibg=#333333 
    hi CursorColumn guibg=#333333
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around and tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set winaltkeys=no
inoremap <A-h> <LEFT>a
inoremap <A-l> <RIGHT>a
inoremap <A-j> <DOWN>a
inoremap <A-k> <UP>a
map <C-A> ggVG
"Bash like
inoremap <C-a> <Home>
inoremap <A-a> <Home>
inoremap <C-e> <End>
inoremap <C-k> <Esc>wd$i
inoremap <C-d> <del>
inoremap <A-o> <Esc>o

"Tab configuration
map <leader>tn :tabnext<cr>
map <leader>te :tabedit 
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove<cr>
try
    set switchbuf=usetab
    set stal=2
catch
endtry

"Favorite filetypes
set ffs=unix,dos,mac
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM userinterface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Turn on WiLd menu
set wildmenu

"Always show current position
set ruler

"The commandbar is 2 high
set cmdheight=2

"Show line number
set nu

"Ignore case when searching
set ignorecase
set incsearch

"Set magic on
set magic

"No sound on errors.
set noerrorbells
set novisualbell
set vb t_vb=

"show matching bracets
set showmatch
set showfulltag

"How many tenths of a second to blink
set mat=2

"Highlight search things
set hlsearch

""""""""""""""""""""""""""""""
" => Statusline
""""""""""""""""""""""""""""""
"Always hide the statusline
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\ " buffer number
set statusline+=%F\ " file name
set statusline+=%h%1*%m%r%w%0* " flag
set statusline+=[
if v:version >= 600
    set statusline+=%{strlen(&ft)?&ft:'none'}, " filetype
    "set statusline+=%{&encoding}, " encoding
    set statusline+=%{(&fenc==\"\")?&enc:&fenc}%{(&bomb?\",BOM\":\"\")},
endif
set statusline+=%{&fileformat}] " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()} " vim buddy
endif
set statusline+=%= " right align
"set statusline+=%2*0x%-8B\ " current char
set statusline+=0x%-8B\ " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P " offset
set ruler           " 在编辑过程中，在右下角显示光标位置的状态行
set showcmd

set cmdheight=1   " 设定命令行的行数为 1
set laststatus=2  " 显示状态栏 (默认值为 1, 无法显示状态栏)


"---------------------------------------------------------------------------
" 括号自动补全
" http://www.linuxgem.org/tip/bracket-auto-closing-in-vim.html
"---------------------------------------------------------------------------
:inoremap ( ()<ESC>i
:inoremap ) <c-r>=ClosePair(')')<CR>
:inoremap { {}<ESC>i
:inoremap } <c-r>=ClosePair('}')<CR>
:inoremap [ []<ESC>i
:inoremap ] <c-r>=ClosePair(']')<CR>
":inoremap < <><ESC>i
":inoremap > <c-r>=ClosePair('>')<CR>

function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf

"Turn backup off
set nobackup
set nowb
set noswapfile

"Enable folding, I find it very useful
set nofen
set fdl=0

" => Text options
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set shiftwidth=4
set tabstop=4

set smarttab
set lbr
set tw=800

""""""""""""""""""""""""""""""
" => Indent
""""""""""""""""""""""""""""""
"Auto indent
set ai

"Smart indet
set si

"C-style indeting
set cindent

"Wrap lines
set wrap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""
" => QuickFix
""""""""""""""""""""""""""""""
nmap <F6> :cn<cr>
nmap <F7> :cp<cr>


""""""""""""""""""""""""""""""
" => Tlist
""""""""""""""""""""""""""""""
map <leader>t :Tlist<cr>
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

""""""""""""""""""""""""""""""
" => cscope
""""""""""""""""""""""""""""""
set cscopequickfix=s-,c-,d-,i-,t-,e-
nmap <C-_>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-_>d :cs find d <C-R>=expand("<cword>")<CR><CR>

if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
        " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb
endif

""""""""""""""""""""""""""""""
" => miniBufferExp
""""""""""""""""""""""""""""""
let g:miniBufExplMapCTabSwitchBufs = 1
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1

""""""""""""""""""""""""""""""
" => c/h 文件相互切换<F12> － A
""""""""""""""""""""""""""""""
nnoremap <silent> <F12> :A<CR>

""""""""""""""""""""""""""""""
" => 在工程中查找<F3> -- 插件: Grep
""""""""""""""""""""""""""""""
nnoremap <silent> <F3> :Grep<CR>

""""""""""""""""""""""""""""""
" => VIM
""""""""""""""""""""""""""""""
autocmd FileType vim map <buffer> <leader><space> :w!<cr>:source %<cr>

""""""""""""""""""""""""""""""
" => Golang section
""""""""""""""""""""""""""""""
autocmd BufRead,BufNewFile *.go set filetype=go

""""""""""""""""""""""""""""""
" => SVN section
"""""""""""""""""""""""""""""""
map <F8> :new<CR>:read !svn diff<CR>:set syntax=diff buftype=nofile<CR>gg

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Set FileEncodeing
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set fileencodings=utf-8,cp936,big5,latin1
an 20.4109 &Edit.-SEP6- <Nop>
an 20.4109.10 &Edit.Encoding.&GBK :set encoding=utf-8<CR>
an 20.4109.11 &Edit.Encoding.&Big5 :set encoding=big5<CR>
an 20.4109.12 &Edit.Encoding.&UTF-8 :set encoding=utf-8<CR>
an 20.4119.10 &Edit.Fileencodings.&GBK :set fileencodings=gbk<CR>
an 20.4119.11 &Edit.Fileencodings.&Big5 :set fileencodings=big5<CR>
an 20.4119.12 &Edit.Fileencodings.&UTF-8 :set fileencodings=utf-8<CR>
an 20.4139 &Edit.gb  convert.gb->big5 :%!autogb -i gb -o big5<CR>
an 20.4139 &Edit.gb  convert.gb->utf8 :%!autogb -i gb -o utf8<CR>
an 20.4149 &Edit.big5  convert.big5->gb :%!autogb -i big5 -o gb<CR>
an 20.4149 &Edit.big5  convert.big5->utf8 :%!autogb -i big5 -o utf8<CR>
an 20.4159 &Edit.utf8  convert.utf8->gb :%!autogb -i utf8 -o gb<CR>
an 20.4159 &Edit.utf8  convert.utf8->big5 :%!autogb -i utf8 -o big5<CR>

if has("multi_byte")
    " Set fileencoding priority
    if getfsize(expand("%")) > 0
        set fileencodings=ucs-bom,utf-8,cp936,big5,euc-jp,euc-kr,latin1
    else
        set fileencodings=cp936,big5,euc-jp,euc-kr,latin1
    endif

    " CJK environment detection and corresponding setting
    if v:lang =~ "^zh_CN"
        " Use cp936 to support GBK, euc-cn == gb2312
        set encoding=gb2312
        set termencoding=utf-8
        set fileencoding=utf-8
    elseif v:lang =~ "^zh_TW"
        " cp950, big5 or euc-tw
        " Are they equal to each other?
        set encoding=big5
        set termencoding=big5
        set fileencoding=big5
    elseif v:lang =~ "^ko"
        " Copied from someone's dotfile, untested
        set encoding=euc-kr
        set termencoding=euc-kr
        set fileencoding=euc-kr
    elseif v:lang =~ "^ja_JP"
        " Copied from someone's dotfile, unteste
        set encoding=euc-jp
        set termencoding=euc-jp
        set fileencoding=euc-jp
    endif
    " Detect UTF-8 locale, and replace CJK setting if needed
    if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
        set encoding=utf-8
        set termencoding=utf-8
        set fileencoding=utf-8
    endif
else
    echoerr "Sorry, this version of (g)vim was not compiled with multi_byte"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Projects
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set tags+=.,./tags;/

