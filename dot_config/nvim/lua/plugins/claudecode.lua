return {
	"https://github.com/coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = function()
		require("claudecode").setup({
			terminal = {
				split_side = "right",
				split_width_percentage = 0.35,
			},
		})

		local map = vim.keymap.set
		-- toggle Claude panel
		map("n", "<leader>cc", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
		-- send visual selection to Claude
		map("v", "<leader>cs", "<cmd>ClaudeCodeSend<cr>", { desc = "Send selection to Claude" })
		-- add file from nvim-tree to Claude context
		map("n", "<leader>ca", "<cmd>ClaudeCodeTreeAdd<cr>", { desc = "Add file to Claude context" })
		-- diff management
		map("n", "<leader>cd", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept Claude diff" })
		map("n", "<leader>cx", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny Claude diff" })

		-- suspend neovim (not just the nested claude process) when pressing <C-z> in claude terminal
		vim.api.nvim_create_autocmd("TermOpen", {
			callback = function(ev)
				if vim.api.nvim_buf_get_name(ev.buf):match("claude") then
					map("t", "<C-z>", "<cmd>suspend<CR>", { buffer = ev.buf })
					map("t", "<Esc><Esc>", "<C-\\><C-n>", { buffer = ev.buf })
				end
			end,
		})
	end,
}
