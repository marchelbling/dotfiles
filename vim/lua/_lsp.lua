local has_cmp, cmp = pcall(require, "cmp")
if not has_cmp then
    return
end

local has_lspconfig, lspconfig = pcall(require, "lspconfig")
if not has_lspconfig then
    return
end

local has_lsp_signature, lsp_signature = pcall(require, "lsp_signature")
if not has_lsp_signature then
    return
end

-- show function signature
lsp_signature.setup({
    bind = true,
    hint_enable = false,
    max_width = 120,
    handler_opts = { border = "none" },
})

-- helper function for mappings
local m = function(mode, key, result)
    vim.api.nvim_buf_set_keymap(0, mode, key, "<cmd> " .. result .. "<cr>", {
        noremap = true,
        silent = true,
    })
end

-- function to attach completion when setting up lsp
local on_attach = function(client)
    -- Mappings.
    m("n", "ga", "lua vim.lsp.buf.code_action()")
    m("n", "gD", "lua vim.lsp.buf.declaration()")
    m("n", "gd", "lua vim.lsp.buf.definition()")
    m("n", "ge", "lua vim.lsp.diagnostic.goto_next()")
    m("n", "gE", "lua vim.lsp.diagnostic.goto_prev()")
    m("n", "gi", "lua vim.lsp.buf.implementation()")
    m("n", "gr", "lua vim.lsp.buf.references()")
    m("n", "K", "lua vim.lsp.buf.hover()")
    -- m("n", "<space>rn", "lua vim.lsp.buf.rename()")
    m("n", "gl", "lua vim.lsp.diagnostic.show_line_diagnostics()")
    -- m("n", "<space>f", "lua vim.lsp.buf.formatting()")

    local has_illuminate, illuminate = pcall(require, "illuminate")
    if  has_illuminate then
        illuminate.on_attach(client)
    end

    if client.resolved_capabilities.document_formatting then
        vim.cmd [[
            augroup format_buffer
            au! * <buffer>
            au BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
            augroup END
        ]]
    end
end

-- diagnostics
vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    float = { source = "always" },
    severity_sort = true,
    signs = true,
    update_in_insert = false,
})

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = {
    pyright = {},
    gopls = {
        cmd = { "gopls", "serve" },
        settings = {
            gopls = {
                codelenses = {
                    test = true, -- Runs go test for a specific set of test or benchmark functions
                    tidy = true, -- Runs go mod tidy for a module
                    vendor = true, -- Runs go mod vendor for a module
                },
                gofumpt = true, -- A stricter gofmt
                usePlaceholders = true, -- enables placeholders for function parameters or struct fields in completion responses
            },
        },
    },
    solargraph = {},
    terraformls = {},
    rust_analyzer = {
        assist = {
            importGranularity = "module",
            importPrefix = "by_self",
        },
        cargo = {
            loadOutDirsFromCheck = true
        },
        procMacro = {
            enable = true
        },
        checkOnSave = {
            command = "clippy"
        },
    }
}
for server, config in pairs(servers) do
  lspconfig[server].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = config.settings or {}
  }
end

-- diagnostics
vim.diagnostic.config({
    virtual_text = false,
    underline = true,
    float = {
        source = "always",
    },
    severity_sort = true,
    --[[ virtual_text = {
      prefix = "»",
      spacing = 4,
    }, ]]
    signs = true,
    update_in_insert = false,
})

-- from: https://github.com/neovim/nvim-lspconfig/issues/115
function goimports(timeout_ms)
    local context = { only = { "source.organizeImports" } }
    vim.validate { context = { context, "t", true } }

    local params = vim.lsp.util.make_range_params()
    params.context = context

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
    if not result or next(result) == nil then return end
    local actions = result[1].result
    if not actions then return end
    local action = actions[1]

    if action.edit or type(action.command) == "table" then
        if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit)
        end
        if type(action.command) == "table" then
            vim.lsp.buf.execute_command(action.command)
        end
    else
        vim.lsp.buf.execute_command(action)
    end
end
vim.cmd([[ autocmd BufWritePre *.go lua goimports(1000) ]])
