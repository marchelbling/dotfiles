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
				-- Search for .venv directories (uv/poetry style)
				project_venvs = {
					command = "fd -HI -a -td --max-depth 4 '^\\.venv$'",
				},
				-- Also search for venv (without dot)
				venvs = {
					command = "fd -HI -a -td --max-depth 4 '^venv$'",
				},
			},
			options = {
				notify_user_on_venv_activation = true,
				-- Disable default searches (conda, pyenv, etc.)
				enable_cached_venvs = false,
			},
		},
	},
	init = function()
		-- Auto-activate closest venv when opening Python files
		-- Creates .venv if pyproject.toml exists but no venv is present
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "python",
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				if vim.b[buf].venv_selector_checked then
					return
				end
				vim.b[buf].venv_selector_checked = true

				local file_path = vim.fn.expand("%:p:h")

				-- Detect package manager from lock files
				local function detect_package_manager(dir)
					if vim.fn.filereadable(dir .. "/uv.lock") == 1 then
						return "uv"
					elseif vim.fn.filereadable(dir .. "/poetry.lock") == 1 then
						return "poetry"
					end
					return "uv" -- default to uv
				end

				-- Find pyproject.toml or .venv by walking up directories
				local function find_project_root(dir)
					-- Check for existing venv first
					local venv_path = dir .. "/.venv"
					if vim.fn.isdirectory(venv_path) == 1 then
						local python_path = venv_path .. "/bin/python"
						if vim.fn.filereadable(python_path) == 1 then
							return { venv = venv_path, needs_create = false, project_dir = dir }
						end
					end
					-- Check for pyproject.toml (project without venv)
					local pyproject_path = dir .. "/pyproject.toml"
					if vim.fn.filereadable(pyproject_path) == 1 then
						return { project_dir = dir, needs_create = true }
					end
					local parent = vim.fn.fnamemodify(dir, ":h")
					if parent ~= dir and parent ~= "/" then
						return find_project_root(parent)
					end
					return nil
				end

				local result = find_project_root(file_path)
				if not result then
					return
				end

				local pkg_manager = detect_package_manager(result.project_dir)

				-- Activate existing venv
				if not result.needs_create then
					vim.defer_fn(function()
						local ok, vs = pcall(require, "venv-selector")
						if ok and vs.activate_from_path then
							vs.activate_from_path(result.venv)
						end
					end, 100)
					return
				end

				-- Helper to activate venv after creation
				local function activate_venv(venv_path)
					vim.defer_fn(function()
						local ok, vs = pcall(require, "venv-selector")
						if ok and vs.activate_from_path then
							vs.activate_from_path(venv_path)
						end
					end, 100)
				end

				local venv_path = result.project_dir .. "/.venv"

				if pkg_manager == "poetry" then
					-- Poetry handles venv creation and deps in one command
					vim.notify("Running poetry install...", vim.log.levels.INFO)
					vim.system(
						{ "poetry", "install" },
						{ cwd = result.project_dir },
						vim.schedule_wrap(function(obj)
							if obj.code ~= 0 then
								vim.notify("poetry install failed: " .. (obj.stderr or ""), vim.log.levels.ERROR)
								return
							end
							vim.notify("Poetry install complete", vim.log.levels.INFO)
							-- Poetry may create venv elsewhere; get the path
							vim.system(
								{ "poetry", "env", "info", "--path" },
								{ cwd = result.project_dir },
								vim.schedule_wrap(function(env_obj)
									local poetry_venv = vim.trim(env_obj.stdout or "")
									if env_obj.code == 0 and poetry_venv ~= "" then
										activate_venv(poetry_venv)
									else
										-- Fallback to .venv if poetry env info fails
										activate_venv(venv_path)
									end
								end)
							)
						end)
					)
				else
					-- uv: create venv then sync
					vim.notify("Creating venv with uv...", vim.log.levels.INFO)
					vim.system(
						{ "uv", "venv", venv_path },
						{ cwd = result.project_dir },
						vim.schedule_wrap(function(obj)
							if obj.code ~= 0 then
								vim.notify("Failed to create venv: " .. (obj.stderr or ""), vim.log.levels.ERROR)
								return
							end
							vim.notify("Installing dependencies with uv sync...", vim.log.levels.INFO)
							vim.system(
								{ "uv", "sync" },
								{ cwd = result.project_dir },
								vim.schedule_wrap(function(sync_obj)
									if sync_obj.code ~= 0 then
										vim.notify("uv sync failed: " .. (sync_obj.stderr or ""), vim.log.levels.WARN)
									else
										vim.notify("Venv ready at " .. venv_path, vim.log.levels.INFO)
									end
									activate_venv(venv_path)
								end)
							)
						end)
					)
				end
			end,
		})
	end,
}
