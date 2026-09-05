return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.icons").setup()
      require("mini.notify").setup()

      require("mini.ai").setup()
      require("mini.align").setup()
      require("mini.comment").setup()
      require("mini.completion").setup()
      require("mini.keymap").setup()
      require("mini.move").setup()
      require("mini.operators").setup()
      require("mini.pairs").setup()
      require("mini.snippets").setup()
      require("mini.splitjoin").setup()
      require("mini.surround").setup()

      require("mini.basics").setup()
      require("mini.bracketed").setup()
      vim.keymap.set("n", "<C-Tab>", "<Cmd>lua MiniBracketed.buffer('forward')<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-Tab>", "<Cmd>lua MiniBracketed.buffer('backward')<CR>", { desc = "Previous buffer" })
      require("mini.bufremove").setup()
      require("mini.clue").setup()
      require("mini.cmdline").setup()
      require("mini.diff").setup()
      require("mini.extra").setup()
      require("mini.files").setup({ options = { use_as_default_explorer = false } })
      require("mini.git").setup()
      require("mini.input").setup()
      require("mini.jump").setup()
      require("mini.jump2d").setup()
      require("mini.misc").setup()
      require("mini.pick").setup()
      require("mini.sessions").setup()
      require("mini.visits").setup()

      require("mini.animate").setup()
      require("mini.base16").setup({
        palette = {
          base00 = "#282828",
          base01 = "#3c3836",
          base02 = "#504945",
          base03 = "#665c54",
          base04 = "#bdae93",
          base05 = "#d5c4a1",
          base06 = "#ebdbb2",
          base07 = "#fbf1c7",
          base08 = "#fb4934",
          base09 = "#fe8019",
          base0A = "#fabd2f",
          base0B = "#b8bb26",
          base0C = "#8ec07c",
          base0D = "#83a598",
          base0E = "#d3869b",
          base0F = "#d65d0e",
        },
      })
      require("mini.colors").setup()
      require("mini.cursorword").setup()
      require("mini.hipatterns").setup()
      require("mini.hues").setup({
        background = "#002734",
        foreground = "#c0c8cc",
        autoadjust = false,
      })
      require("mini.indentscope").setup()
      require("mini.map").setup()
      require("mini.starter").setup()
      require("mini.statusline").setup()
      require("mini.tabline").setup()
      require("mini.trailspace").setup()

      require("mini.doc").setup()
      require("mini.fuzzy").setup()
      require("mini.test").setup()
    end,
  },
}
