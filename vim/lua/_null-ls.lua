local has_null_ls, null_ls = pcall(require, "null-ls")
if not has_null_ls then
	return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup({
	-- configuration:
	sources = {
		-- lua
		formatting.stylua,
		-- golang
		formatting.gofumpt,
		formatting.goimports,
		diagnostics.golangci_lint,
		-- js/html
		formatting.prettier,
		code_actions.eslint,
	},
	-- format on save
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
