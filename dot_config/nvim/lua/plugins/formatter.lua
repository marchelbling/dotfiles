return {
	"mhartington/formatter.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		vim.cmd([[
            augroup FormatAutogroup
            autocmd!
            autocmd BufWritePost * FormatWrite
            augroup END
        ]])

		local util = require("formatter.util")
		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				js = {
					require("formatter.filetypes.javascript").prettier,
				},
				python = {
					function()
						return {
							exe = "ruff",
							stdin = true,
							args = {
								"format",
								"--line-length",
								120,
								"--stdin-filename",
								util.escape_path(util.get_current_buffer_file_path()),
							},
						}
					end,
				},
				go = {
					-- goimports:
					function()
						return {
							exe = "goimports",
							stdin = true,
							-- , args = {
							--     "-local",
							--     "github.com/la-tournee/refill"
							-- }
						}
					end,
					-- gofumpt:
					function()
						return {
							exe = "gofumpt",
							stdin = true,
						}
					end,
				},
			},
		})
	end,
}
