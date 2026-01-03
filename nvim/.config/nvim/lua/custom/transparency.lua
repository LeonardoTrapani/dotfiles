-- transparent background - applies on every colorscheme change
local M = {}

local function apply()
  local groups = {
    "Normal", "NormalFloat", "FloatBorder", "Pmenu", "Terminal",
    "EndOfBuffer", "FoldColumn", "Folded", "SignColumn", "NormalNC",
    "WhichKeyFloat", "TelescopeBorder", "TelescopeNormal",
    "TelescopePromptBorder", "TelescopePromptTitle",
    -- neotree
    "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeVertSplit",
    "NeoTreeWinSeparator", "NeoTreeEndOfBuffer",
    -- nvim-tree
    "NvimTreeNormal", "NvimTreeVertSplit", "NvimTreeEndOfBuffer",
    -- notify
    "NotifyINFOBody", "NotifyERRORBody", "NotifyWARNBody",
    "NotifyTRACEBody", "NotifyDEBUGBody", "NotifyINFOTitle",
    "NotifyERRORTitle", "NotifyWARNTitle", "NotifyTRACETitle",
    "NotifyDEBUGTitle", "NotifyINFOBorder", "NotifyERRORBorder",
    "NotifyWARNBorder", "NotifyTRACEBorder", "NotifyDEBUGBorder",
  }
  for _, g in ipairs(groups) do
    vim.api.nvim_set_hl(0, g, { bg = "none" })
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
  apply()
end

return M
