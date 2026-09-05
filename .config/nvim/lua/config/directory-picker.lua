local M = {}

function M.setup()
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  vim.api.nvim_create_autocmd("VimEnter", {
    nested = true,
    callback = function(args)
      local path = args.file ~= "" and args.file or vim.fn.argv(0)
      if path == "" or vim.fn.isdirectory(path) == 0 then
        return
      end

      path = vim.fs.normalize(path)
      vim.cmd.cd(path)

      vim.bo.bufhidden = "wipe"

      vim.schedule(function()
        require("snacks").picker.files({ cwd = path })
      end)
    end,
  })
end

return M
