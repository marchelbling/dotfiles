return {
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "golangcilint" },
			yaml = { "actionlint" },
		}

		local warned = {}
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				local names = lint.linters_by_ft[vim.bo.filetype] or {}
				local available = {}
				for _, name in ipairs(names) do
					local linter = lint.linters[name]
					local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
					if vim.fn.executable(cmd) == 1 then
						table.insert(available, name)
					elseif not warned[name] then
						warned[name] = true
						vim.schedule(function()
							vim.notify(
								("lint: `%s` (%s) not found in $PATH — skipping. Run `mise install`."):format(name, cmd),
								vim.log.levels.WARN,
								{ title = "nvim-lint" }
							)
						end)
					end
				end
				if #available > 0 then
					lint.try_lint(available)
				end
			end,
		})
	end,
}
