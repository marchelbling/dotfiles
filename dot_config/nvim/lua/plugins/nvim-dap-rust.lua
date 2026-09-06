-- Rust debugging via lldb-dap, which ships with Xcode (already in the Brewfile),
-- so there is nothing extra to install — unlike the usual codelldb route.
return {
	"https://github.com/mfussenegger/nvim-dap",
	config = function()
		local dap = require("dap")

		local lldb_dap = vim.fn.trim(vim.fn.system({ "xcrun", "-f", "lldb-dap" }))
		if vim.v.shell_error ~= 0 or lldb_dap == "" then
			vim.schedule(function()
				vim.notify(
					"dap: `lldb-dap` not found — install Xcode (or run `xcode-select --install`).",
					vim.log.levels.WARN,
					{ title = "nvim-dap-rust" }
				)
			end)
			return
		end

		dap.adapters.lldb = {
			type = "executable",
			command = lldb_dap,
			name = "lldb",
		}

		-- Without these, Vec/String/Option render as raw memory instead of values.
		local function rust_init_commands()
			local sysroot = vim.fn.trim(vim.fn.system({ "rustc", "--print", "sysroot" }))
			if vim.v.shell_error ~= 0 or sysroot == "" then
				return {}
			end
			local etc = sysroot .. "/lib/rustlib/etc"
			return {
				"command script import " .. etc .. "/lldb_lookup.py",
				"command source -s 0 " .. etc .. "/lldb_commands",
			}
		end

		dap.configurations.rust = {
			{
				name = "Launch (prompt for binary)",
				type = "lldb",
				request = "launch",
				program = function()
					local target = vim.fs.root(0, { "Cargo.toml" }) or vim.uv.cwd()
					return vim.fn.input("Path to executable: ", target .. "/target/debug/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
				initCommands = rust_init_commands,
			},
		}
	end,
}
