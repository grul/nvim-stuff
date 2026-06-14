-- Toggle markdown checkboxes with a keybind.
--
--   "- [ ] todo"  <->  "- [x] todo"
--   "- todo"       ->  "- [ ] todo"   (plain bullet gains a checkbox)
--   "todo"         ->  "- [ ] todo"   (plain text becomes a checkbox item)

local M = {}

local function set_line(line)
    local old = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(line)
    -- Keep the cursor over the same content when length changes (e.g. a
    -- checkbox is inserted), so insert mode stays put instead of drifting.
    local delta = #line - #old
    if delta ~= 0 then
        local cursor = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, { cursor[1], math.max(cursor[2] + delta, 0) })
    end
end

function M.toggle()
    local line = vim.api.nvim_get_current_line()

    -- Checked checkbox -> uncheck it.
    if line:match("^(%s*[-*+]%s+)%[[xX]%]") then
        set_line((line:gsub("^(%s*[-*+]%s+)%[[xX]%]", "%1[ ]", 1)))
        return
    end

    -- Unchecked checkbox -> check it.
    if line:match("^(%s*[-*+]%s+)%[ %]") then
        set_line((line:gsub("^(%s*[-*+]%s+)%[ %]", "%1[x]", 1)))
        return
    end

    -- Plain bullet without a checkbox -> add an unchecked one.
    if line:match("^(%s*[-*+]%s+)") then
        set_line((line:gsub("^(%s*[-*+]%s+)", "%1[ ] ", 1)))
        return
    end

    -- Plain text -> turn it into an unchecked checkbox item.
    local indent, rest = line:match("^(%s*)(.*)$")
    set_line(indent .. "- [ ] " .. rest)
end

-- opts.key: the keybind to use (default "<C-l>").
function M.setup(opts)
    opts = opts or {}
    local key = opts.key or "<C-l>"
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
            vim.keymap.set({ "n", "i" }, key, M.toggle,
                { buffer = args.buf, silent = true, desc = "Toggle markdown checkbox" })
        end,
    })
end

return M
