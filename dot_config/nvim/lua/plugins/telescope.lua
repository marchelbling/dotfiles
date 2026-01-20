return {
	"https://github.com/nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	config = function()
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						size = {
							width = "95%",
							height = "95%",
						},
					},
				},
				pickers = {
					find_files = {
						theme = "dropdown",
					},
				},
				wrap_results = true,
				-- path_display = "truncate", -- mutually exclusive with wrap_results
			},
		})

		-- See `:help telescope.builtin`
		vim.keymap.set(
			"n",
			"<leader>?",
			require("telescope.builtin").oldfiles,
			{ desc = "[?] Find recently opened files" }
		)
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = true,
			}))
		end, { desc = "[/] Fuzzily search in current buffer]" })

		vim.keymap.set("n", "<leader>p", function()
			-- https://github.com/nvim-telescope/telescope.nvim/issues/2183#issuecomment-1264492824
			local in_git_repo = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
			if in_git_repo then
				require("telescope.builtin").git_files()
			else
				require("telescope.builtin").find_files()
			end
		end, { desc = "[S]earch [F]iles" })
		-- Helper to get visual selection
		local function get_visual_selection()
			local _, ls, cs = unpack(vim.fn.getpos("v"))
			local _, le, ce = unpack(vim.fn.getpos("."))
			-- Ensure correct order
			if ls > le or (ls == le and cs > ce) then
				ls, le = le, ls
				cs, ce = ce, cs
			end
			local lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
			return table.concat(lines, "\n")
		end

		-- live_grep with word under cursor (normal) or visual selection
		vim.keymap.set("n", "<leader>k", function()
			local word = vim.fn.expand("<cword>")
			require("telescope.builtin").live_grep({ default_text = word })
		end, { desc = "[S]earch live grep with current [W]ord" })

		vim.keymap.set("v", "<leader>k", function()
			local text = get_visual_selection()
			-- Escape special regex characters for ripgrep
			text = vim.fn.escape(text, "\\^$.*+?()[]{}|")
			require("telescope.builtin").live_grep({ default_text = text })
		end, { desc = "[S]earch live grep with selection" })

		vim.keymap.set("n", "K", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })

		-- Fuzzy grep: rg returns all matches, telescope does fuzzy filtering
		vim.keymap.set("n", "<leader>K", function()
			require("telescope.builtin").grep_string({
				search = "^",
				only_sort_text = true,
				prompt_title = "Fuzzy Grep",
				use_regex = true,
			})
		end, { desc = "[S]earch by fuzzy [G]rep" })
		vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
		vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)
	end,
}
