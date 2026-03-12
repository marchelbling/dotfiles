-- Executed automatically by Neovim when a Java buffer is opened.
-- Do NOT add jdtls to the nvim-lspconfig servers table — it would conflict.

local jdtls = require("jdtls")
local on_attach = require("config.lsp").on_attach

-- Unique workspace per project (jdtls maintains per-project index state)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

jdtls.start_or_attach({
	cmd = { "jdtls", "-data", workspace_dir },

	root_dir = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }),

	settings = {
		java = {
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
