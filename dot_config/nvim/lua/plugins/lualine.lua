return {
	"https://github.com/nvim-lualine/lualine.nvim",
	opts = {
		options = {
			icons_enabled = true,
			theme = "nord",
		},
		sections = {
			lualine_x = {
				{
					require("noice").api.statusline.mode.get,
					cond = require("noice").api.statusline.mode.has,
					color = { fg = "#ff9e64" },
				},
				{
					require("noice").api.status.command.get,
					cond = require("noice").api.status.command.has,
					color = { fg = "#ff9e64" },
				},
			},
			lualine_y = { "searchcount" },
		},
	},
}
