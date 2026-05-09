local opts = require 'opts'
local Set = require 'Set'
local cardLists = require 'cardLists'
local query = require 'query'

local loader = {}

loader.evaluatePT = function(value)
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

loader.chars = {}

loader.addCharsToTable = function(str)
  local bytesRemaining = 0
  local inMultiByteChar = false
  for i = 1, #str, 1 do
    local byte = str:byte(i)

    if inMultiByteChar then
      loader.chars.TEMP = loader.chars.TEMP .. string.char(byte)

      bytesRemaining = bytesRemaining - 1

      if bytesRemaining <= 0 then
        inMultiByteChar = false
        loader.chars[loader.chars.TEMP] = true
        loader.chars.TEMP = ""
      end
    elseif byte > 127 then
      inMultiByteChar = true
      if byte > 239 then
        bytesRemaining = 3
      elseif byte > 223 then
        bytesRemaining = 2
      else
        bytesRemaining = 1
      end

      loader.chars.TEMP = string.char(byte)
    else
      loader.chars[string.char(byte)] = true
    end
  end
end

loader.accumulateCharacters = function(card)
  loader.addCharsToTable(card.name)

  if card.oracle_text then
    loader.addCharsToTable(card.oracle_text)
  end

  if card.type_line then
    loader.addCharsToTable(card.type_line)
  end

  if card.card_faces then
    if card.card_faces[1].oracle_text then
      loader.addCharsToTable(card.card_faces[1].oracle_text)
    end

    if card.card_faces[2].oracle_text then
      loader.addCharsToTable(card.card_faces[2].oracle_text)
    end
  end
end

loader.tidleExpansions = {
  "thiscard",
  "thiscreature",
  "thisspell",
  "thisartifact",
  "thisenchantment",
  "thisland",
  "thisplaneswalker",
  "thispermanent",
}

loader.processCards = function(rawJsonObj)
  local oracleObjects = {}
  ---@cast oracleObjects card[]

  for _, card in ipairs(rawJsonObj) do
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

      oracleObject.sets[card.set] = true
    else
      card.availabilities = {}
      for _, game in ipairs(card.games) do
        card.availabilities[game] = true
      end

      card.sets = {}
      card.sets[card.set] = true

      if card.card_faces then
        for _, face in ipairs(card.card_faces) do
          if face.power then
            face.evaluatedPower = loader.evaluatePT(face.power)
          end
          if face.toughness then
            face.evaluatedToughness = loader.evaluatePT(face.toughness)
          end
          if face.loyalty then
            face.evaluatedLoyalty = loader.evaluatePT(face.loyalty)
          end
          if face.defense then
            face.evaluatedDefense = loader.evaluatePT(face.defense)
          end

          face.nameNoEpithet = face.name:match("^([^,]+),")
        end
      end

      loader.stripData(card)

      ---@cast card card

      if card.power then
        card.evaluatedPower = loader.evaluatePT(card.power)
      end
      if card.toughness then
        card.evaluatedToughness = loader.evaluatePT(card.toughness)
      end
      if card.loyalty then
        card.evaluatedLoyalty = loader.evaluatePT(card.loyalty)
      end
      if card.defense then
        card.evaluatedDefense = loader.evaluatePT(card.defense)
      end

      if card.type_line then
        card.type_line = card.type_line:gsub("\226\128\148", "-")
      end


      oracleObjects[card.oracle_id or card.card_faces[1].oracle_id] = card
    end
  end

  local orderedList = {}
  for _, card in pairs(oracleObjects) do
    card.nameSearch = card.name:lower():gsub("[%s,']+", "")

    if card.nameSearch:find("^([^,]+),") then
      card.nameNoEpithet = card.nameSearch:match("^([^,]+),"):lower()
    end

    if card.oracle_text then
      card.oracleTextSearch = card.oracle_text:lower():gsub("[%s,']+", "")

      if card.nameNoEpithet then
        card.oracleTextSearch = card.oracleTextSearch:gsub(card.nameNoEpithet, "~")
      else
        card.oracleTextSearch = card.oracleTextSearch:gsub(card.nameSearch, "~")
      end

      for _, v in pairs(loader.tidleExpansions) do
        card.oracleTextSearch = card.oracleTextSearch:gsub(v, "~")
      end
    end

    table.insert(orderedList, card)
  end

  local file = io.open(opts.cacheDir .. "cardChars.json", "a")
  if file then
    file:write(vim.json.encode(loader.chars))
  end

  return orderedList
end

loader.stripData = function(card)
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
  card.games = nil

  if card.card_faces then
    for _, face in pairs(card.card_faces) do
      face.artist = nil
      face.artist_id = nil
      face.flavor_text = nil
      face.illustration_id = nil
      face.image_uris = nil
      face.printed_name = nil
      face.printed_text = nil
      face.printed_type_line = nil
      face.watermark = nil
    end
  end
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

  local oracleObjects = loader.processCards(rawJsonObj)
  local oracleObjectsJson = vim.json.encode(oracleObjects)

  local bulkFile = io.open(opts.bulkDataPath, "w+")
  if not bulkFile then
    print "Issue opening bulk data file."
    return
  end

  bulkFile:write(oracleObjectsJson)
  io.close(bulkFile)
end

loader.sortList = function(list, field)
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
    loader.sortList(cardLists.allCards, opts.sortPredicate)
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
