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
			"ruby",
			"rust",
			"typescript",
			"vim",
			"yaml",
		},
		sync_install = false,
		ignore_install = { "" }, -- List of parsers to ignore installing
		highlight = {
			enable = true, -- false will disable the whole extension
			disable = { "" }, -- list of language that will be disabled
			additional_vim_regex_highlighting = false,
		},
		indent = { enable = true, disable = {} },
	},
}
