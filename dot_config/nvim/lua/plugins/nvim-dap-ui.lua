return {
	"https://github.com/rcarriga/nvim-dap-ui",
	dependencies = {
		"https://github.com/mfussenegger/nvim-dap",
		"https://github.com/nvim-neotest/nvim-nio",
	},
	config = function()
		require("dapui").setup()

		local dap, dapui = require("dap"), require("dapui")
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end
	end,
}
