-- see https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
local set = vim.opt

vim.cmd [[
    :silent !mkdir -p ~/.vim/udata/undo >/dev/null 2>&1
    :silent !mkdir -p ~/.vim/udata/back >/dev/null 2>&1
]]

-- general
set.encoding   = 'utf8'
set.compatible = false -- break vi compatibility

set.modelines  = 0 -- prevent file exploit
set.title      = true -- change terminal/window title to buffer name
set.swapfile   = false
set.backupdir  = '~/.vim/udata/back'
set.undodir    = '~/.vim/udata/undo'
set.undofile   = true
set.history    = 1000
set.undolevels = 1000
set.confirm    = true -- warn for unsaved changes before exiting

-- indentation
set.colorcolumn   = {'100'}
set.scrolloff     = 5  -- always show at least 5 lines below
set.formatoptions = 'qrn1j'
set.shiftround    = true       -- round indent to multiple of shiftwidth
set.showmatch     = true       -- show matching brackets
set.linebreak     = true       -- change long lines display
set.visualbell    = true       -- enable visual bell instead of audio bell
set.cursorline    = true       -- highlight current line
set.gdefault      = true       -- set g by default for substitute commands (%s///g)
set.clipboard     = 'unnamed'    -- use the system clipboard
set.listchars     = {eol = '↲', tab = '▸ ', trail = '·'} -- display tab and br nicely


-- editing
set.backspace = indent,eol,start -- low backspacing over an indent, line break (end of line) or start of an insert

-- searching
set.ignorecase     = true
set.smartcase      = true
set.wildignorecase = true -- case insensitive file completion
set.wildmenu       = true -- bash-like tab completion
set.wildmode       = {'list:longest', 'full'}
set.tabstop        = 4
set.softtabstop    = 4
set.shiftwidth     = 4
set.expandtab      = true
