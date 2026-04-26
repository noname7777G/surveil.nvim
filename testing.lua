local surveil = require 'surveil'

local card_a = surveil.query([["birds of paradise"]], true)

vim.print(card_a)
