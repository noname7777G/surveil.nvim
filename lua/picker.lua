local popup = require 'plenary.popup'

---@class searchMenu
---@field private resultsWindow number?
---@field private resultWinBufnr number?
---@field private cardWindow number?
---@field private cardWinBufnr number? @field private searchWinBufnr number?
---@field private searchWindow number?
---@field private oldWindow number?
---@field private currentResults card[]?
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
        local oneThird = math.floor((actualWidth - 2) / 3)
        local oneSixth = math.max(math.floor((actualWidth - 2) / 6), 15)

        local name = card.name:sub(1, oneThird)
        local nameLen = #vim.str_utf_pos(name)
        local nameBufferLen = oneThird - nameLen
        local nameBufferSpace = string.rep(" ", nameBufferLen)

        local manaCost = ""
        local manaCostLen = 0
        if card.mana_cost then
          manaCost = card.mana_cost:sub(1, oneSixth)
          manaCostLen = #vim.str_utf_pos(manaCost)
        end
        local manaCostBufferLen = oneSixth - manaCostLen
        local manaCostBufferSpace = string.rep(" ", manaCostBufferLen)

        local typeLine = ""
        local typeLineLen = 0
        if card.type_line then
          typeLine = card.type_line:sub(1, oneThird + (oneThird - oneSixth))
          typeLineLen = #vim.str_utf_pos(typeLine)
        end
        local typeBufferLen = (oneThird + (oneThird - oneSixth)) - typeLineLen
        local typeBufferSpace = string.rep(" ", typeBufferLen)


        local displayLine =
            name ..
            nameBufferSpace ..
            "|" ..
            typeLine ..
            typeBufferSpace ..
            "|" ..
            manaCostBufferSpace ..
            manaCost

        table.insert(cardNames, displayLine)
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

  if searchMenu.currentResults then
    rowCard = searchMenu.currentResults[row]
  else
    return
  end

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

    local pt = nil
    if rowCard.power and rowCard.toughness then
      pt = "(" .. rowCard.power .. "/" .. rowCard.toughness .. ")"
    elseif rowCard.loyalty then
      pt = "{" .. rowCard.loyalty .. "}"
    elseif rowCard.defense then
      pt = "[" .. rowCard.defense .. "]"
    end

    display[#display + 1] = pt

    vim.api.nvim_buf_set_lines(searchMenu.cardWinBufnr, 0, -1, false, display)
  end)
end

function searchMenu.CloseMenu()
  vim.api.nvim_win_close(searchMenu.resultsWindow, true)
  vim.api.nvim_win_close(searchMenu.cardWindow, true)
  vim.api.nvim_win_close(searchMenu.searchWindow, true)
end

return searchMenu
