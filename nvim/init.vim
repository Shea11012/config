let mapleader=" "	"修改leader为空格
syntax on	"语法高亮
set nocompatible "不使用vi模式，使用vim模式
set cursorline
set showcmd
set number
set wildmenu	"命令行补全
set ruler	"在状态栏显示光标的坐标
set hlsearch	"开启高亮搜索
set incsearch	"输出字符串时同时进行搜索
set ignorecase	"搜索时忽略大小写

set noeb	"取消错误提示音
set autoindent "自动缩进
set smartindent "自动对齐
filetype indent on "自适应不同语言的智能缩进
filetype plugin on	"加载对应文件类型插件
filetype plugin indent on
set mouse=i		"仅在insert mode下可使用mouse

set listchars=tab:>-,trail:-	"tab显示为 >-,trail显示为 -
set softtabstop=4 	"缩进宽度
set tabstop=4	"tab宽度
set shiftwidth=4	"自动缩进时的宽度
set smarttab	"在行和段开始处使用制表符
set history=999	"命令历史记录数
set encoding=utf-8 nobomb	"设置字符编码，无bomb
set helplang=cn
set termencoding=utf-8
set langmenu=zh_CN.UTF-8
set laststatus=2	"总是显示状态栏
set wrap	"拆行
set lbr		"不在单词中间换行
set ru


"垂直分屏
map si :set splitright<CR>:vsplit<CR>
"横向分屏
map sb :set splitbelow<CR>:split<CR>

"向左移动一个分屏
map <LEADER>h <C-w>h
"向右移动一个分屏
map <LEADER>l <C-w>l
"向上移动一个分屏
map <LEADER>j <C-w>j
"向下移动一个分屏
map <LEADER>k <C-w>k

nnoremap <F3> :NERDTreeToggle<CR>


call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdtree'
Plug 'preservim/nerdcommenter'

call plug#end()
