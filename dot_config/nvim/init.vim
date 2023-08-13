let mapleader = ","

" Plugins install
call plug#begin('~/.vim/plugged')

Plug 'https://github.com/arcticicestudio/nord-vim'
Plug 'https://github.com/ryanoasis/vim-devicons'

Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/henrik/vim-indexed-search'
Plug 'https://github.com/Raimondi/delimitMate'

Plug 'https://github.com/tomtom/tcomment_vim'
"{{{
" toggle comment on current line/visual selection
map <leader>c :TComment<CR>
"}}}

Plug 'https://github.com/bling/vim-airline'
Plug 'https://github.com/vim-airline/vim-airline-themes'
"{{{
" vim-airline (status bar)
let g:airline_theme='base16'
let g:airline_powerline_fonts=1
set laststatus=2
set t_Co=256
let g:airline#extensions#tabline#enabled=1     " display list of opened buffers
let g:airline#extensions#tabline#fnamemod=':t' " display buffer filename only
"}}}

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" {{{
let g:fzf_nvim_statusline = 0 " disable statusline overwriting

nnoremap <silent> <leader>p :ProjectFiles<CR>
" search word under cursor or visual selection (if currently in visual mode)
" if invoked with no visual selection or no word under the cursor, this will search in the
" full project as expected
nnoremap <silent> <leader>k :call SearchWordWithAg()<CR>
vnoremap <silent> <leader>k :call SearchVisualSelectionWithAg()<CR>

" from: https://github.com/junegunn/fzf.vim/issues/47#issuecomment-160237795
function! s:find_git_root()
    return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()

function! SearchWordWithAg()
    execute 'Ag' expand('<cword>')
endfunction

function! SearchVisualSelectionWithAg() range
    let old_reg = getreg('"')
    let old_regtype = getregtype('"')
    let old_clipboard = &clipboard
    set clipboard&
    normal! ""gvy
    let selection = getreg('"')
    call setreg('"', old_reg, old_regtype)
    let &clipboard = old_clipboard
    execute 'Ag' selection
endfunction
" }}}

Plug 'https://github.com/airblade/vim-gitgutter'
"{{{
highlight SignColumn guibg=gray17
let g:gitgutter_realtime = 0
let g:gitgutter_eager = 0
"}}}

Plug 'hashivim/vim-terraform'
let g:terraform_align=1
let g:terraform_fmt_on_save=1

if has('nvim')
    " see https://github.com/neovim/neovim/issues/1822
    Plug 'bfredl/nvim-miniyank'
    map p <Plug>(miniyank-autoput)
    map P <Plug>(miniyank-autoPut)
endif

" highlighting
if has('nvim')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

" LSP / autocomplete
if has('nvim')
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-nvim-lua'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'

  Plug 'neovim/nvim-lspconfig'
  Plug 'ray-x/lsp_signature.nvim'
  Plug 'RRethy/vim-illuminate'
endif

" formatting
Plug 'nvim-lua/plenary.nvim'
Plug 'mhartington/formatter.nvim'
" linting
Plug 'mfussenegger/nvim-lint'

" Display diagnostics
Plug 'folke/trouble.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/lsp-colors.nvim'
" toggle comment on current line/visual selection
map <leader>d :TroubleToggle<CR>

call plug#end()  " required

filetype plugin indent on                " detect file type
runtime macros/matchit.vim " activate matchit (extended '%' behavior)

colorscheme nord
let g:nord_bold_vertical_split_line = 1
let g:nord_uniform_diff_background = 1
let g:nord_bold = 1
let g:nord_italic = 1
let g:nord_italic_comments = 1
let g:nord_underline = 1

let g:indent_blankline_enabled = v:false

highlight Comment cterm=italic ctermfg=245 " override default color for comments (if terminal lack suppor for true color)"
" workaround italic support for OSX terminal (see: https://stackoverflow.com/a/53625973)
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"


lua require "_configuration"
lua require "_treesitter"
lua require "_cmp"
lua require "_lsp"
lua require "_formatter"
lua require "_nvim-lint"
lua require "_trouble"

" automatically reload vim configuration when a change is detected (http://superuser.com/a/417997)
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

" trailing spaces (no automatic killing of them though)
highlight TrailingSpaces ctermbg=red guibg=red
match TrailingSpaces /\s\+$/

"clear highlight on 'return'
nnoremap <silent> <CR> :noh<CR>

" use visual selection as (forward) search
vnoremap <silent> * :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy/<C-R><C-R>=substitute(
            \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>

""""""" navigation
" navigate through buffers using ctrl-h & ctrl-l in normal/insert modes
nnoremap <C-h> :bprevious<CR>
nnoremap <C-l> :bnext<CR>
inoremap <C-h> <Esc>:bprevious<CR>i
inoremap <C-l> <Esc>:bnext<CR>i
nnoremap <C-x> :bd<CR>

" navigate through splits using arrows
nmap <silent> <S-Up> :wincmd k<CR>
nmap <silent> <S-Down> :wincmd j<CR>
nmap <silent> <S-Left> :wincmd h<CR>
nmap <silent> <S-Right> :wincmd l<CR>


"""""" utilities
" git commit messages with spelling and automatic insert mode
if has("spell")
    au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell
endif

" prettify json
function! DoPrettyJSON()
    let l:origft = &ft
    silent %!python3 -m json.tool
    exe "set ft=" . l:origft
endfunction
command! PrettyJSON call DoPrettyJSON()

if has("nvim")
    " fix escape mapping for neovim and make mapping compatible with fzf
    " preview window; see https://github.com/junegunn/fzf.vim/issues/544#issuecomment-457456166.
    tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"
endif