-- Detect package manager from lock files
local function detect_package_manager(dir)
	if vim.fn.filereadable(dir .. "/uv.lock") == 1 then
		return "uv"
	elseif vim.fn.filereadable(dir .. "/poetry.lock") == 1 then
		return "poetry"
	end
	return "uv" -- default to uv
end

-- Find project root by walking up directories looking for pyproject.toml or .venv
local function find_project_root(dir)
	if vim.fn.filereadable(dir .. "/pyproject.toml") == 1 or vim.fn.isdirectory(dir .. "/.venv") == 1 then
		return dir
	end
	local parent = vim.fn.fnamemodify(dir, ":h")
	if parent ~= dir and parent ~= "/" then
		return find_project_root(parent)
	end
	return nil
end

-- Activate venv via venv-selector plugin
local function activate_venv(venv_path)
	vim.defer_fn(function()
		local ok, vs = pcall(require, "venv-selector")
		if ok and vs.activate_from_path then
			vs.activate_from_path(venv_path)
		end
	end, 100)
end

-- Run sync for the given project directory (uv sync or poetry install)
local function sync_project(project_dir)
	local pkg_manager = detect_package_manager(project_dir)
	local venv_path = project_dir .. "/.venv"

	if pkg_manager == "poetry" then
		vim.notify("Running poetry install...", vim.log.levels.INFO)
		vim.system(
			{ "poetry", "install" },
			{ cwd = project_dir },
			vim.schedule_wrap(function(obj)
				if obj.code ~= 0 then
					vim.notify("poetry install failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
					return
				end
				vim.notify("Poetry install complete", vim.log.levels.INFO)
				vim.system(
					{ "poetry", "env", "info", "--path" },
					{ cwd = project_dir },
					vim.schedule_wrap(function(env_obj)
						local poetry_venv = vim.trim(env_obj.stdout or "")
						if env_obj.code == 0 and poetry_venv ~= "" then
							activate_venv(poetry_venv)
						else
							activate_venv(venv_path)
						end
					end)
				)
			end)
		)
	else
		vim.notify("Running uv sync...", vim.log.levels.INFO)
		vim.system(
			{ "uv", "sync" },
			{ cwd = project_dir },
			vim.schedule_wrap(function(obj)
				if obj.code ~= 0 then
					vim.notify("uv sync failed: " .. (obj.stderr or ""), vim.log.levels.WARN)
				else
					vim.notify("Venv ready at " .. venv_path, vim.log.levels.INFO)
				end
				activate_venv(venv_path)
			end)
		)
	end
end

return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
		{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	},
	lazy = false,
	ft = "python",
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select venv" },
	},
	opts = {
		settings = {
			search = {
				project_venvs = {
					command = "fd -HI -a -td --max-depth 4 '^\\.venv$'",
				},
				venvs = {
					command = "fd -HI -a -td --max-depth 4 '^venv$'",
				},
			},
			options = {
				notify_user_on_venv_activation = true,
				enable_cached_venvs = false,
			},
		},
	},
	init = function()
		-- Auto-sync and activate venv when opening Python files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "python",
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				if vim.b[buf].venv_selector_checked then
					return
				end
				vim.b[buf].venv_selector_checked = true

				local project_dir = find_project_root(vim.fn.expand("%:p:h"))
				if not project_dir then
					return
				end

				sync_project(project_dir)
			end,
		})

		-- Re-sync venv when saving pyproject.toml
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "pyproject.toml",
			callback = function()
				local project_dir = vim.fn.expand("%:p:h")
				sync_project(project_dir)
			end,
		})
	end,
}
