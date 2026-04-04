local surveil = require 'surveil'

vim.keymap.set('n', '<leader>su', [[<cmd>lua require('surveil').picker()<CR>]])
vim.keymap.set('n', '<leader>sc', [[<cmd>lua require('surveil').unloadCards()<CR>]])

return surveil
