return {
	"https://github.com/andymass/vim-matchup",
	lazy = false,
	opts = {}, -- for default options, refer to the configuration section for custom setup.
	config = function()
		require("nvim-treesitter.configs").setup({
			matchup = {
				enable = true, -- mandatory, false will disable the whole extension
				disable = {}, -- optional, list of language that will be disabled
				enable_quotes = true,
				disable_virtual_text = false,
				include_match_words = true,
			},
		})
	end,
}
