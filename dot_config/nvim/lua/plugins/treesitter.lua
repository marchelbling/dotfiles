return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"cmake",
			"cpp",
			"css",
			"diff",
			"go",
			"gomod",
			"gosum",
			"html",
			"javascript",
			"json",
			"lua",
			"make",
			"markdown",
			"python",
			"regex",
			"ruby",
			"rust",
			"typescript",
			"vim",
			"yaml",
		},
		sync_install = false,
		ignore_install = { "" }, -- List of parsers to ignore installing
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
		textobjects = {
			select = {
				enable = true,
				lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
			},
		},
		matchup = {
			enable = true,
			disable = {},
			enable_quotes = true,
			disable_virtual_text = false,
			include_match_words = true,
		},
	},
	config = function() end,
}
