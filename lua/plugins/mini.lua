return {
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			require("mini.pairs").setup({})
			require("mini.move").setup({
				mappings = {
					-- Move visual selection in Visual mode. Defaults are Alt (Meta) + Arrow keys.
					-- left = "<M-left>",
					-- right = "<M-right>",
					-- down = "<M-down>",
					-- up = "<M-up>",

					-- Move current line in Normal mode
					-- line_left = "<M-left>",
					-- line_right = "<M-right>",
					-- line_down = "<M-down>",
					-- line_up = "<M-up>",
				},
			})
		end,
	},
	{
		"echasnovski/mini.move",
		version = false,
	},
	{
		"echasnovski/mini.pairs",
		version = false,
	},
}
