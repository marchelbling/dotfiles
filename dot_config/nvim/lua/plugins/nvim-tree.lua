return {
	"https://github.com/nvim-tree/nvim-tree.lua",
	dependencies = { "https://github.com/nvim-tree/nvim-web-devicons" },
	config = function()
		require("nvim-tree").setup()

		vim.keymap.set("n", "t", "<cmd>NvimTreeToggle<cr>")
	end,
}
