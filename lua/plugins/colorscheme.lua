return {
    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("gruvbox").setup({
                italic = {
                    strings = false,
                    comments = false,
                    operators = false,
                    folds = false,
                    emphasis = false,
                },
                overrides = {
                    Normal = { bg = "#080808" },
                    NormalFloat = { bg = "#080808" },
                },
            })
            -- vim.cmd([[colorscheme gruvbox]])
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd([[colorscheme kanagawa]])
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            -- rose-pine rose-pine-dawn rose-pine-moon (and -main but it's the same as rose-pine)
            vim.cmd([[colorscheme rose-pine-moon]])
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            -- vim.cmd([[colorscheme catppuccin-mocha]])
        end,
    },
    {
        "shaunsingh/nord.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd([[colorscheme nord]])
        end,
    },
    {
        "EdenEast/nightfox.nvim",
        priority = 1000,
        config = function()
            -- nightfox, dayfox, dawnfox, duskfox, nordfox, terafox, carbonfox
            -- vim.cmd([[colorscheme terafox]])
        end,
    },
}
