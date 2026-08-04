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
    -- syntax for vue is rudimentary).
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "vue",
        callback = function(args)
            local ok, err = pcall(vim.treesitter.start, args.buf)
            if ok then
                -- parse(true) parses the whole file including all injected
                -- languages (ts/html/css); otherwise injections are parsed
                -- lazily per visible region and highlighting can stop
                -- mid-file until the boundary is scrolled into view.
                vim.treesitter.get_parser(args.buf):parse(true)
            else
                -- e.g. parser missing/stale — run :TSInstall! vue
                vim.notify("vue treesitter highlight failed: " .. tostring(err), vim.log.levels.WARN)
            end
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
