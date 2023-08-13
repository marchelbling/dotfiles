local has_formatter, formatter = pcall(require, "formatter")
if not has_formatter then
	return
end

vim.cmd([[
    augroup FormatAutogroup
    autocmd!
    autocmd BufWritePost * FormatWrite
    augroup END
]])

require("formatter").setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    lua = {
        require("formatter.filetypes.lua").stylua,
    },
    js = {
        require("formatter.filetypes.javascript").prettier,
    },
    go = {
        -- goimports:
        function()
            return {
                exe = "goimports"
                , stdin = true
                -- , args = {
                --     "-local",
                --     "github.com/la-tournee/refill"
                -- }
            }
        end,
        -- gofumpt:
        function()
            return {
                exe = "gofumpt"
                , stdin = true
            }
        end
    },
  }
}
