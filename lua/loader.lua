local opts = require 'opts'
local Set = require 'Set'
local cardLists = require 'cardLists'
local query = require 'query'

local loader = {}

local evaluatePT = function(value)
  local try = tonumber(value or 0)

  if try then
    return try
  elseif type(value) == "string" then
    local repl = value:gsub("[^%d+-]", "0")
    return vim.fn.eval(repl)
  else
    return 0
  end
end

local stripData = function(rawJsonObj)
  local oracleObjects = {}
  ---@cast oracleObjects card[]

  for _, card in ipairs(rawJsonObj) do
    --if card.layout == "reversible_card" then goto continue end -- This is a temp solution, I want these printings included in the "in" and "artist" fields.

    local oracleObject = oracleObjects[card.oracle_id or card.card_faces[1].oracle_id]

    if oracleObject then
      if card.games then
        for _, game in ipairs(card.games) do
          oracleObject.availabilities[game] = true
        end
      end

      if card.oracle_text and oracleObject.oracle_text and #card.oracle_text > #oracleObject.oracle_text then --ensure we have the most reminder text
        oracleObject.oracle_text = card.oracle_text
      end

      oracleObject.sets[#oracleObject.sets + 1] = card.set
    else
      card.arena_id = nil
      card.id = nil
      card.lang = nil
      card.mtgo_id = nil
      card.mtgo_foil_id = nil
      card.multiverse_ids = nil
      card.resource_id = nil
      card.tcgplayer_id = nil        -- To remain nil until they stop union busting
      card.tcgplayer_etched_id = nil -- To remain nil until they stop union busting
      card.cardmarket_id = nil
      card.object = nil
      card.scryfall_uri = nil
      card.uri = nil

      card.artist = nil
      card.artist_ids = nil
      card.booster = nil
      card.border_color = nil
      card.card_back_id = nil
      card.collector_number = nil
      card.digital = nil
      card.finishes = nil
      card.flavor_text = nil
      card.frame_effects = nil
      card.frame = nil
      card.full_art = nil

      card.availabilities = {}
      for _, game in ipairs(card.games) do
        card.availabilities[game] = true
      end
      card.games = nil

      card.highres_image = nil
      card.illustration_id = nil
      card.image_status = nil
      card.image_uris = nil
      card.oversized = nil
      card.prices = nil
      card.printed_name = nil
      card.printed_text = nil
      card.printed_type_line = nil
      card.promo = nil
      card.promo_types = nil
      card.purchase_uris = nil
      card.rarity = nil
      card.related_uris = nil
      card.released_at = nil
      card.reprint = nil
      card.scryfall_set_uri = nil
      card.set_name = nil
      card.search_uri = nil
      card.set_type = nil
      card.set_uri = nil

      card.sets = {}
      card.sets[1] = card.set
      card.set = nil

      card.set_id = nil
      card.story_spotlight = nil
      card.textless = nil
      card.variation = nil
      card.variation_of = nil
      card.security_stamp = nil
      card.watermark = nil
      card.preview = nil

      card.foil = nil
      card.nonfoil = nil

      if card.card_faces then
        for _, face in ipairs(card.card_faces) do
          face.artist = nil
          face.artist_id = nil
          face.flavor_text = nil
          face.illustration_id = nil
          face.image_uris = nil
          face.printed_name = nil
          face.printed_text = nil
          face.printed_type_line = nil
          face.watermark = nil

          if face.power then
            face.evaluatedPower = evaluatePT(face.power)
          end
          if face.toughness then
            face.evaluatedToughness = evaluatePT(face.toughness)
          end
          if face.loyalty then
            face.evaluatedLoyalty = evaluatePT(face.loyalty)
          end
          if face.defense then
            face.evaluatedDefense = evaluatePT(face.defense)
          end

          face.nameNoEpithet = face.name:match("^([^,]+),")
        end
      end

      ---@cast card card

      if card.power then
        card.evaluatedPower = evaluatePT(card.power)
      end
      if card.toughness then
        card.evaluatedToughness = evaluatePT(card.toughness)
      end
      if card.loyalty then
        card.evaluatedLoyalty = evaluatePT(card.loyalty)
      end
      if card.defense then
        card.evaluatedDefense = evaluatePT(card.defense)
      end

      if card.type_line then
        card.type_line = card.type_line:gsub("\226\128\148", "-")
      end

      card.nameNoEpithet = card.name:match("^([^,]+),")

      oracleObjects[card.oracle_id or card.card_faces[1].oracle_id] = card
    end
    ::continue::
  end

  local orderedList = {}
  for _, card in pairs(oracleObjects) do
    table.insert(orderedList, card)
  end

  --vim.print(longestCardName .. " is " .. nameMaxLen .. " characters long.")
  --vim.print("The type line of " .. longestTypeLineCardName .. " is " .. typeLineMaxLen .. " characters long.")
  --vim.print(manaCostMaxLen)

  return orderedList
end

loader.updateCards = function(skipDownload)
  if skipDownload ~= "skipDownload" then
    local tempFileName = os.tmpname()

    local ok, str, code = os.execute("curl https://api.scryfall.com/bulk-data/default-cards" ..
      opts.curlArgs .. "> " .. tempFileName)

    if not ok then
      print(str .. code)
      return
    end

    local tempFile = io.open(tempFileName)
    if tempFile == nil then
      print "Issue opening temp file"
      return
    end
    local json = tempFile:read()

    local jsonObj = vim.json.decode(json, { object = true, array = true })
    os.execute("curl " .. jsonObj.download_uri .. opts.curlArgs .. "-o " .. opts.cacheDir .. "/raw_bulk.json")
  end

  local rawBulkFile = io.open(opts.cacheDir .. "/raw_bulk.json", "r")
  if not rawBulkFile then
    print "Issue opening raw bulk data."
    return
  end

  local rawJson = rawBulkFile:read("a")
  local rawJsonObj = vim.json.decode(rawJson, { object = true, array = true })

  local oracleObjects = stripData(rawJsonObj)
  local oracleObjectsJson = vim.json.encode(oracleObjects)

  local bulkFile = io.open(opts.bulkDataPath, "w+")
  if not bulkFile then
    print "Issue opening bulk data file."
    return
  end

  bulkFile:write(oracleObjectsJson)
  io.close(bulkFile)
end

local sortList = function(list, field)
  if field == "edhrec_rank" then
    table.sort(list, function(a, b)
      local aV = a["edhrec_rank"] or 9999999
      if aV == 0 then
        aV = 9999999
      end

      local bV = b[field] or 9999999
      if bV == 0 then
        bV = 9999999
      end

      return aV < bV
    end)
  end
end

loader.loadCards = function()
  local bulkDataFile = io.open(opts.bulkDataPath)

  if bulkDataFile then
    local bulkDataJson = bulkDataFile:read("a")
    cardLists.allCards = vim.json.decode(bulkDataJson, { object = true, array = true })
  else
    vim.ui.input({
      prompt = "No card data found, would you like to download card data? [y/N]:",
      default = "n",
    }, function(input)
      if input == "y" or input == "Y" then
        loader.updateCards()

        bulkDataFile = io.open(opts.bulkDataPath)

        if bulkDataFile then
          local bulkDataJson = bulkDataFile:read("a")
          cardLists.allCards = vim.json.decode(bulkDataJson, { object = true, array = true })
        else
          vim.print("Error loading bulk data.")
        end
      end
    end)
  end

  if opts.sortPredicate then
    sortList(cardLists.allCards, opts.sortPredicate)
  end

  for _, v in pairs(cardLists.allCards) do
    ---@cast v card
    v.colors = Set(v.colors or {})
    v.color_identity = Set(v.color_identity or {})
    v.color_indicator = Set(v.color_indicator or {})
    v.produced_mana = Set(v.produced_mana or {})
  end

  if opts.defaultQuery then
    cardLists.trimmedCards = query.query(opts.defaultQuery)
  end
end

return loader
