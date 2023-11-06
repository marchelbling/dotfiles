return {
	"https://github.com/ray-x/lsp_signature.nvim",
	event = "VeryLazy",
	config = function()
		require("lsp_signature").setup({
			bind = true,
			hint_enable = false,
			max_width = 120,
			handler_opts = { border = "none" },
		})
	end,
}
