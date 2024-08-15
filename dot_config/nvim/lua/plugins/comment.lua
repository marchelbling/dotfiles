return {
	-- should test https://github.com/numToStr/Comment.nvim
	"https://github.com/tomtom/tcomment_vim",
	version = "4.0.0",
	config = function()
		vim.cmd([[
		    " toggle comment on current line/visual selection
		    map <leader>c :TComment<CR>
		]])
	end,
}
