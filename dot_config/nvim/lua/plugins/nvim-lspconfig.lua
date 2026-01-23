return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"RRethy/vim-illuminate",
	},
	config = function()
		-- helper function for mappings (buffer-local)
		local m = function(bufnr, mode, key, rhs)
			vim.keymap.set(mode, key, rhs, { buffer = bufnr, noremap = true, silent = true })
		end

		-- function to attach completion when setting up lsp
		local on_attach = function(client, bufnr)
			-- Mappings.
			m(bufnr, "n", "ga", vim.lsp.buf.code_action)
			m(bufnr, "n", "gD", vim.lsp.buf.declaration)
			m(bufnr, "n", "gd", vim.lsp.buf.definition)

			-- These used to be vim.lsp.diagnostic.* (deprecated). Use vim.diagnostic.*
			m(bufnr, "n", "ge", vim.diagnostic.goto_next)
			m(bufnr, "n", "gE", vim.diagnostic.goto_prev)
			m(bufnr, "n", "gl", vim.diagnostic.open_float)

			m(bufnr, "n", "gi", vim.lsp.buf.implementation)
			m(bufnr, "n", "gr", vim.lsp.buf.references)
			m(bufnr, "n", "H", vim.lsp.buf.hover)
			m(bufnr, "i", "<C-k>", vim.lsp.buf.signature_help)

			local has_illuminate, illuminate = pcall(require, "illuminate")
			if has_illuminate then
				illuminate.on_attach(client)
			end

			-- delegate formatting to dedicated plugins
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false

			-- Enable native LSP completion (Neovim 0.11+)
			vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
		end

		-- diagnostics
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
				source = "if_many",
				spacing = 4,
			},
			underline = { severity = { min = vim.diagnostic.severity.WARN } },
			float = {
				source = "if_many",
				border = "rounded",
				header = "",
				prefix = function(diag)
					local icons = { "E", "W", "H", "I" }
					return icons[diag.severity] .. " ", "Diagnostic" .. ({ "Error", "Warn", "Hint", "Info" })[diag.severity]
				end,
			},
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = " ",
					[vim.diagnostic.severity.INFO] = " ",
				},
				priority = 20,
			},
			update_in_insert = false,
		})

		-- Find Python path by walking up directories to find .venv
		local function find_python_path(start_dir)
			local dir = start_dir
			while dir and dir ~= "/" do
				-- Check for .venv or venv
				for _, venv_name in ipairs({ ".venv", "venv" }) do
					local python_path = dir .. "/" .. venv_name .. "/bin/python"
					if vim.fn.executable(python_path) == 1 then
						return python_path
					end
				end
				dir = vim.fn.fnamemodify(dir, ":h")
			end
			-- Check VIRTUAL_ENV (set by venv-selector)
			local venv = os.getenv("VIRTUAL_ENV")
			if venv then
				local python_path = venv .. "/bin/python"
				if vim.fn.executable(python_path) == 1 then
					return python_path
				end
			end
			-- Fallback to system Python
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		-- Your server configs (kept as-is, but we'll feed them into vim.lsp.config)
		local servers = {
			pyright = {
				-- Find project root by looking for pyproject.toml, .venv, or .git
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local root = vim.fs.root(bufnr, { "pyproject.toml", ".venv", "venv", ".git" })
					on_dir(root or vim.fn.fnamemodify(fname, ":h"))
				end,
				on_init = function(client)
					-- Set Python path based on project venv
					local root = client.config.root_dir or vim.fn.getcwd()
					local python_path = find_python_path(root)
					client.config.settings = client.config.settings or {}
					client.config.settings.python = client.config.settings.python or {}
					client.config.settings.python.pythonPath = python_path
				end,
				settings = {
					python = {
						analysis = {
							autoImportCompletions = true,
							diagnosticMode = "openFilesOnly", -- "workspace" would diagnose all files
							useLibraryCodeForTypes = true,
						},
					},
				},
			},
			clangd = {},
			gopls = {
				root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
				cmd = { "gopls", "serve" },
				settings = {
					gopls = {
						codelenses = {
							test = true,
							tidy = true,
							vendor = true,
						},
						gofumpt = true,
						usePlaceholders = true,
						buildFlags = { "-tags=integration" },
					},
				},
			},
			solargraph = {},
			terraformls = {},
			html = {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				configurationSection = { "html", "css", "javascript" },
				embeddedLanguages = {
					css = true,
					javascript = true,
				},
				provideFormatter = true,
			},
		}

		-- Register configs using the new Neovim 0.11+ API
		local enabled = {}
		for server, cfg in pairs(servers) do
			vim.lsp.config(
				server,
				vim.tbl_deep_extend("force", cfg, {
					on_attach = on_attach,
				})
			)
			table.insert(enabled, server)
		end

		-- Enable them
		vim.lsp.enable(enabled)
	end,
}
