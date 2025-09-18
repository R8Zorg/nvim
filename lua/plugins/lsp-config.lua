-- LSP Support
return {
    -- LSP Configuration
    -- https://github.com/neovim/nvim-lspconfig
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        -- LSP Management
        -- https://github.com/williamboman/mason.nvim
        { "williamboman/mason.nvim" },
        -- https://github.com/williamboman/mason-lspconfig.nvim
        { "williamboman/mason-lspconfig.nvim" },

        -- Auto-Install LSPs, linters, formatters, debuggers
        -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
        { "WhoIsSethDaniel/mason-tool-installer.nvim" },

        -- Useful status updates for LSP
        -- https://github.com/j-hui/fidget.nvim
        { "j-hui/fidget.nvim",                        opts = {} },

        -- Additional lua configuration, makes nvim stuff amazing!
        -- https://github.com/folke/neodev.nvim
        { "folke/neodev.nvim",                        opts = {} },
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
            -- Create a function that lets us more easily define mappings specific LSP related items.
            -- It sets the mode, buffer and description for us each time.
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end
                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-T>.
                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                --  For example, in C this would take you to the header
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to seeAG
                --  the definition of its *type*, not where it was *defined*.
                map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                -- Find references for the word under your cursor.
                map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                -- Rename the variable under your cursor
                --  Most Language Servers support renaming across files, etc.
                map("rr", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

                -- Fuzzy find all the symbols in your current workspace
                --  Similar to document symbols, except searches over your whole project.
                map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

                -- Opens a popup that displays documentation about the word under your cursor
                --  See `:help K` for why this keymap
                map("K", vim.lsp.buf.hover, "Hover Documentation")

                map("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
                map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
                map("<leader>wl", function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, "[W]orkspace [L]ist Folders")

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end,
        })
        require("mason").setup()
        require("mason-lspconfig").setup({
            automatic_enable = false,
            -- Install these LSPs automatically
            ensure_installed = {
                "pylsp",
                "bashls",
                "cssls",
                "html",
                "gradle_ls",
                -- "groovyls",
                "lua_ls",
                "jdtls",
                "jsonls",
                "lemminx",
                "marksman",
                "quick_lint_js",
                "yamlls",
                "omnisharp",
            },
        })

        require("mason-tool-installer").setup({
            -- Install these linters, formatters, debuggers automatically
            ensure_installed = {
                "java-debug-adapter",
                "java-test",
                "stylua",
            },
        })

        -- There is an issue with mason-tools-installer running with VeryLazy, since it triggers on VimEnter which has already occurred prior to this plugin loading so we need to call install explicitly
        -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim/issues/39
        vim.api.nvim_command("MasonToolsInstall")

        local lspconfig = require("lspconfig")
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        local lsp_attach = function(client, bufnr)
            -- Create your keybindings here...
        end

        -- Call setup on each LSP server
        -- require("mason-lspconfig").setup({
        --     function(server_name)
        --         -- Don't call setup for JDTLS Java LSP because it will be setup from a separate config
        --         if server_name ~= "jdtls" then
        --             lspconfig[server_name].setup({
        --                 on_attach = lsp_attach,
        --                 capabilities = lsp_capabilities,
        --             })
        --         end
        --     end,
        -- })
        require("mason-lspconfig").setup({
            function(server_name)
                if server_name == "jdtls" then
                    return -- jdtls у тебя отдельно
                end
                if server_name == "omnisharp" then
                    lspconfig.omnisharp.setup({
                        cmd = { vim.fn.stdpath("data") .. "/mason/bin/OmniSharp" },
                        handlers = { ["textDocument/definition"] = require("omnisharp_extended").handler },
                        capabilities = lsp_capabilities,
                        enable_roslyn_analyzers = true,
                        enable_import_completion = true,
                        organize_imports_on_format = true,
                        enable_decompilation_support = true,
                        filetypes = { "cs", "vb" },
                    })
                    return
                end
                lspconfig[server_name].setup({
                    on_attach = lsp_attach,
                    capabilities = lsp_capabilities,
                })
            end,
        })
        vim.lsp.enable("omnisharp")
        -- Lua LSP settings
        lspconfig.lua_ls.setup({
            settings = {
                Lua = {
                    diagnostics = {
                        -- Get the language server to recognize the `vim` global
                        globals = { "vim" },
                    },
                },
            },
        })

        lspconfig.pylsp.setup({
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = {
                            ignore = { "E203" },
                            maxLineLength = 88,
                        },
                        autopep8 = { enabled = false },
                        yapf = { enabled = false },
                    },
                },
            },
        })

        -- Globally configure all LSP floating preview popups (like hover, signature help, etc)
        local open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or "rounded" -- Set border to rounded
            return open_floating_preview(contents, syntax, opts, ...)
        end
    end,
}
