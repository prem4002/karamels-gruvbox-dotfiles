local function set_transparent()
  local groups = {
    "Normal", "NormalNC", "NormalFloat",
    "SignColumn", "LineNr", "CursorLineNr",
    "FoldColumn", "EndOfBuffer",
    "TelescopeNormal", "TelescopeBorder",
    "TelescopePromptNormal", "TelescopePromptBorder",
    "NvimTreeNormal", "NvimTreeNormalNC",
    "NvimTreeNormalFloat", "NvimTreeEndOfBuffer",
    "NvimTreeWinSeparator", "NvimTreeCursorLine",
    "NvimTreeCursorColumn",
    "FloatBorder", "Pmenu",
    "StatusLine", "StatusLineNC",
    "TabLine", "TabLineFill",
  }
  for _, g in ipairs(groups) do
    vim.api.nvim_set_hl(0, g, { bg = "NONE", ctermbg = "NONE" })
  end
  -- set separately since it needs fg not bg
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#282828", bg = "NONE" })
end

vim.schedule(set_transparent)

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "NvimTree*",
  callback = set_transparent,
})