return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",

		-- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- https://github.com/theHamsta/nvim-dap-virtual-text
		"theHamsta/nvim-dap-virtual-text", -- inline variable text while debugging
		-- https://github.com/nvim-telescope/telescope-dap.nvim
		"nvim-telescope/telescope-dap.nvim", -- telescope integration with dap

		-- Add your own debuggers here
		"mfussenegger/nvim-dap-python",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local dap_python = require("dap-python")
		require("mason-nvim-dap").setup({
			-- Makes a best effort to setup the various debuggers with
			-- reasonable debug configurations
			automatic_setup = true,
			automatic_installation = true,

			-- You can provide additional configuration to the handlers,
			-- see mason-nvim-dap README for more information
			handlers = {},

			-- You'll need to check that you have the required things installed
			-- online, please don't ask me how to install them :)
			ensure_installed = {
				-- Update this to ensure that you have the debuggers for the langs you want
				-- 'delve',
				"debugpy",
			},
		})

		-- Basic debugging keymaps, feel free to change to your liking!
		vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
		vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
		vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
		vim.keymap.set("n", "<F4>", dapui.toggle, { desc = "Debug: See last session result." })
		vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
		vim.keymap.set("n", "<C-F5>", dap.terminate, { desc = "Debug: Terminate session" })
		vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>B", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "Debug: Set Breakpoint" })
		-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
		-- vim.keymap.set("n", "<F7>", dapui.repl.toggle, { desc = "Debug: See last session result." })
		-- dap.listeners.before.event_terminated["dapui_config"] = dapui.close
		-- dap.listeners.before.event_exited["dapui_config"] = dapui.close
		dap.listeners.after.event_initialized["dapui_config"] = dapui.open

		-- Dap UI setup
		-- For more information, see |:help nvim-dap-ui|
		dapui.setup({
			-- Set icons to characters that are more likely to work in every terminal.
			--    Feel free to remove or use ones that you like more! :)
			--    Don't feel like these are good choices.
			icons = { expanded = "", collapsed = "", current_frame = "*" },
			controls = {
				icons = {
					disconnect = "",
					pause = "",
					play = "",
					run_last = "",
					step_back = "",
					step_into = "",
					step_out = "",
					step_over = "",
					terminate = "",
				},
			},
		})

		-- Install golang specific config
		-- require('dap-go').setup()
		require("dap-python").setup()

		dap.configurations.java = {
			{
				name = "Debug Launch (2GB)",
				type = "java",
				request = "launch",
				vmArgs = "" .. "-Xmx2g ",
			},
			{
				name = "Debug Attach (8000)",
				type = "java",
				request = "attach",
				hostName = "127.0.0.1",
				port = 8000,
			},
			{
				name = "Debug Attach (5005)",
				type = "java",
				request = "attach",
				hostName = "127.0.0.1",
				port = 5005,
			},
			{
				name = "My Custom Java Run Configuration",
				type = "java",
				request = "launch",
				-- You need to extend the classPath to list your dependencies.
				-- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
				-- classPaths = {},

				-- If using multi-module projects, remove otherwise.
				-- projectName = "yourProjectName",

				-- javaExec = "java",
				mainClass = "replace.with.your.fully.qualified.MainClass",

				-- If using the JDK9+ module system, this needs to be extended
				-- `nvim-jdtls` would automatically populate this property
				-- modulePaths = {},
				vmArgs = "" .. "-Xmx2g ",
			},
		}
	end,
}
