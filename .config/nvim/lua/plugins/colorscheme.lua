return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1,
    config = function()
      require("gruvbox").setup({
        overrides = {
          FloatBorder = { fg = "#928374", bg = "#3c3836" },
          FloatTitle = { fg = "#ebdbb2", bg = "#3c3836" },
          FloatFooter = { fg = "#928374", bg = "#3c3836" },
          MsgSeparator = { fg = "#ebdbb2", bg = "#504945" },
        },
      })
      vim.o.background = "dark"
      vim.cmd.colorscheme("gruvbox")

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          pcall(require("mini.statusline").setup)
        end,
      })
    end,
  },
}
