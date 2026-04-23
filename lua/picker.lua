local popup = require 'plenary.popup'

---@class searchMenu
---@field private resultsWindow number?
---@field private resultWinBufnr number?
---@field private cardWindow number?
---@field private cardWinBufnr number? @field private searchWinBufnr number?
---@field private searchWindow number?
---@field private oldWindow number?
---@field private currentResults table?
---@field private DisplayResults function
---@field public ShowMenu function
---@field public CloseMenu function
---@field opts table
local searchMenu = {}

searchMenu.querySession = require 'query'

searchMenu.opts = {}

function searchMenu.moveCursorUp()
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] == 1 then
    vim.api.nvim_set_current_win(searchMenu.searchWindow)
  else
    pos[1] = pos[1] - 1
    vim.api.nvim_win_set_cursor(0, pos)
  end

  searchMenu:displayHighlightedCard()
end

function searchMenu.moveCursorDown()
  local pos = vim.api.nvim_win_get_cursor(0)
  local winBottom = vim.api.nvim_buf_line_count(0)
  if pos[1] < winBottom then
    pos[1] = pos[1] + 1
    vim.api.nvim_win_set_cursor(0, pos)
  end

  searchMenu:displayHighlightedCard()
end

function searchMenu:ShowMenu(target)
  local desiredHeight = 40
  local desiredWidth = 80

  local screenHeight = vim.go.lines
  local screenWidth = vim.go.columns

  local actualHeight
  if desiredHeight > screenHeight - 10 then
    actualHeight = screenHeight - 10
  else
    actualHeight = desiredHeight
  end

  local actualWidth
  if desiredWidth > screenWidth - 10 then
    actualWidth = screenWidth - 10
  else
    actualWidth = desiredWidth
  end

  local topLeftLine = math.floor((screenHeight - actualHeight) / 2)
  local topLeftColumn = math.floor((screenWidth - actualWidth) / 3)

  searchMenu.oldWindow = vim.api.nvim_win_get_buf(0)

  searchMenu.resultsWindow = popup.create(searchMenu.opts,
    {
      title = "Results",
      line = topLeftLine - 1,
      col = topLeftColumn,
      minwidth = actualWidth,
      minheight = actualHeight,
      borderchars = { "─", "│", "─", "│", "├", "┬	", "┴", "╰" },
    })

  searchMenu.cardWindow = popup.create(searchMenu.opts,
    {
      title = "Card",
      line = topLeftLine - 1,
      col = topLeftColumn + actualWidth + 2,
      minwidth = actualWidth,
      minheight = actualHeight,
      borderchars = { "─", "│", "─", " ", "─", "┤", "╯", "─" },
    })

  searchMenu.searchWindow = popup.create(searchMenu.opts,
    {
      title = "Surveil",
      line = topLeftLine - 4,
      col = topLeftColumn,
      minwidth = (actualWidth * 2) + 2,
      minheight = 1,
      borderchars = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
    })

  searchMenu.resultWinBufnr = vim.api.nvim_win_get_buf(searchMenu.resultsWindow)
  searchMenu.cardWinBufnr = vim.api.nvim_win_get_buf(searchMenu.cardWindow)
  searchMenu.searchWinBufnr = vim.api.nvim_win_get_buf(searchMenu.searchWindow)
  searchMenu.querySession.setPrimaryTable(target)

  vim.api.nvim_buf_attach(searchMenu.searchWinBufnr, true, {
    on_lines = function(_, BufNum, _, firstLine, lastLine)
      local line = vim.api.nvim_buf_get_lines(BufNum, firstLine, lastLine, false)[1]

      searchMenu.currentResults = searchMenu.querySession.query(line) or {}

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(searchMenu.resultWinBufnr, 0, -1, false, {})
      end)

      local cardNames = {}
      for _, card in pairs(searchMenu.currentResults) do
        table.insert(cardNames, card.name .. " | " .. (card.type_line or "") .. " | " .. (card.mana_cost or ""))
      end

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(searchMenu.resultWinBufnr, 0, -1, false, cardNames)
      end)
    end
  })

  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.searchWinBufnr })
  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.resultWinBufnr })
  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.cardWinBufnr })

  vim.keymap.set('n', 'j', searchMenu.moveToResults, { buffer = searchMenu.searchWinBufnr })
  vim.keymap.set('n', 'k', searchMenu.moveCursorUp, { buffer = searchMenu.resultWinBufnr })
  vim.keymap.set('n', 'j', searchMenu.moveCursorDown, { buffer = searchMenu.resultWinBufnr })

  vim.wo[searchMenu.searchWindow].wrap = false
  vim.wo[searchMenu.resultsWindow].wrap = false
  vim.wo[searchMenu.cardWindow].wrap = true
  vim.wo[searchMenu.cardWindow].linebreak = true
end

function searchMenu.moveToResults()
  vim.api.nvim_set_current_win(searchMenu.resultsWindow)
  searchMenu:displayHighlightedCard()
end

function searchMenu:displayHighlightedCard()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local rowCard

  rowCard = searchMenu.currentResults[row]

  if not rowCard then return end

  vim.schedule(function()
    local display = {
      rowCard.name,
      (rowCard.mana_cost or ""),
      (rowCard.type_line or ""),
    }

    if rowCard.oracle_text then
      rowCard.oracle_text:gsub("([^\n]*)\n*", function(s)
        table.insert(display, s)
      end)
    end

    vim.api.nvim_buf_set_lines(searchMenu.cardWinBufnr, 0, -1, false, display)
  end)
end

function searchMenu.CloseMenu()
  vim.api.nvim_win_close(searchMenu.resultsWindow, true)
  vim.api.nvim_win_close(searchMenu.cardWindow, true)
  vim.api.nvim_win_close(searchMenu.searchWindow, true)
end

return searchMenu
