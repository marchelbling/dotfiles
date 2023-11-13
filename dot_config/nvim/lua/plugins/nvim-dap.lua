return {
	"https://github.com/mfussenegger/nvim-dap",
	config = function()
		-- https://miguelcrespo.co/posts/how-to-debug-like-a-pro-using-neovim/
		vim.keymap.set("n", "<F5>", require("dap").continue)
		vim.keymap.set("n", "<F10>", require("dap").step_over)
		vim.keymap.set("n", "<F11>", require("dap").step_into)
		vim.keymap.set("n", "<F12>", require("dap").step_out)
		vim.keymap.set("n", "<leader>b", require("dap").toggle_breakpoint)

		vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "", linehl = "", numhl = "" })
	end,
}
