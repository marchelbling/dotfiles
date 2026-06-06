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

		local warned = {}
		local function if_exe(exe, spec)
			if vim.fn.executable(exe) == 1 then
				return spec
			end
			if not warned[exe] then
				warned[exe] = true
				vim.schedule(function()
					vim.notify(
						("formatter: `%s` not found in $PATH — skipping. Run `mise install`."):format(exe),
						vim.log.levels.WARN,
						{ title = "formatter.nvim" }
					)
				end)
			end
			return nil
		end
		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				javascript = {
					require("formatter.filetypes.javascript").prettier,
				},
				javascriptreact = {
					require("formatter.filetypes.javascript").prettier,
				},
				typescript = {
					require("formatter.filetypes.typescript").prettier,
				},
				typescriptreact = {
					require("formatter.filetypes.typescript").prettier,
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
					function()
						return if_exe("goimports", { exe = "goimports", stdin = true })
					end,
					function()
						return if_exe("gofumpt", { exe = "gofumpt", stdin = true })
					end,
				},
			},
		})
	end,
}
