return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"RRethy/vim-illuminate",
		-- If you use nvim-cmp, keep this; otherwise remove these two lines.
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- Capabilities (nvim-cmp integration if present)
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
		if ok_cmp then
			capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
		end

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

			local has_illuminate, illuminate = pcall(require, "illuminate")
			if has_illuminate then
				illuminate.on_attach(client)
			end

			-- delegate formatting to dedicated plugins
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
		end

		vim.diagnostic.config({
			virtual_text = false,
			underline = true,
			float = { source = "always" },
			severity_sort = true,
			signs = true,
			update_in_insert = false,
		})

		local servers = {
			pyright = {
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

		local enabled = {}
		for server, cfg in pairs(servers) do
			vim.lsp.config(
				server,
				vim.tbl_deep_extend("force", cfg, {
					on_attach = on_attach,
					capabilities = capabilities,
				})
			)
			table.insert(enabled, server)
		end

		-- Enable them
		vim.lsp.enable(enabled)
	end,
}
