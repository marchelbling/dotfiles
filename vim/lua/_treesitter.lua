local status_ok, cmp = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

local configs = require("nvim-treesitter.configs")
configs.setup {
  -- ensure_installed = "maintained",
  ensure_installed = {"bash", "python", "ruby", "go", "lua", "vim", "html", "css", "javascript", "yaml", "json", "comment"},
  sync_install = false,
  ignore_install = { "" }, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true, disable = {} },
}
