-- Native LSP completion (Neovim 0.11+)

vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.opt.shortmess:append("c")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "Enable native LSP completion",
	callback = function(ev)
		local client_id = ev.data and ev.data.client_id
		if not client_id then
			return
		end

		vim.lsp.completion.enable(true, client_id, ev.buf, {
			autotrigger = false, -- set true if you want auto popup
		})
	end,
})

-- Manual trigger (cmp-style)
vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end, { desc = "LSP completion" })
