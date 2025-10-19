return {
	"luk400/vim-jukit",
	ft = { "python", "jupyter" },
	config = function()
		vim.g.jukit_mappings = 1
		vim.g.jukit_terminal = "nvimterm"
		vim.g.jukit_auto_output_hist = 0
		vim.g.jukit_clean_output = 1
		vim.g.jukit_show_prompt = 1
		vim.g.jukit_highlight_markers = 1
		vim.g.jukit_save_output = 1
		vim.g.jukit_output_bg_color = ""
		vim.g.jukit_output_marker = "# OUTPUT"
		vim.g.jukit_comment_mark = "#"
		vim.g.jukit_markdown_viewer = "jupyter"
		vim.g.jukit_convert_overwrite_default = 1
		
		vim.g.jukit_shell_cmd = "python3"
		vim.g.jukit_terminal_cmd = ""
		vim.g.jukit_auto_start_console = 0
		
		vim.keymap.set("n", "<leader>os", "<cmd>call jukit#send#section(0)<cr>", { desc = "Send code section to terminal" })
		vim.keymap.set("n", "<leader>oa", "<cmd>call jukit#send#all()<cr>", { desc = "Send all code to terminal" })
		vim.keymap.set("n", "<leader>ol", "<cmd>call jukit#send#line()<cr>", { desc = "Send current line to terminal" })
		vim.keymap.set("n", "<leader>oo", "<cmd>call jukit#cells#output_below()<cr>", { desc = "Create output cell" })
		vim.keymap.set("n", "<leader>oj", "<cmd>call jukit#cells#jump_to_next_cell()<cr>", { desc = "Jump to next cell" })
		vim.keymap.set("n", "<leader>ok", "<cmd>call jukit#cells#jump_to_previous_cell()<cr>", { desc = "Jump to previous cell" })
		vim.keymap.set("n", "<leader>od", "<cmd>call jukit#cells#delete_outputs(0)<cr>", { desc = "Delete current output cell" })
		vim.keymap.set("n", "<leader>oD", "<cmd>call jukit#cells#delete_outputs(1)<cr>", { desc = "Delete all output cells" })
		vim.keymap.set("n", "<leader>oh", "<cmd>call jukit#split#output()<cr>", { desc = "Create horizontal split" })
		vim.keymap.set("n", "<leader>ov", "<cmd>call jukit#split#output_and_text()<cr>", { desc = "Create vertical split" })
		vim.keymap.set("n", "<leader>ot", "<cmd>call jukit#split#term(jukit#util#get_layout(), '*')<cr>", { desc = "Open terminal" })
		vim.keymap.set("n", "<leader>oq", "<cmd>call jukit#split#close_split()<cr>", { desc = "Close splits" })
		vim.keymap.set("n", "<leader>or", "<cmd>call jukit#send#section(1)<cr>", { desc = "Send code section and save output" })
		vim.keymap.set("n", "<leader>on", "<cmd>call jukit#cells#create_below(0)<cr>", { desc = "Create code cell below" })
		vim.keymap.set("n", "<leader>oN", "<cmd>call jukit#cells#create_above(0)<cr>", { desc = "Create code cell above" })
		vim.keymap.set("n", "<leader>om", "<cmd>call jukit#cells#create_below(1)<cr>", { desc = "Create markdown cell below" })
		vim.keymap.set("n", "<leader>oM", "<cmd>call jukit#cells#create_above(1)<cr>", { desc = "Create markdown cell above" })
		vim.keymap.set("v", "<leader>os", "<esc><cmd>call jukit#send#selection()<cr>", { desc = "Send selection to terminal" })
		
		vim.keymap.set("n", "<leader>np", "<cmd>call jukit#convert#notebook_convert('jupyter-notebook')<cr>", { desc = "Convert to .ipynb" })
		vim.keymap.set("n", "<leader>nh", "<cmd>call jukit#convert#save_nb_to_file(0,1,'html')<cr>", { desc = "Convert to HTML" })
		vim.keymap.set("n", "<leader>nr", "<cmd>call jukit#convert#save_nb_to_file(0,1,'html')<cr>", { desc = "Convert to HTML and open" })
		vim.keymap.set("n", "<leader>np", "<cmd>call jukit#convert#save_nb_to_file(0,1,'pdf')<cr>", { desc = "Convert to PDF" })
	end,
}