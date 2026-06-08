-- Executed automatically by Neovim when a Java buffer is opened.
-- Do NOT add jdtls to the nvim-lspconfig servers table — it would conflict.

local jdtls = require("jdtls")
local on_attach = require("config.lsp").on_attach

-- Unique workspace per project (jdtls maintains per-project index state)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

-- All JDKs are managed by mise (single source of truth). From the installed set
-- we derive two things, cached for the whole nvim session:
--   * server_java: a >=21 JDK to RUN jdtls itself (the server requires Java 21+,
--     independent of whatever version the current project pins in its .mise.toml)
--   * runtimes:    a JavaSE-<major> -> path table so jdtls COMPILES each project
--     against its own JDK (e.g. a java17 project maps to JavaSE-17 automatically)
local function mise_java()
	if vim.g._jdtls_mise_java then
		return vim.g._jdtls_mise_java
	end
	local out = vim.fn.system({ "mise", "ls", "java", "--json" })
	local ok, list = pcall(vim.json.decode, out)
	local runtimes, server_java = {}, nil
	if ok and vim.v.shell_error == 0 and type(list) == "table" then
		for _, j in ipairs(list) do
			local major = tonumber((j.version or ""):match("^(%d+)"))
			if major and j.install_path then
				table.insert(runtimes, { name = "JavaSE-" .. major, path = j.install_path })
				-- prefer the lowest >=21 install as the (well-tested) server runtime
				if major >= 21 and (not server_java or major < server_java.major) then
					server_java = { major = major, bin = j.install_path .. "/bin/java" }
				end
			end
		end
	end
	local result = { runtimes = runtimes, bin = server_java and server_java.bin or "java" }
	vim.g._jdtls_mise_java = result
	return result
end

local java = mise_java()

jdtls.start_or_attach({
	cmd = { "jdtls", "--java-executable", java.bin, "-data", workspace_dir },

	root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }),

	settings = {
		java = {
			configuration = { runtimes = java.runtimes },
			signatureHelp = { enabled = true },
			contentProvider = { preferred = "fernflower" },
			completion = {
				favoriteStaticMembers = {
					"org.junit.Assert.*",
					"org.junit.jupiter.api.Assertions.*",
					"org.mockito.Mockito.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
		},
	},

	on_attach = function(client, bufnr)
		on_attach(client, bufnr)

		-- Java-specific refactoring commands
		local m = function(mode, key, rhs)
			vim.keymap.set(mode, key, rhs, { buffer = bufnr, noremap = true, silent = true })
		end
		m("n", "<leader>jo", jdtls.organize_imports)
		m("n", "<leader>jv", jdtls.extract_variable)
		m("v", "<leader>jv", function() jdtls.extract_variable(true) end)
		m("n", "<leader>jc", jdtls.extract_constant)
		m("v", "<leader>jc", function() jdtls.extract_constant(true) end)
		m("v", "<leader>jm", function() jdtls.extract_method(true) end)
	end,

	init_options = {
		bundles = {},
	},
})
