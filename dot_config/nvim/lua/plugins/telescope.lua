return {
	"https://github.com/nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	config = function()
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						size = {
							width = "95%",
							height = "95%",
						},
					},
				},
				pickers = {
					find_files = {
						theme = "dropdown",
					},
				},
			},
		})

		-- See `:help telescope.builtin`
		vim.keymap.set(
			"n",
			"<leader>?",
			require("telescope.builtin").oldfiles,
			{ desc = "[?] Find recently opened files" }
		)
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = true,
			}))
		end, { desc = "[/] Fuzzily search in current buffer]" })

		vim.keymap.set("n", "<leader>p", function()
			-- https://github.com/nvim-telescope/telescope.nvim/issues/2183#issuecomment-1264492824
			local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
			if in_git_repo then
				require("telescope.builtin").git_files()
			else
				require("telescope.builtin").find_files()
			end
		end, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>k", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "K", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)
	end,
}
