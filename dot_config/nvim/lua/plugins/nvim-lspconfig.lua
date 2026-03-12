return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"RRethy/vim-illuminate",
	},
	config = function()
		local on_attach = require("config.lsp").on_attach

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

		local servers = {
			pyright = {
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local root = vim.fs.root(bufnr, { "pyproject.toml", ".venv", "venv", ".git" })
					on_dir(root or vim.fn.fnamemodify(fname, ":h"))
				end,
				on_init = function(client)
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
							diagnosticMode = "openFilesOnly",
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
			vtsls = {
				settings = {
					vtsls = { autoUseWorkspaceTsdk = true },
					typescript = {
						updateImportsOnFileMove = { enabled = "always" },
						inlayHints = {
							parameterNames = { enabled = "literals" },
							parameterTypes = { enabled = true },
							variableTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							functionLikeReturnTypes = { enabled = true },
							enumMemberValues = { enabled = true },
						},
					},
					javascript = {
						updateImportsOnFileMove = { enabled = "always" },
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

		vim.lsp.enable(enabled)
	end,
}
