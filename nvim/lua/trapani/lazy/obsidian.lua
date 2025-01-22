return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "leo trapani's vault",
					path = "/Users/leonardotrapani/Library/Mobile Documents/iCloud~md~obsidian/Documents/leo trapani's vault",
				},
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},

			notes_subdir = "3 - Notes",
			new_notes_location = "notes_subdir",
			note_id_func = function(title)
				return title
			end,
			daily_notes = {
				-- Optional, if you keep daily notes in a separate directory.
				folder = "4 - Daily",
				-- Optional, default tags to add to each new daily note created.
				default_tags = { "daily-notes" },
				-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
				template = "Daily Template",
			},

			-- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
			-- way then set 'mappings = {}'.
			mappings = {
				-- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
				["gd"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				},
				-- Toggle check-boxes.
				["<leader>ch"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
				-- Smart action depending on context, either follow link or toggle checkbox.
				["<cr>"] = {
					action = function()
						return require("obsidian").util.smart_action()
					end,
					opts = { buffer = true, expr = true },
				},
			},

			note_frontmatter_func = function(note)
				local out = {
					connections = {},
					id = note.id,
					aliases = note.aliases,
					tags = note.tags,
					date = os.date("%Y-%m-%d"),
				}

				if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
					for k, v in pairs(note.metadata) do
						out[k] = v
					end
				end

				return out
			end,

			templates = {
				subdir = "(Templates)",
				date_format = "%Y-%m-%d",
				time_format = "%H:%M",
				tags = "",
				substitutions = {
					yesterday = function()
						return os.date("%Y-%m-%d", os.time() - 86400)
					end,
					tomorrow = function()
						return os.date("%Y-%m-%d", os.time() + 86400)
					end,
				},
			},

			ui = {
				enable = false, -- using render-markdown.nvim instead
			},
		})
	end,
}
