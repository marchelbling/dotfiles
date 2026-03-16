# Neovim Config: Framing Document

> Objective: evolve the config toward a minimal, state-of-the-art setup that covers modern
> software engineering practices without plugin bloat. Prefer ad-hoc configuration over
> community plugins where the tradeoff is reasonable.

---

## Current State

### Strengths

- **Native Neovim 0.11 LSP API** — uses `vim.lsp.config()` + `vim.lsp.enable()` (the new
  canonical path; nvim-lspconfig is now just a config library providing server defaults)
- **Native completion** — `vim.lsp.completion.enable()` instead of nvim-cmp; correct for 0.11+
- **Multi-language coverage** — Python, Go, TypeScript (vtsls, not the slower tsserver), Java
  (jdtls), C/C++, Ruby, Terraform, HTML
- **Full DAP stack** — nvim-dap + nvim-dap-ui + per-language adapters
- **Python automation** — venv-selector with uv/poetry auto-detection and sync on save
- **AI integration** — claudecode.nvim (MCP-based, terminal split approach)
- **Modular layout** — each plugin in its own `lua/plugins/*.lua` file, lazy-loaded cleanly

### Plugin Inventory (28 plugins)

| Plugin | Role | Status |
|---|---|---|
| lazy.nvim | Plugin manager | ✅ Standard |
| nvim-lspconfig | LSP config library | ✅ Using new 0.11 API correctly |
| nvim-treesitter | Syntax / text objects | ✅ |
| telescope.nvim + fzf-native | Fuzzy finder | ✅ |
| nvim-tree.lua | File explorer | ✅ |
| vim-fugitive | Git commands | ⚠️ Aging (no visual diff) |
| vim-gitgutter | Git signs | ❌ Vimscript; superseded by gitsigns.nvim |
| nvim-dap + dap-ui + dap-go + dap-python | Debugging | ⚠️ Python adapter unconfigured |
| nvim-jdtls | Java LSP | ✅ |
| formatter.nvim | Formatting | ❌ Superseded by conform.nvim |
| nvim-lint | Linting | ✅ |
| barbar.nvim | Buffer tabs | ⚠️ Reasonable, alternatives exist |
| lualine.nvim | Status line | ✅ |
| nord-vim | Color scheme | ✅ Personal choice |
| tcomment_vim | Commenting | ❌ Redundant — Neovim 0.10 has `gc`/`gcc` built in |
| trouble.nvim | Diagnostics / QF panel | ✅ |
| vim-matchup | Bracket matching | ✅ |
| delimitMate | Auto-close delimiters | ⚠️ Vimscript; alternatives exist |
| venv-selector.nvim | Python venv management | ✅ |
| claudecode.nvim | Claude AI integration | ✅ |
| snacks.nvim | Utility library (dep) | 💡 Underutilized — 40+ modules available |
| vim-illuminate | Symbol highlighting | ✅ |
| nvim-web-devicons | Icons | ✅ Dep |
| nvim-nio + plenary.nvim | Async utilities | ✅ Deps |

---

## Research Summary (Early 2026)

### Neovim 0.10 / 0.11 Built-in Features That Reduce Plugin Needs

| Feature | Replaces |
|---|---|
| `gc` / `gcc` commenting (0.10) | tcomment_vim, comment.nvim |
| `vim.lsp.completion.enable()` (0.11) | nvim-cmp for basic completion |
| `vim.lsp.config()` + `vim.lsp.enable()` (0.11) | `lspconfig.setup{}` pattern |
| `vim.lsp.foldexpr()` (0.11) | fold plugins |
| Default LSP keymaps `grn`, `grr`, `gra`, `gri` (0.11) | manual on_attach mappings |
| `winborder` global option (0.11) | per-plugin border config |
| Virtual lines diagnostics (0.11) | lsp_lines.nvim |
| `vim.snippet` (0.10) | snippet engines for basic LSP snippets |
| OSC 52 clipboard (0.10) | terminal clipboard hacks |

### Community Convergence Points

- **conform.nvim** has become the formatting standard (supersedes formatter.nvim, null-ls)
- **gitsigns.nvim** is the universal replacement for vim-gitgutter (Lua-native, inline blame,
  hunk staging)
- **snacks.nvim** (folke) has emerged as a meta-utility covering 40+ small features; already
  in the dependency tree via claudecode.nvim
- **blink.cmp** is challenging nvim-cmp as the completion engine (Rust-based fuzzy matching);
  not relevant here since native completion is already used
