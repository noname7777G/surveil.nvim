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
---@field public windowParts table
---@field opts table
---@field private selectedCard card
local searchMenu = {}

searchMenu.windowParts = {
  verticalBar = "│",
  horizontalBar = "─",
  noBar = " ",
  leftTee = "├",
  topTee = "┬",
  bottomTee = "┴",
  rightTee = "┤",
  bottomLeft = "╰",
  bottomRight = "╯",
  topLeft = "╭",
  topRight = "╮",
}

searchMenu.querySession = require 'query'

searchMenu.opts = {}
searchMenu.cardNames = {}

function searchMenu.moveCursorUp()
  local pos = vim.api.nvim_win_get_cursor(0)
  if pos[1] == 1 then
    vim.api.nvim_set_current_win(searchMenu.searchWindow)
  else
    pos[1] = pos[1] - 1
    vim.api.nvim_win_set_cursor(0, pos)
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local rowCard

  if searchMenu.currentResults then
    rowCard = searchMenu.currentResults[row]
  end

  searchMenu.selectedCard = rowCard
  searchMenu:displayHighlightedCard()
end

function searchMenu.moveCursorDown()
  local pos = vim.api.nvim_win_get_cursor(0)
  local winBottom = vim.api.nvim_buf_line_count(0)
  if pos[1] < winBottom then
    pos[1] = pos[1] + 1
    vim.api.nvim_win_set_cursor(0, pos)
  end

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local rowCard

  if searchMenu.currentResults then
    rowCard = searchMenu.currentResults[row]
  end

  searchMenu.selectedCard = rowCard

  searchMenu:displayHighlightedCard()
end

