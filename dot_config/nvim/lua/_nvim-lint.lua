local has_nvim_lint, nvim_lint = pcall(require, "lint")
if not has_nvim_lint then
	return
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

require("lint").linters_by_ft = {
	go = { "golangcilint" },
}
