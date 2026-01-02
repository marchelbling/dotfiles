return {
	"andymass/vim-matchup",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		vim.g.matchup_matchparen_enabled = 1
		vim.g.matchup_matchparen_offscreen = { method = "popup" }
	end,
}
