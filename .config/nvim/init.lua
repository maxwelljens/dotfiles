-- Włączenie integracji z systemowym schowkiem
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- Definicja niestandardowego dostawcy schowka dla DMS (Dank Linux)
vim.g.clipboard = {
  name = "dms-clipboard",
  copy = {
    ["+"] = { "dms", "cl", "copy" },
    ["*"] = { "dms", "cl", "copy" },
  },
  paste = {
    ["+"] = { "dms", "cl", "paste" },
    ["*"] = { "dms", "cl", "paste" },
  },
  cache_enabled = 0,
}

-- Ustawienie języków
vim.opt.spell = true
vim.opt.spelllang = { "en_gb", "pl" }

-- lazy.nvim
require("config.lazy")
