-- ~/.config/nvim/init.lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.colorcolumn = "120"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 20

-- Keybindo
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Esc>:w<CR>", { desc = "Save file" })
-- vim.keymap.set("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer" })
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>")
vim.keymap.set("n", "<leader>s", ":wa<CR>", { desc = "Save all" })
vim.keymap.set("n", "<leader>q", ":wqa<CR>", { desc = "Save all and quit" })
vim.keymap.set("n", "<Esc>", ":noh<CR><Esc>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Close buffer" })

-- Go to next error (or next warning if no errors)
vim.keymap.set("n", "<F2>", function()
    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if #errors > 0 then
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    else
        vim.diagnostic.goto_next()
    end
end, { desc = "Next error (or warning if no errors)" })

-- Go to previous error (or previous warning if no errors)
vim.keymap.set("n", "<F14>", function()
    local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if #errors > 0 then
        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    else
        vim.diagnostic.goto_prev()
    end
end, { desc = "Previous error (or warning if no errors)" })

-- Plugin setup
require("lazy").setup({
    -- Gruvbox colorscheme
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
            -- vim.cmd([[colorscheme rose-pine]])
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
            vim.cmd([[colorscheme terafox]])
        end,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup()

            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
        end,
    },
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup()
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-tree").setup({
                actions = {
                    open_file = {
                        quit_on_open = true, }
                }
            })
            vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
        end,
    },
    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            vim.treesitter.language.add("rust")
            vim.treesitter.language.add("typescript")
            vim.treesitter.language.add("javascript")
            vim.treesitter.language.add("tsx")
            vim.treesitter.language.add("lua")
        end,
    },

    -- Mason for managing LSP servers
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer", "ts_ls", "lua_ls", "cssls" },
            })
        end,
    },

    -- Which-key for keybinding hints
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
        end,
    },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- CONFORM
    {
        "stevearc/conform.nvim",
        -- event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<M-F>",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "n",
                desc = "Format buffer",
            },
        },
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    javascript = { "dprint" },
                    typescript = { "dprint" },
                    html = { "dprint" },
                    css = { "dprint" },
                    javascriptreact = { "dprint" },
                    typescriptreact = { "dprint" },
                },
                -- format_on_save = {
                --     timeout_ms = 2000,
                --     lsp_format = "fallback",
                -- },
            })
        end,
    },

    -- TROUBLE
    {
        "folke/trouble.nvim",
        opts = {
            win = {
                size = 0.3
            }
        },
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    }
})

-- Disable italic and bold text globally (must be AFTER the require("lazy").setup() block)
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        local highlights = vim.api.nvim_get_hl(0, {})
        for group, attrs in pairs(highlights) do
            if attrs.italic or attrs.bold then
                local new_attrs = vim.deepcopy(attrs)
                new_attrs.italic = false
                new_attrs.bold = false
                vim.api.nvim_set_hl(0, group, new_attrs)
            end
        end
    end,
})

vim.schedule(function()
    local highlights = vim.api.nvim_get_hl(0, {})
    for group, attrs in pairs(highlights) do
        if attrs.bold then
            attrs.bold = false
            vim.api.nvim_set_hl(0, group, attrs)
        end
        if attrs.italic then
            attrs.italic = false
            vim.api.nvim_set_hl(0, group, attrs)
        end
    end
end)

-- LSP Configuration using vim.lsp.config (Neovim 0.11+)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Rust Analyzer
vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json" },
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
        },
    },
})

-- TypeScript Language Server
vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
    capabilities = capabilities,
})

-- Lua Language Server
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml" },
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
        },
    },
})

-- CSS Language Server
vim.lsp.config("cssls", {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    root_markers = { "package.json", ".git" },
    capabilities = capabilities,
})

-- Enable LSP servers
vim.lsp.enable({ "rust_analyzer", "ts_ls", "lua_ls", "cssls" })

-- LSP Keybindings
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})
