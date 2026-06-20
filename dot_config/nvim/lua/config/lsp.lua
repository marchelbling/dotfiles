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

	-- Highlight references of the symbol under the cursor (native, Neovim 0.11+).
	-- Debounced on CursorMoved so it feels immediate (independent of 'updatetime').
	if client:supports_method("textDocument/documentHighlight") then
		local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
		local timer = vim.uv.new_timer()
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			group = group,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.clear_references()
				timer:stop()
				timer:start(
					120,
					0,
					vim.schedule_wrap(function()
						if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
							vim.lsp.buf.document_highlight()
						end
					end)
				)
			end,
		})
		vim.api.nvim_create_autocmd("LspDetach", {
			group = group,
			buffer = bufnr,
			callback = function()
				timer:stop()
				if not timer:is_closing() then
					timer:close()
				end
			end,
		})
	end

	-- delegate formatting to dedicated plugins
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false

	-- Enable native LSP completion (Neovim 0.11+)
	vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
end

return M
