return {
	"https://github.com/junegunn/fzf.vim",
	dependencies = { "https://github.com/junegunn/fzf", build = ":call fzf#install()" },
	config = function()
		-- disable statusline overwriting
		vim.g["fzf_nvim_statusline"] = 0

		-- search for file from git repo or current path
		vim.keymap.set("n", "<Leader>p", function()
			local folder = vim.fn.system("git rev-parse --show-toplevel 2> /dev/null | tr -d '\n'")
			if folder == "" then
				folder = vim.fn.getcwd()
			end
			vim.call("fzf#vim#files", folder, vim.call("fzf#vim#with_preview"), 0)
		end, { remap = false, silent = true })

		vim.cmd([[
            " search word under cursor or visual selection (if currently in visual mode)
            " if invoked with no visual selection or no word under the cursor, this will search in the
            " full project as expected
            nnoremap <silent> <leader>k :call SearchWordWithRg()<CR>
            vnoremap <silent> <leader>k :call SearchVisualSelectionWithRg()<CR>

            " from: https://github.com/junegunn/fzf.vim/issues/47#issuecomment-160237795
            function! s:find_git_root()
            return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
            endfunction
            command! ProjectFiles execute 'Files' s:find_git_root()

            function! SearchWordWithRg()
                execute 'Rg' expand('<cword>')
            endfunction

            function! SearchVisualSelectionWithRg() range
                let old_reg = getreg('"')
                let old_regtype = getregtype('"')
                let old_clipboard = &clipboard
                set clipboard&
                normal! ""gvy
                let selection = getreg('"')
                call setreg('"', old_reg, old_regtype)
                let &clipboard = old_clipboard
                execute 'Rg' selection
            endfunction
        ]])
	end,
}
