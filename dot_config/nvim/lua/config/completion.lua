-- Native LSP completion settings (Neovim 0.11+)
-- Completion enabling is done in nvim-lspconfig on_attach

vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.opt.shortmess:append("c")

-- Manual trigger (cmp-style)
vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.trigger()
end, { desc = "LSP completion" })

-- Auto-trigger signature help when typing function arguments
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Setup signature help triggers",
	callback = function(ev)
		local bufnr = ev.buf
		vim.api.nvim_create_autocmd("InsertCharPre", {
			buffer = bufnr,
			callback = function()
				local char = vim.v.char
				if char == "(" or char == "," then
					vim.defer_fn(function()
						vim.lsp.buf.signature_help()
					end, 0)
				end
			end,
		})
	end,
})
