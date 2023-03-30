local M = {}

local function is_supported()
    -- only support fcitx5
    local exist = vim.fn.executable("fcitx5-remote")
    if vim.fn.executable("fcitx5-remote") ~= 1 then return false end

    local im = vim.fn.system("fcitx5-remote -n"):sub(1, -2)
    if im ~= "rime" then return false end

    return true
end

local function is_asciimode()
    local cmd =
        "/usr/bin/qdbus org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1.IsAsciiMode"
    local res = vim.fn.system(cmd):sub(1, -2)
    return res == "true"
end

function M.setup()
    if not is_supported() then return end

    vim.api.nvim_create_autocmd({"InsertLeave", "CmdlineLeave", "VimEnter"}, {
        callback = function()
            local t = is_asciimode()
            if not is_asciimode() then
                local cmd =
                    "/usr/bin/qdbus org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1.SetAsciiMode 1"
                local res = vim.fn.system(cmd)
            end
        end
    })

end

M.setup()

return M
