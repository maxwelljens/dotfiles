return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      picker = {
        enabled = true,
        layout = { preset = "default" },
        sources = {
          files = { hidden = true, ignored = true },
        },
      },
    },
    keys = {
      { "<leader>ff", function() require("snacks").picker.files() end, desc = "Find files" },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      require("config.directory-picker").setup()
    end,
  },
}
