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
        dap.adapters.coreclr = {
            type = "executable",
            command = "/usr/local/bin/netcoredbg/netcoredbg",
            args = { "--interpreter=vscode" },
        }
        dap.configurations.cs = {
            {
                type = "coreclr",
                name = "Launch .NET Core",
                request = "launch",

                program = function()
                    local cwd = vim.fn.getcwd()

                    -- Находим csproj
                    local csproj_files = vim.fn.glob(cwd .. "/*.csproj", 0, 1)
                    if #csproj_files == 0 then
                        error("No .csproj file found in current directory")
                    end

                    local project_file = csproj_files[1]
                    local project_name = vim.fn.fnamemodify(project_file, ":t:r")

                    -- Читаем TargetFramework
                    local csproj_content = vim.fn.readfile(project_file)
                    local target_framework
                    for _, line in ipairs(csproj_content) do
                        local tf = line:match("<TargetFramework>(.+)</TargetFramework>")
                        if tf then
                            target_framework = tf
                            break
                        end
                    end
                    if not target_framework then
                        error("Cannot find <TargetFramework> in " .. project_file)
                    end

                    -- Выбор конфигурации Debug/Release
                    local build_config = vim.fn.input("Build configuration (Debug/Release): ", "Debug")
                    if build_config ~= "Debug" and build_config ~= "Release" then
                        build_config = "Debug"
                    end

                    -- Билдим проект
                    -- print(
                    --     "Building project "
                    --     .. project_name
                    --     .. " ["
                    --     .. build_config
                    --     .. "] for "
                    --     .. target_framework
                    --     .. "..."
                    -- )
                    local build_cmd = string.format("dotnet build %s -c %s", project_file, build_config)
                    local result = vim.fn.system(build_cmd)
                    -- print(result)

                    -- Путь к DLL
                    local output_dir = cwd .. "/bin/" .. build_config .. "/" .. target_framework .. "/"
                    local dll_path = output_dir .. project_name .. ".dll"

                    if vim.fn.filereadable(dll_path) == 0 then
                        error("DLL not found: " .. dll_path)
                    end

                    return dll_path
                end,
            },
        }
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
            layouts = {
                {
                    elements = {
                        {
                            id = "scopes",
                            size = 0.50,
                        },
                        {
                            id = "stacks",
                            size = 0.30,
                        },
                        {
                            id = "watches",
                            size = 0.10,
                        },
                        {
                            id = "breakpoints",
                            size = 0.10,
                        },
                    },
                    size = 40,
                    position = "right", -- Can be "left" or "right"
                },
                {
                    elements = {
                        {
                            id = "repl",
                            size = 0.20,
                        },
                        {
                            id = "console",
                            size = 0.80,
                        },
                    },
                    size = 20,
                    position = "bottom", -- Can be "bottom" or "top"
                },
            },
        })

        require("dap-python").setup()

        dap.configurations.java = {} -- ftplugin/java.lua will setup it. If you need custom settings, uncomment lines below

        -- dap.configurations.java = {
        -- {
        -- 	name = "Debug Launch (2GB)",
        -- 	type = "java",
        -- 	request = "launch",
        -- 	vmArgs = "" .. "-Xmx2g ",
        -- },
        -- {
        -- 	name = "Debug Attach (8000)",
        -- 	type = "java",
        -- 	request = "attach",
        -- 	hostName = "127.0.0.1",
        -- 	port = 8000,
        -- },
        -- {
        -- 	name = "Debug Attach (5005)",
        -- 	type = "java",
        -- 	request = "attach",
        -- 	hostName = "127.0.0.1",
        -- 	port = 5005,
        -- },
        -- {
        -- 	name = "My Custom Java Run Configuration",
        -- 	type = "java",
        -- 	request = "launch",
        -- 	-- You need to extend the classPath to list your dependencies.
        -- 	-- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
        -- 	-- classPaths = {},
        --
        -- 	-- If using multi-module projects, remove otherwise.
        -- 	-- projectName = "yourProjectName",
        --
        -- 	-- javaExec = "java",
        -- 	-- mainClass = "replace.with.your.fully.qualified.MainClass",
        -- 	mainClass = "com.bot.Main",
        --
        -- 	-- If using the JDK9+ module system, this needs to be extended
        -- 	-- `nvim-jdtls` would automatically populate this property
        -- 	-- modulePaths = {},
        -- 	vmArgs = "" .. "-Xmx2g ",
        -- },
        -- }
    end,
}
