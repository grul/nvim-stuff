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

-- Open a TODO file in the cwd (matches todo/TODO/etc. case-insensitively,
-- any extension). Does nothing if none exists.
vim.keymap.set("n", "<leader>t", function()
    local dir = vim.fn.getcwd()
    for name, type in vim.fs.dir(dir) do
        if type == "file" and name:gsub("%.[^.]+$", ""):lower() == "todo" then
            vim.cmd.edit(vim.fs.joinpath(dir, name))
            return
        end
    end
    vim.notify("No TODO file found in " .. dir, vim.log.levels.WARN)
end, { desc = "Open TODO file (if one exists)" })

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
    require("plugins.colorscheme"),
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local builtin = require("telescope.builtin")

            -- Switch between find_files and live_grep, keeping the typed text
            local function switch_to(picker)
                return function(prompt_bufnr)
                    local text = action_state.get_current_line()
                    actions.close(prompt_bufnr)
                    picker({ default_text = text })
                end
            end

            local switch_mappings = {
                ["<C-g>"] = switch_to(builtin.live_grep),
                ["<C-f>"] = switch_to(builtin.find_files),
            }

            require("telescope").setup({
                defaults = {
                    layout_config = {
                        width = 0.999999, -- 1.0 will be interpreted as number of columns. 0.9999 = percentage
                        height = 0.999999,
                    },
                    mappings = {
                        i = switch_mappings,
                        n = switch_mappings,
                    },
                },
            })

            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
            vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Find references (LSP)" })
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
            vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>")
        end,
    },

    -- Update imports when files are renamed/moved/deleted in nvim-tree.
    -- Hooks nvim-tree's file events into the LSP's workspace/willRenameFiles
    -- request, which ts_ls uses to rewrite import paths project-wide.
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-tree.lua",
        },
        config = function()
            require("lsp-file-operations").setup()
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

    -- Auto-install non-LSP tools (formatters/linters). mason-lspconfig only
    -- handles LSP servers, so formatters like oxfmt need this to be installed.
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = { "oxfmt" },
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

            -- Disable autocompletion in markdown files
            cmp.setup.filetype("markdown", {
                enabled = false,
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
            -- Auto-pick a formatter based on which config file is present in
            -- the project. Each entry's built-in `condition` walks upward from
            -- the buffer looking for its config; `stop_after_first` runs only
            -- the first match. Prettier has no condition, so it's the fallback.
            local chain = { "biome", "dprint", "oxfmt", "prettier", stop_after_first = true }

            require("conform").setup({
                formatters_by_ft = {
                    javascript      = chain,
                    typescript      = chain,
                    javascriptreact = chain,
                    typescriptreact = chain,
                    json            = chain,
                    jsonc           = chain,
                    html            = chain,
                    css             = chain,
                    markdown        = chain,
                },
                formatters = {
                    -- oxfmt isn't built into conform yet; defined here so it
                    -- only fires when an oxc config exists upward from the buffer.
                    oxfmt = {
                        command = "oxfmt",
                        stdin = true,
                        condition = function(_, ctx)
                            return vim.fs.find({ ".oxlintrc.json", "oxfmt.json" }, {
                                path = ctx.filename,
                                upward = true,
                            })[1] ~= nil
                        end,
                    },
                },
                -- format_on_save = {
                --     timeout_ms = 2000,
                --     lsp_format = "fallback",
                -- },
            })
        end,
    },

    -- Git signs in the gutter + hunk actions
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = require("gitsigns")
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                    end

                    map("n", "<leader>gj", function() gs.nav_hunk("next") end, "Next hunk")
                    map("n", "<leader>gk", function() gs.nav_hunk("prev") end, "Previous hunk")
                    map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                    map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
                    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
                    map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
                    map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
                end,
            })
        end,
    },

    -- Full-file / project-wide diff view
    -- Usage:
    -- :DiffviewOpen [rev_range] (e.g. HEAD~1..HEAD)
    -- :DiffviewOpen commit_hash^! (to see changes in a single commit)
    -- Use <leader>gh to browse history and <Enter> on a commit to see its changes.
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Open diff view" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>",         desc = "Close diff view" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>",   desc = "Project history" },
            { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
            {
                "<leader>gc",
                function()
                    vim.ui.input({ prompt = "Diff commits (e.g. HEAD~1..HEAD or commit_hash): " }, function(input)
                        if input and input ~= "" then
                            vim.cmd("DiffviewOpen " .. input)
                        end
                    end)
                end,
                desc = "Diff specific commits",
            },
        },
    },

    -- Animated cursor trail / smear effect
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = function()
            -- Read current Normal bg so the smear "shadow" blends with the theme
            local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
            local bg = normal.bg and string.format("#%06x", normal.bg) or "#000000"

            return {
                -- Make the smear shadow match the editor bg (Windows Terminal can't
                transparent_bg_fallback_color = bg,

                legacy_computing_symbols_support = false,
                cursor_color = "#d3cdc3",   -- explicit color avoids OSC misdetection
                smear_horizontally = false, -- only smear on vertical/scroll motion

                -- Motion feel
                stiffness = 0.6,             -- head speed (0 = floppy, 1 = snappy)
                trailing_stiffness = 0.25,   -- lower = tail lingers longer at origin
                -- trailing_exponent = 3,               -- higher = tail hangs before whipping forward
                distance_stop_animating = 3, -- end animation early to avoid jitter
            }
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
local capabilities = vim.tbl_deep_extend(
    "force",
    require("cmp_nvim_lsp").default_capabilities(),
    require("lsp-file-operations").default_capabilities()
)

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
        vim.keymap.set("n", "gd", require("telescope.builtin").lsp_definitions, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
})

-- In the quickfix list (e.g. gd with multiple results), pressing <CR> jumps to
-- the entry AND closes the quickfix window.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        vim.keymap.set("n", "<CR>", "<CR><cmd>cclose<cr>", { buffer = args.buf, silent = true })
    end,
})

-- Markdown checkbox toggling (markdown buffers only).
require("markdown_checkbox").setup({ key = "<C-l>" })
