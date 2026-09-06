-- opencode.nvim drives an `opencode` *server*; the TUI that opencode ships is what
-- renders the conversation. Rather than managing a server outside the editor, we run
-- the TUI in a snacks terminal split: it is a child job of this Neovim, so it starts
-- on demand and dies with us. Nothing to launch by hand, nothing left behind.
local cmd = { "opencode", "--port", "0" } -- port 0 = pick a free one; the plugin discovers it

-- Pinned at startup so the terminal id stays stable even if something :cd's later.
local cwd = vim.fn.getcwd()

local function term_opts(extra)
	return vim.tbl_extend("force", {
		cwd = cwd,
		count = 1, -- stable id: ignore any count prefix typed before the mapping
		win = {
			position = "right", -- fixed right split, like the claudecode integration
			width = 0.35,
			wo = { winbar = "" },
		},
	}, extra or {})
end

local function terminal(create)
	return require("snacks.terminal").get(cmd, term_opts({ create = create }))
end

-- Called by opencode.nvim when it finds no server; it then polls until one is up.
-- Start the TUI but hand focus straight back to the buffer we were editing.
local function start()
	local term = terminal(true)
	if term and term:win_valid() then
		vim.cmd.stopinsert()
		vim.cmd.wincmd("p")
	end
end

-- Top line of the visual selection at the moment Ask was triggered, so the
-- prompt window can position itself fully above it. Written by the `<leader>oa`
-- mapping, read by the `row` function installed in `config`.
local ask_sel_top = nil

return {
	"https://github.com/NickvanDyke/opencode.nvim",
	version = "*", -- latest stable release
	dependencies = {
		{
			"folke/snacks.nvim",
			-- Without `Snacks.setup()` the `input`/`picker` modules stay disabled,
			-- so Ask/Select fall back to the native cmdline `vim.ui` handlers.
			opts = {
				input = { enabled = true }, -- floating prompt for Ask
				picker = { enabled = true }, -- floating picker for Select
			},
		},
	},
	-- Loaded by lazy.nvim on the first `require("opencode")` below.
	lazy = true,
	config = function()
		-- Ask prompt placement: pinned to the left edge and vertically centered,
		-- but clamped fully above the visual selection when there is one. The
		-- row function lives here because function opts can't travel through
		-- `vim.g.opencode_opts`; patching the loaded config works because the
		-- ask UI merges `config.opts.ask.snacks` on every invocation.
		local win = require("opencode.config").opts.ask.snacks.win
		win.relative = "editor"
		win.col = 0
		win.row = function()
			local h = 3 -- 1-line input + top/bottom border
			local top = math.floor((vim.o.lines - h) / 2)
			if ask_sel_top then
				top = math.min(top, ask_sel_top - h - 1) -- keep a gap above the selection
			end
			return math.max(0, top)
		end
	end,
	init = function()
		-- Read before the plugin loads, so it must be set here rather than in `config`.
		---@type opencode.Opts
		vim.g.opencode_opts = { server = { start = start } }

		local map = vim.keymap.set
		-- toggle OpenCode panel (starts it on first use)
		map("n", "<leader>oo", function()
			require("snacks.terminal").toggle(cmd, term_opts())
		end, { desc = "Toggle OpenCode" })
		-- ask about the cursor position or selection; remember the selection start
		-- before the prompt steals focus (mode/cursor move) for `win.row` above
		map({ "n", "x" }, "<leader>oa", function()
			ask_sel_top = vim.fn.mode():match("[vV\22]") and vim.fn.line("v") or nil
			require("opencode").ask("@this: ")
		end, { desc = "Ask OpenCode" })
		-- pick from canned prompts and session commands
		map({ "n", "x" }, "<leader>os", function()
			require("opencode").select()
		end, { desc = "OpenCode prompts/commands" })
		map("n", "<leader>on", function()
			require("opencode").command("session.new")
		end, { desc = "New OpenCode session" })
		-- send a motion/selection to the prompt without asking yet
		map({ "n", "x" }, "go", function()
			return require("opencode").operator("@this ")
		end, { expr = true, desc = "Append range to OpenCode" })
		map("n", "goo", function()
			return require("opencode").operator("@this ") .. "_"
		end, { expr = true, desc = "Append line to OpenCode" })

		-- Terminal jobs normally die with Neovim, but be explicit: no orphaned
		-- opencode server outliving the editor that spawned it.
		vim.api.nvim_create_autocmd("VimLeavePre", {
			desc = "Kill the OpenCode server on exit",
			callback = function()
				local term = terminal(false)
				if term and term:buf_valid() then
					pcall(vim.fn.jobstop, vim.b[term.buf].terminal_job_id)
				end
			end,
		})
	end,
}