- **grug-far.nvim** fills the find-and-replace gap that Telescope doesn't cover
- **diffview.nvim** is the standard for visual diff review and merge conflict resolution
- **neotest** is the standard test runner integration (40+ language adapters)
- AI tooling has split into two layers: inline ghost text (copilot.lua, supermaven) + chat/agent
  (claudecode, avante, codecompanion); the config has the agent layer but not inline completion

---

## Gaps & Opportunities

### Priority 1: Straightforward Improvements

| Gap | Action | Notes |
|---|---|---|
| `tcomment_vim` still installed | **Remove** | `gc`/`gcc` is built into Neovim 0.10+ |
| `vim-gitgutter` (Vimscript) | **Replace with `gitsigns.nvim`** | Gains inline blame, hunk staging, word-diff |
| `formatter.nvim` | **Replace with `conform.nvim`** | Better diff preservation, 200+ formatters, actively maintained |
| `<leader>cs` conflict | **Fix** | Both `trouble` (symbols) and `claudecode` (send selection) use it |
| Python DAP empty | **Fix** — add `require("dap-python").setup(vim.fn.exepath("python"))` | The adapter is installed, just not configured |

### Priority 2: Filling Real Workflow Gaps

| Gap | Action | Notes |
|---|---|---|
| No project-wide find & replace | **Add `grug-far.nvim`** | Ripgrep-backed, editable results buffer; fills the gap between Telescope grep and `:cdo` |
| No visual diff / code review | **Add `diffview.nvim`** | `DiffviewOpen origin/main..HEAD`, 3-way merge resolution, file history |
| No markdown rendering | **Add `render-markdown.nvim`** | Useful with claudecode output, hover docs, README editing |
| snacks.nvim already a dep | **Leverage existing modules** | Notifier, LazyGit float, gitbrowse, terminal — zero new deps |

### Priority 3: Consider Adding

| Gap | Action | Notes |
|---|---|---|
| No motion enhancement | `flash.nvim` | Label-based jumping; current standard replacing leap/lightspeed |
| No interactive git TUI | `neogit` + diffview | Magit-style; only worth it if doing complex git ops from Neovim |
| No inline AI completions | `copilot.lua` or `supermaven-nvim` | Adds ghost-text layer; complementary to claudecode |
| No structured test runner | `neotest` | In-buffer pass/fail; integrates with DAP for test debugging |
| `delimitMate` replacement | `nvim-autopairs` or `mini.pairs` | Lua-native; or a small autocmd for the common cases |
| Inlay hints toggle | Ad-hoc keymap | `vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())` |
| Codelens run mapping | Ad-hoc keymap | gopls codelenses (test/tidy/vendor) are configured but have no trigger mapping |

### Not Worth Changing

- **telescope.nvim** — still excellent; snacks.nvim picker is an alternative but not a clear win
- **lualine.nvim** — works well, no reason to change
- **barbar.nvim** — functional; replacing for aesthetics is low ROI
- **nvim-tree** — works; oil.nvim is philosophically different, not strictly better
- **nord** — personal choice

---

## Learning Opportunities

Gaps inferred from the config that suggest underused Neovim features:

### Quickfix & Location List
The only access path is `<leader>xQ` via trouble. The native quickfix workflow is much more
powerful:
- `:copen` / `:cclose` — open/close quickfix
- `]q` / `[q` (or `:cnext` / `:cprev`) — navigate entries
- `:cdo s/old/new/g` — run a substitution across every quickfix entry (multi-file rename)
- `:cfdo bd` — run a command on each *file* in the list (not each entry)
- Telescope: `<C-q>` in any Telescope result sends all results to quickfix; `<M-q>` sends
  selected items only — enables powerful grep → edit workflows
- `:Ggrep` (fugitive) and `:vimgrep` both populate the quickfix list

### Registers
`set.clipboard = "unnamed"` means yanks/pastes always use the system clipboard, which is
convenient but loses register flexibility:
- Named registers `"a`–`"z` — store and recall multiple yanks (`"ayy` yank line into a, `"ap` paste)
- Black-hole register `"_` — delete without affecting clipboard (`"_dd`)
- Expression register `"=` — evaluate and insert an expression (`<C-r>=system("date")<CR>` in insert)
- `<C-r>` in insert mode — paste from any register without leaving insert (`<C-r>0` for last yank,
  `<C-r>"` for unnamed register, `<C-r>+` for system clipboard)
- `<C-r><C-r>` — paste literally (no auto-indenting)

