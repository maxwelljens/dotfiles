require("config.lazy")

-- Włączenie integracji z systemowym schowkiem
vim.opt.clipboard = "unnamedplus"

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
