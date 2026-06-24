return {
	"https://github.com/olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("codecompanion").setup({
			-- chat over ACP talks to the Cursor CLI (uses your Cursor login)
			interactions = {
				chat = { adapter = "cursor_cli" },
			},
			adapters = {
				acp = {
					-- Cursor's installer ships `cursor-agent`, not `agent`
					cursor_cli = function()
						return require("codecompanion.adapters").extend("cursor_cli", {
							commands = {
								default = { "cursor-agent", "acp" },
							},
						})
					end,
				},
			},
		})

		local map = vim.keymap.set
		-- toggle the chat buffer
		map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion chat" })
		-- action palette
		map({ "n", "v" }, "<leader>ap", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion actions" })
		-- send visual selection to the chat
		map("v", "<leader>ac", "<cmd>CodeCompanionChat Add<cr>", { desc = "Add selection to CodeCompanion chat" })
	end,
}
