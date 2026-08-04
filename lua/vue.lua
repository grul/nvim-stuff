-- All Vue-specific LSP wiring lives here. To disable Vue support entirely,
-- comment out the require("vue").setup(...) line in init.lua.
--
-- Uses Vetur (vls) rather than the modern vue_ls: the Vue code that matters
-- here is Vue 2.6 on TypeScript 3.7, which Vue Language Tools 3.x no longer
-- supports (and its @vue/typescript-plugin crashes old workspace tsservers).
-- Vetur is a standalone server from the Vue 2 era, so ts_ls stays untouched.
-- If a Vue 3 project ever becomes relevant, swap this for vue_ls + the
-- @vue/typescript-plugin setup described in nvim-lspconfig's vue_ls docs.
local M = {}

function M.setup(capabilities)
    -- Start treesitter highlighting for vue buffers (the built-in regex
    -- syntax for vue is rudimentary). pcall: silently does nothing if the
    -- vue parser isn't installed yet.
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "vue",
        callback = function()
            pcall(vim.treesitter.start)
        end,
    })

    -- Defined fully by hand: nvim-lspconfig no longer ships a vuels preset.
    -- Vetur expects its whole settings tree in init_options.config (VS Code
    -- normally provides this); without it, it silently does nothing.
    vim.lsp.config("vuels", {
        cmd = { "vls" },
        filetypes = { "vue" },
        root_markers = { "vue.config.js", "package.json" },
        capabilities = capabilities,
        init_options = {
            config = {
                vetur = {
                    -- Use Vetur's bundled TypeScript instead of the (ancient)
                    -- workspace one.
                    useWorkspaceDependencies = false,
                    completion = {
                        autoImport = true,
                        tagCasing = "kebab",
                        useScaffoldSnippets = false,
                    },
                    validation = {
                        script = true,
                        style = true,
                        template = true,
                    },
                    format = {
                        defaultFormatter = { js = "none", ts = "none" },
                        defaultFormatterOptions = {},
                        scriptInitialIndent = false,
                        styleInitialIndent = false,
                    },
                },
            },
        },
    })
    vim.lsp.enable("vuels")
end

return M
