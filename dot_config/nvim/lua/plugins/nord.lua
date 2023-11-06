return {
	"https://github.com/arcticicestudio/nord-vim",
	config = function()
		vim.cmd([[
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
        ]])
	end,
}
