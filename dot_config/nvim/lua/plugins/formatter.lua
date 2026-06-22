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

		-- find a project marker by walking up from the current buffer's file
		local function find_upward(names)
			local file = vim.api.nvim_buf_get_name(0)
			local from = (file ~= "" and file) or vim.uv.cwd()
			return vim.fs.find(names, { upward = true, path = from })[1]
		end

		-- true when the project configures ruff itself (so we must not override it)
		local function project_has_ruff_config()
			if find_upward({ "ruff.toml", ".ruff.toml" }) then
				return true
			end
			local pyproject = find_upward({ "pyproject.toml" })
			return pyproject ~= nil and table.concat(vim.fn.readfile(pyproject), "\n"):match("%[tool%.ruff") ~= nil
		end

		-- goimports -local prefix, derived from the nearest go.mod module path
		local function go_local_prefix()
			local gomod = find_upward({ "go.mod" })
			if not gomod then
				return nil
			end
			for _, line in ipairs(vim.fn.readfile(gomod)) do
				local mod = line:match("^module%s+(%S+)")
				if mod then
					return mod
				end
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
						local args = {
							"format",
							"--stdin-filename",
							util.escape_path(util.get_current_buffer_file_path()),
						}
						-- ruff discovers the project config via --stdin-filename; only fall
						-- back to a default line-length when the project sets none itself
						if not project_has_ruff_config() then
							vim.list_extend(args, { "--line-length", "120" })
						end
						return { exe = "ruff", stdin = true, args = args }
					end,
				},
				go = {
					function()
						local args = {}
						local prefix = go_local_prefix()
						if prefix then
							args = { "-local", prefix }
						end
						return if_exe("goimports", { exe = "goimports", stdin = true, args = args })
					end,
					function()
						return if_exe("gofumpt", { exe = "gofumpt", stdin = true })
					end,
				},
			},
		})
	end,
}
