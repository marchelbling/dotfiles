return {
	"https://github.com/airblade/vim-gitgutter",
	config = function()
		vim.cmd([[
            highlight SignColumn guibg=gray17
            let g:gitgutter_realtime = 0
            let g:gitgutter_eager = 0
        ]])
	end,
}
