"use anonymous pro font from http://www.ms-studio.com/FontSales/anonymouspro.html

"break vi compatibility
set nocompatible
"prevent file exploit
set modelines=0

"pathogen
call pathogen#infect()

"detect file type
filetype on
"use specific filetype plugins
filetype plugin on
filetype plugin indent on

"code highlight:
syntax on
"colorscheme:
"colorscheme mustang
colorscheme wombat
"font:
set gfn=Anonymous\ Pro:h14

"navigate through tabs
nmap <C-S-tab> :tabprevious<CR>
nmap <C-tab> :tabnext<CR>

"leader character:
let mapleader = ","

"indentation
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
"text layout
set wrap
set textwidth=100
set formatoptions=qrn1
set colorcolumn=80

"show trailing spaces
highlight TrailingSpaces ctermbg=red guibg=red
match TrailingSpaces /\s\+$\|\t/

set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest,full
set visualbell
set cursorline
set ttyfast
set ruler
set backspace=indent,eol,start
set laststatus=2


"search option
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
"clear highlight on 'return':
nnoremap <silent> <CR> :noh<CR>


set paste
set nosmartindent

"manage backup, swap & undo directories
"/!\ this requires that the .vim-* directories exist
"could use  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1  to create them if needed
set backupdir=~/.vim-back
set directory=~/.vim-swap
set undodir=~/.vim-undo
set backup
set undofile

"json highlight
au BufRead,BufNewFile *.json set filetype=json

"ruby compiler check
autocmd FileType ruby compiler ruby

function! DoPrettyJSON()
  " save the filetype so we can restore it later
  let l:origft = &ft
  " this requires a python install
  silent %!python -m json.tool
  exe "set ft=" . l:origft
endfunction
command! PrettyJSON call DoPrettyJSON()

function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()
