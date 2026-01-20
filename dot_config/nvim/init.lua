-- setup lazy package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- override leader key: this is required before lazy loads plugins to have correct mappings
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- legacy init.vim configuration
vim.cmd([[
    " trailing spaces (no automatic killing of them though)
    highlight TrailingSpaces ctermbg=red guibg=red
    match TrailingSpaces /\s\+$/

    "clear highlight on 'return' (except in quickfix/loclist)
    nnoremap <silent> <expr> <CR> &buftype ==# 'quickfix' ? "\<CR>" : ":noh\<CR>"

    " use visual selection as (forward) search
    vnoremap <silent> * :<C-U>
                \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
                \gvy/<C-R><C-R>=substitute(
                \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
                \gV:call setreg('"', old_reg, old_regtype)<CR>

    """"""" navigation
    " navigate through buffers using ctrl-h & ctrl-l in normal/insert modes (rely on barbar)
    nnoremap <C-h> :BufferPrevious<CR>
    nnoremap <C-l> :BufferNext<CR>
    inoremap <C-h> <Esc>:BufferPrevious<CR>i
    inoremap <C-l> <Esc>:BufferNext<CR>i
    nnoremap <C-x> :bd<CR>

    " navigate through splits using arrows
    nmap <silent> <S-Up> :wincmd k<CR>
    nmap <silent> <S-Down> :wincmd j<CR>
    nmap <silent> <S-Left> :wincmd h<CR>
    nmap <silent> <S-Right> :wincmd l<CR>


    """""" utilities
    " git commit messages with spelling and automatic insert mode
    if has("spell")
        au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell spelllang=en
    endif

    if has("nvim")
        " fix escape mapping for neovim and make mapping compatible with fzf
        " preview window; see https://github.com/junegunn/fzf.vim/issues/544#issuecomment-457456166.
        tnoremap <expr> <Esc> (&filetype == "fzf") ? "<Esc>" : "<c-\><c-n>"
    endif
]])

-- see https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
local set = vim.opt

vim.cmd([[
    :silent !mkdir -p $HOME/.vim/udata/undo >/dev/null 2>&1
    :silent !mkdir -p $HOME/.vim/udata/back >/dev/null 2>&1
]])
HOME = os.getenv("HOME")

-- general
set.encoding = "utf8"
set.compatible = false -- break vi compatibility

set.modelines = 0 -- prevent file exploit
set.title = true -- change terminal/window title to buffer name
set.swapfile = false
set.backupdir = HOME .. "/.vim/udata/back"
set.undodir = HOME .. "/.vim/udata/undo"
set.undofile = true
set.history = 1000
set.undolevels = 1000
set.confirm = true -- warn for unsaved changes before exiting

-- indentation
set.colorcolumn = { "100" }
set.scrolloff = 5 -- always show at least 5 lines below
set.formatoptions = "qrn1j"
set.shiftround = true -- round indent to multiple of shiftwidth
set.showmatch = true -- show matching brackets
set.linebreak = true -- change long lines display
set.visualbell = true -- enable visual bell instead of audio bell
set.cursorline = true -- highlight current line
set.gdefault = true -- set g by default for substitute commands (%s///g)
set.clipboard = "unnamed" -- use the system clipboard
set.listchars = { eol = "↲", tab = "▸ ", trail = "·" } -- display tab and br nicely

-- editing
set.backspace = { "indent", "eol", "start" } -- low backspacing over an indent, line break (end of line) or start of an insert

-- searching
set.ignorecase = true
set.smartcase = true
set.wildignorecase = true -- case insensitive file completion
set.wildmenu = true -- bash-like tab completion
set.wildmode = { "list:longest", "full" }
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true

-- load plugin configuration automatically from the lua/plugins folder
require("lazy").setup("plugins")

-- activate native autocompletion
require("config.completion")