---@param cards card[]
---@param actualWidth integer
searchMenu.generateResultsLines = function(cards, actualWidth)
  local oneThird = math.floor((actualWidth - 2) / 3)
  local oneSixth = math.max(math.floor((actualWidth - 2) / 6), 15)

  for i = 1, #searchMenu.cardNames do
    searchMenu.cardNames[i] = nil
  end

  for i = 1, #cards do
    local card = cards[i]

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
      typeLineLen = #typeLine
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

    searchMenu.cardNames[#searchMenu.cardNames + 1] = displayLine
  end
end

local function makeHighlightGroups()
  searchMenu.whiteMana = vim.fn.matchadd("WhiteMana", [[{\([Ww]\|\([Ww]/[Pp]\)\)}]], 10, -1,
    { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("WhiteMana", [[{[Ww]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("WhiteMana", [[{[Ww]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "WhiteMana", { bg = "#ffffea", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("BlueMana", [[{[Uu]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("BlueMana", [[{[Uu]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("BlueMana", [[{[Uu]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "BlueMana", { bg = "#a7e2f4", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("BlackMana", [[{[Bb]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("BlackMana", [[{[Bb]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("BlackMana", [[{[Bb]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "BlackMana", { bg = "#918c88", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("RedMana", [[{[Rr]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("RedMana", [[{[Rr]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("RedMana", [[{[Rr]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "RedMana", { bg = "#f8ac88", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("GreenMana", [[{[Gg]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("GreenMana", [[{[Gg]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("GreenMana", [[{[Gg]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "GreenMana", { bg = "#9bd5bd", fg = "Black" })

  searchMenu.whiteMana = vim.fn.matchadd("GenericMana", [[{\d*}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("GenericMana", [[{\d*}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("GenericMana", [[{\d*}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "GenericMana", { bg = "#d0c8c5", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("ColorlessMana", [[{[Cc]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("ColorlessMana", [[{[Cc]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("ColorlessMana", [[{[Cc]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "ColorlessMana", { bg = "#d0c8c5", fg = "Black" })
  searchMenu.whiteMana = vim.fn.matchadd("XMana", [[{[Xx]}]], 10, -1, { window = searchMenu.resultsWindow })
  searchMenu.whiteMana = vim.fn.matchadd("XMana", [[{[Xx]}]], 10, -1, { window = searchMenu.cardWindow })
  searchMenu.whiteMana = vim.fn.matchadd("XMana", [[{[Xx]}]], 10, -1, { window = searchMenu.searchWindow })
  vim.api.nvim_set_hl(0, "XMAna", { bg = "#d0c8c5", fg = "Black" })
end

function searchMenu:ShowMenu(target)
  local desiredHeight = 30
  local desiredWidth = 100

  local screenHeight = vim.go.lines
  local screenWidth = vim.go.columns

  local actualHeight = math.min(desiredHeight, screenHeight - 10)
  local actualWidth = math.min(desiredWidth, screenWidth - 10)
  local halfWidth = math.floor(actualWidth / 2)

  local windowTopLeftLine = math.floor(screenHeight / 2) - math.floor(actualHeight / 2)
  local windowTopLeftColumn = math.floor(screenWidth / 2) - math.floor(actualWidth / 2) - math.floor(halfWidth / 2)

  searchMenu.oldWindow = vim.api.nvim_win_get_buf(0)

  searchMenu.resultsWindow = popup.create(searchMenu.opts,
    {
      title = "Results",
      line = windowTopLeftLine + 3,
      col = windowTopLeftColumn,
      minwidth = actualWidth,
      minheight = actualHeight,
      borderchars = { searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.leftTee,
        searchMenu.windowParts.topTee,
        searchMenu.windowParts.bottomTee,
        searchMenu.windowParts.bottomLeft },
    }
  )

  searchMenu.cardWindow = popup.create(searchMenu.opts,
    {
      title = "Card",
      line = windowTopLeftLine + 3,
      col = windowTopLeftColumn + actualWidth + 2,
      minwidth = halfWidth,
      minheight = actualHeight,
      borderchars = { searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.noBar,
        searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.rightTee,
        searchMenu.windowParts.bottomRight,
        searchMenu.windowParts.horizontalBar },
    }
  )

  searchMenu.searchWindow = popup.create(searchMenu.opts,
    {
      title = "Surveil",
      line = windowTopLeftLine,
      col = windowTopLeftColumn,
      minwidth = actualWidth + halfWidth + 2,
      minheight = 1,
      borderchars = { searchMenu.windowParts.horizontalBar,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.noBar,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.topLeft,
        searchMenu.windowParts.topRight,
        searchMenu.windowParts.verticalBar,
        searchMenu.windowParts.verticalBar },
    }
  )

  makeHighlightGroups()

  searchMenu.resultWinBufnr = vim.api.nvim_win_get_buf(searchMenu.resultsWindow)
  searchMenu.cardWinBufnr = vim.api.nvim_win_get_buf(searchMenu.cardWindow)
  searchMenu.searchWinBufnr = vim.api.nvim_win_get_buf(searchMenu.searchWindow)
  searchMenu.querySession.setPrimaryTable(target)

  searchMenu.currentResults = target
  searchMenu.generateResultsLines(searchMenu.currentResults, actualWidth)

  vim.api.nvim_buf_set_lines(searchMenu.resultWinBufnr, 0, -1, false, searchMenu.cardNames)

  vim.api.nvim_buf_attach(searchMenu.searchWinBufnr, true, {
    on_lines = function(_, BufNum, _, firstLine, lastLine)
      local line = vim.api.nvim_buf_get_lines(BufNum, firstLine, lastLine, false)[1]

      searchMenu.currentResults = searchMenu.querySession.query(line) or {}

      searchMenu.generateResultsLines(searchMenu.currentResults, actualWidth)

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(searchMenu.resultWinBufnr, 0, -1, false, {})
        vim.api.nvim_buf_set_lines(searchMenu.resultWinBufnr, 0, -1, false, searchMenu.cardNames)
      end)
    end
  })

  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.searchWinBufnr })
  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.resultWinBufnr })
  vim.keymap.set('n', '<esc>', searchMenu.CloseMenu, { buffer = searchMenu.cardWinBufnr })

  vim.keymap.set('n', 'j', searchMenu.moveToResults, { buffer = searchMenu.searchWinBufnr })
  vim.keymap.set('n', 'k', searchMenu.moveCursorUp, { buffer = searchMenu.resultWinBufnr })
  vim.keymap.set('n', 'j', searchMenu.moveCursorDown, { buffer = searchMenu.resultWinBufnr })

  vim.keymap.set('n', '<leader>sp', function()
    vim.print(searchMenu.selectedCard)
  end, { buffer = searchMenu.resultWinBufnr })

  vim.wo[searchMenu.searchWindow].wrap = false
  vim.wo[searchMenu.resultsWindow].wrap = false
  vim.wo[searchMenu.cardWindow].wrap = true
  vim.wo[searchMenu.cardWindow].linebreak = true
end

function searchMenu.moveToResults()
  vim.api.nvim_set_current_win(searchMenu.resultsWindow)
  searchMenu.selectedCard = searchMenu.currentResults[1]
  searchMenu:displayHighlightedCard()
end

function searchMenu:displayHighlightedCard()
  if not searchMenu.selectedCard then return end

  vim.schedule(function()
    local display = {
      searchMenu.selectedCard.name,
      (searchMenu.selectedCard.mana_cost or ""),
      (searchMenu.selectedCard.type_line or ""),
    }

    if searchMenu.selectedCard.oracle_text then
      searchMenu.selectedCard.oracle_text:gsub("([^\n]*)\n*", function(s)
        table.insert(display, s)
      end)
    end

    local pt = nil
    if searchMenu.selectedCard.power and searchMenu.selectedCard.toughness then
      pt = "(" .. searchMenu.selectedCard.power .. "/" .. searchMenu.selectedCard.toughness .. ")"
    elseif searchMenu.selectedCard.loyalty then
      pt = "{" .. searchMenu.selectedCard.loyalty .. "}"
    elseif searchMenu.selectedCard.defense then
      pt = "[" .. searchMenu.selectedCard.defense .. "]"
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
