local has_null_ls, null_ls = pcall(require, "null-ls")
if not has_null_ls then
    return
end


local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local sources = {
    formatting.gofumpt,
    formatting.goimports,
    diagnostics.golangci_lint,
}

null_ls.setup({
    -- configuration:
    sources = sources,
    -- format on save
    on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
            vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
            ]])
        end
    end,
})

