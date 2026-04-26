local surveil = require 'surveil'

vim.api.nvim_create_user_command("SurveilUpdate",
  function(args)
    surveil.updateCards(args.args[1] or false)
  end,
  { nargs = "?" }
)

vim.api.nvim_create_user_command("SurveilPicker",
  function()
    surveil.picker()
  end,
  {}
)

vim.api.nvim_create_user_command("SurveilClear",
  function()
    surveil.unloadCards()
  end,
  {}
)

vim.keymap.set('n', '<leader>su', [[<cmd>SurveilPicker<CR>]])
vim.keymap.set('n', '<leader>sc', [[<cmd>SurveilClear<CR>]])

return surveil
