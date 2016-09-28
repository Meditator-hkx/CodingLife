"Ctrl+p : complete the word
"Ctrl+] : find the definition of an element, such as variable, function
"Ctrl+t : return
"
"in minibuf you can use Tab to switch window
"
"Find something among multiple files, :Rgrep strings which are found
"
"avoid bugs from older version of vi
set nocompatible

"display the number of lines
set nu

"detect file type
filetype on
filetype plugin indent on
set completeopt=longest,menu

"indent format
set tabstop=2
set shiftwidth=2

"save all opened files
"inoremap <F3> <Esc>:wall<CR>a
nnoremap <F3> :wall<CR>
nmap <F6> <Esc>:quitall<CR>
nmap <F5> :close<CR>
nmap <F4> :shell<CR>

"set shortcut keys for splitted window switching
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l

map <F7> :call MakeFile()<CR>
func! MakeFile()
    exec ":wall"
    exec ":make"
endfunc

"-------------------------Taglist Plugin-----------------
"configure Taglist
"only display tags of the current file
let Tlist_Show_One_File = 1
"items in tags are sorted by name
let Tlist_Sort_Type = "name"

"make tag
map <F12> :call MakeTag()<CR><CR>
func! MakeTag()
		exec ":wall"
		exec "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q"
		exec "!cscope -Rbq"
		cs add cscope.out
endfunc


"-------------------------WinManager Plugin-----------------
"configure WinManager plugin
let g:winManagerWindowLayout='FileExplorer|TagList'
let g:winManagerWidth = 36
nmap <F8> :WMToggle<CR>


"-------------------------A Plugin-----------------
"can swift from cpp to h or from h to cpp
map <F9> :A<CR>


"move to top window
"map <F5> <C-w>t

"set the size of a window to 8 lines
"map <F2>8 8<C-w>_
map <F2>8 16<C-w>_

"maximum the size of a window
map <F2>m <C-w>_

"you can change tags to your source code
if filereadable("tags")
    set tags=tags,/usr/lib/erlang/lib/kernel-2.13.2/src/tags
elseif filereadable("../tags")
    set tags=../tags,/usr/lib/erlang/lib/kernel-2.13.2/src/tags
else
    "echo "no tags"
endif

"指定pathogen目录
runtime bundle/vim-pathogen/autoload/pathogen.vim
""运行pathogen
execute pathogen#infect()

"powerline
"set guifont=PowerlineSymbols\ for\ Powerline

:set laststatus=2
:set statusline=%<%f%h%m%r%=%b\ 0x%B\ \ %l,%c%V\ %P

let mapleader=";"

syntax enable   "开启语法高亮功能
syntax on   "允许用指定语法高亮配色方案替换默认方案 

" 自适应不同语言的智能缩进
filetype indent on

set incsearch   "开启实时搜索
set ignorecase  "大小写不敏感

"******************Vundle************************
"
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
call vundle#end()
filetype plugin indent on
"*****************YCM****************************
"
let g:ycm_global_ycm_extra_conf = '/home/peng/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'
let g:ycm_seed_identifiers_with_syntax=1    " 语法关键字补全
let g:ycm_confirm_extra_conf=0   " 打开vim时不再询问是否加载ycm_extra_conf.py配置
inoremap <expr> <CR>  pumvisible() ? "\<C-y>" : "\<CR>"    "回车即选中当前项
set completeopt=longest,menu    "让Vim的补全菜单行为与一般IDE一致(参考VimTip1228) '

"config2
"
"设置error和warning的提示符，如果没有设置，ycm会以syntastic的
"" g:syntastic_warning_symbol 和 g:syntastic_error_symbol 这两个为准
let g:ycm_error_symbol='>>'
let g:ycm_warning_symbol='>*'

"设置跳转的快捷键，可以跳转到definition和declaration
nnoremap <leader>gc :YcmCompleter GoToDeclaration<CR>
nnoremap <leader>ff :YcmCompleter GoTo<CR>
nnoremap <leader>gg :YcmCompleter GoToImprecise<CR>
"nnoremap <leader>gg :YcmCompleter GoToDefinitionElseDeclaration<CR>
"
"设置全局配置文件的路径
""开启基于tag的补全，可以在这之后添加需要的标签路径
let g:ycm_collect_identifiers_from_tags_files = 1 
""在接受补全后不分裂出一个窗口显示接受的项
set completeopt-=preview
"每次重新生成匹配项，禁止缓存匹配项
let g:ycm_cache_omnifunc=0
""在注释中也可以补全
let g:ycm_complete_in_comments=1
"输入第一个字符就开始补全
let g:ycm_min_num_of_chars_for_completion=1
""不查询ultisnips提供的代码模板补全，如果需要，设置成1即可
"let g:ycm_use_ultisnips_completer=0
"inoremap <F6> <Esc>:YcmForceCompileAndDiagnostics<CR>
"nnoremap <F6> :YcmForceCompileAndDiagnostics<CR>
"nmap <F6> :YcmDiags<CR>

set cursorline
"colorscheme evening
highlight SpellBad ctermbg=8
highlight Search ctermbg=1

if !empty(glob("~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"))
    let g:ycm_global_ycm_extra_conf = "~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"
endif

if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"add author information
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>a ms:call AddAuthor()<cr>'s
function AddAuthor()
    let n = 1
    while n < 5
	let line = getline(n)
	if line =~'^\s*\*\s*\S*Last\s*modified\s*:\s*\S*.*$'
	    call UpdateTitle()
	    return
	endif
	let n = n + 1
    endwhile
    call AddTitle()
endfunction
function UpdateTitle()
        normal m'
        execute '/* Last modified\s*:/s@:.*$@\=strftime(": %Y-%m-%d %H:%M")@'
        normal "
        normal mk
        execute '/* Filename\s*:/s@:.*$@\=": ".expand("%:t")@'
        execute "noh"
        normal 'k
        echohl WarningMsg | echo "Successful in updating the copy right." | echohl None
endfunction
function AddTitle()
        call append(0,"/**")
        call append(1," * Author        : Peng Zhou")
        call append(2," * Email         : zhoupengcv@sjtu.edu.cn")
        call append(3," * Last modified : ".strftime("%Y-%m-%d %H:%M"))
        call append(4," * Filename      : ".expand("%:t"))
        call append(5," * Description   : ")
        call append(6," */") 
        echohl WarningMsg | echo "Successful in adding the copyright." | echohl None
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"end add author information
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
