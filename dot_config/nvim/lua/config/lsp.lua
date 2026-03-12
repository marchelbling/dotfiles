-- Shared LSP on_attach used by nvim-lspconfig and nvim-jdtls
local M = {}

M.on_attach = function(client, bufnr)
	local m = function(mode, key, rhs)
		vim.keymap.set(mode, key, rhs, { buffer = bufnr, noremap = true, silent = true })
	end

	m("n", "ga", vim.lsp.buf.code_action)
	m("n", "gD", vim.lsp.buf.declaration)
	m("n", "gd", vim.lsp.buf.definition)
	m("n", "ge", vim.diagnostic.goto_next)
	m("n", "gE", vim.diagnostic.goto_prev)
	m("n", "gl", vim.diagnostic.open_float)
	m("n", "gi", vim.lsp.buf.implementation)
	m("n", "gr", vim.lsp.buf.references)
	m("n", "H", vim.lsp.buf.hover)
	m("i", "<C-k>", vim.lsp.buf.signature_help)

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

return M
