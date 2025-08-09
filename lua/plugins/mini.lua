return {
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function()
            require("mini.pairs").setup({
                mappings = {
                    -- ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^\\]." },
                    -- [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },

                    -- ["/*"] = { action = "open", pair = "/**/", neigh_pattern = "[^\\]." },
                    -- ["*/"] = { action = "close", pair = "/**/", neigh_pattern = "[^\\]." },
                },
            })
            require("mini.move").setup({})
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
