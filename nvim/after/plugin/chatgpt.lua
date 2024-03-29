local chatgpt = require("chatgpt")

-- Open the file in read mode
local file = io.open(os.getenv("HOME") .. "/.openaiapikey.txt", "r")

-- Check if the file exists
if file then
	-- Read the content of the file
	local content = file:read("*all")

	-- Close the file
	file:close()

	-- Store the content in a variable
	local apiKey = content

	chatgpt.setup({
		api_key_cmd = "echo " .. apiKey,
		yank_register = "+",
		edit_with_instructions = {
			diff = false,
			keymaps = {
				close = "q",
				accept = "<C-y>",
				toggle_diff = "<C-d>",
				toggle_settings = "<C-o>",
				cycle_windows = "<Tab>",
				use_output_as_input = "<C-i>",
			},
		},
		chat = {
			welcome_message = "Hello Leo, I'm here to make you look like a better programmer.",
			loading_text = "Loading...",
			question_sign = "⚪️",
			answer_sign = "ﮧ",
			max_line_length = 120,
			sessions_window = {
				border = {
					style = "rounded",
					text = {
						top = " Sessions ",
					},
				},
				win_options = {
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
				},
			},
			keymaps = {
				close = { "q" },
				yank_last = "<C-y>",
				yank_last_code = "<C-k>",
				scroll_up = "<C-u>",
				scroll_down = "<C-d>",
				new_session = "<C-n>",
				cycle_windows = "<Tab>",
				cycle_modes = "<C-f>",
				select_session = "<Space>",
				rename_session = "r",
				delete_session = "d",
				draft_message = "<C-d>",
				toggle_settings = "<C-o>",
				toggle_message_role = "<C-r>",
				toggle_system_role_open = "<C-s>",
			},
		},
		popup_layout = {
			default = "center",
			center = {
				width = "80%",
				height = "80%",
			},
			right = {
				width = "30%",
				width_settings_open = "50%",
			},
		},
		popup_window = {
			border = {
				highlight = "FloatBorder",
				style = "rounded",
				text = {
					top = " ChatGPT ",
				},
			},
			win_options = {
				wrap = true,
				linebreak = true,
				foldcolumn = "1",
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
			buf_options = {
				filetype = "markdown",
			},
		},
		system_window = {
			border = {
				highlight = "FloatBorder",
				style = "rounded",
				text = {
					top = " SYSTEM ",
				},
			},
			win_options = {
				wrap = true,
				linebreak = true,
				foldcolumn = "2",
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
		},
		popup_input = {
			prompt = "  ",
			border = {
				highlight = "FloatBorder",
				style = "rounded",
				text = {
					top_align = "center",
					top = " Prompt ",
				},
			},
			win_options = {
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
			submit = "<C-Enter>",
			submit_n = "<Enter>",
		},
		settings_window = {
			border = {
				style = "rounded",
				text = {
					top = " Settings ",
				},
			},
			win_options = {
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
			},
		},
		openai_params = {
			model = "gpt-3.5-turbo",
			frequency_penalty = 0,
			presence_penalty = 0,
			max_tokens = 300,
			temperature = 0,
			top_p = 1,
			n = 1,
		},
		openai_edit_params = {
			model = "code-davinci-edit-001",
			temperature = 0,
			top_p = 1,
			n = 1,
		},
		actions_paths = {},
		show_quickfixes_cmd = "Trouble quickfix",
		predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
	})
else
	print("File not found!")
end
