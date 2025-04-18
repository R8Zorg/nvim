return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        vim.keymap.set("n", "<C-n>", ":Neotree filesystem toggle left<CR>", {})
        vim.keymap.set("n", "<C-g>", ":Neotree float git_status<CR>", {})

        require("neo-tree").setup({
            filesystem = {
                filtered_items = {
                    visible = true,
                    --hide_dotfiles = false,
                },
            },
        })
    end,
}
