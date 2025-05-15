return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",

	config = function()
		vim.opt.termguicolors = true
		require("bufferline").setup({
			options = {
				close_command = "Bdelete! %d", -- can be a string | function, see "Mouse actions"
			},
		})
	end,
}