### LSP Features Not Mapped
Several LSP capabilities are configured but have no keybindings:
- **Rename** — no explicit rename keymap; Neovim 0.11 provides `grn` as a default but it may
  be shadowed by `on_attach` overrides in the current config
- **Workspace symbols** — no mapping for `vim.lsp.buf.workspace_symbol()`; useful for
  jumping to any symbol across the project
- **Codelenses** — gopls has `test`, `tidy`, `vendor` codelenses configured but
  `vim.lsp.codelens.run()` has no keymap
- **Inlay hints toggle** — vtsls has inlay hints enabled but no toggle keymap

### Treesitter Text Objects
Configured in `treesitter.lua` (`af`/`if` for functions, `ac`/`ic` for classes, etc.) but
likely underused. Key patterns:
- `vaf` — select around function (including signature)
- `dif` — delete inside function body
- `]f` / `[f` — jump to next/previous function
- These compose with operators: `gUaf` — uppercase the entire function

### Folding
No fold configuration exists. LSP-based folding (`vim.lsp.foldexpr()` in 0.11) and treesitter
folding are both available without plugins:
```lua
set.foldmethod = "expr"
set.foldexpr = "v:lua.vim.lsp.foldexpr()"
set.foldlevel = 99  -- open all folds by default
```
- `za` — toggle fold, `zc` close, `zo` open, `zM` close all, `zR` open all
- `[z` / `]z` — move to start/end of current fold

### The `:global` Command
Powerful for multi-line operations, likely rarely used:
- `:g/pattern/d` — delete all lines matching pattern
- `:g/pattern/norm A,` — append a comma to the end of every matching line
- `:v/pattern/d` — delete all lines NOT matching (`:v` = `:g!`)
- `:g/^func/t$` — copy all function signatures to end of file

### Marks
No mark-related mappings in the config:
- `ma` — set mark `a` at current position
- `` `a `` — jump to exact position of mark `a`
- `'a` — jump to line of mark `a`
- `` `. `` — jump to last edit position (very useful after navigating away)
- `''` — jump back to last jump position (pairs well with `gd`)
- `:Telescope marks` — browse all marks

### Terminal Mode
There is an `<Esc>` mapping for terminal mode but no structured terminal workflow:
- `:term` opens a terminal in the current window
- `<C-\><C-n>` — exit terminal insert mode (what your `<Esc>` mapping does)
- `:vsplit term://lazygit` — open a command in a vertical split terminal
- snacks.nvim (already installed) provides `Snacks.lazygit()` and `Snacks.terminal()` for free

### Spell Checking
Only enabled for commit messages, but spell is useful more broadly:
- `]s` / `[s` — next/previous misspelling
- `z=` — suggest corrections for word under cursor
- `zg` — add word to dictionary
- `zw` — mark word as wrong

### The `gdefault` Setting
`set.gdefault = true` is set, which means `:s/a/b/` replaces **all occurrences on the line**
by default (no `/g` needed). This is intentional but the flags invert: to replace only the
first occurrence you now need to pass `/g` explicitly (which with gdefault means "toggle off
global"). Easy to forget when reading others' Vim advice.

---

## Next Steps

Suggested iteration order (each step is independently completable):

1. **Remove `tcomment_vim`** — delete `lua/plugins/comment.lua`; `gc`/`gcc` works natively
2. **`vim-gitgutter` → `gitsigns.nvim`** — rewrite `gitgutter.lua` with gitsigns config; add
   inline blame toggle and hunk stage/reset mappings
3. **`formatter.nvim` → `conform.nvim`** — rewrite `formatter.lua`; migrate language configs
4. **Fix `<leader>cs` conflict** — reassign trouble symbols to `<leader>ts` or similar
5. **Fix Python DAP** — add one-liner setup to `nvim-dap-python.lua`
6. **Leverage snacks.nvim** — add ad-hoc keymaps for `Snacks.lazygit()`, `Snacks.gitbrowse()`,
   `Snacks.notifier` setup
7. **Add missing LSP keymaps** — rename, workspace symbols, codelens run, inlay hint toggle
8. **Add `grug-far.nvim`** — project-wide find & replace
9. **Add `diffview.nvim`** — visual diff and merge conflict resolution
10. **Add `render-markdown.nvim`** — in-buffer rendering for hover docs and markdown files
11. **Consider `flash.nvim`** — evaluate vs. current `/` search workflow
12. **Consider `neotest`** — evaluate if test running from Neovim is worth the plugin weight
