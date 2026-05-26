local colors = {
  black = "b",
  green = "g",
  red = "r",
  blue = "u",
  white = "w",

  golgari = "bg",
  rakdos = "br",
  dimir = "bu",
  orzhov = "bw",
  gruul = "gr",
  simic = "gu",
  selesnya = "gw",
  izzet = "ru",
  boros = "rw",
  azorius = "uw",

  witherbloom = "bg",
  silverquill = "bw",
  quandrix = "gu",
  prismari = "ru",
  lorehold = "rw",

  jund = "bgr",
  grixis = "bru",
  esper = "buw",
  naya = "grw",
  bant = "guw",

  jeskai = "ruw",
  sultai = "bgu",
  abzan = "bgw",
  mardu = "brw",
  temur = "gru",

  riviteers = "bgr",
  maestros = "bru",
  obscura = "buw",
  cabaretti = "grw",
  brokers = "guw",

  zagoth = "bgu",
  indatha = "bgw",
  savai = "brw",
  ketria = "gru",
  raugrin = "ruw",

  glint = "bgru",
  dune = "bgrw",
  witch = "bguw",
  yore = "bruw",
  ink = "gruw",

  chaos = "bgru",
  aggression = "bgrw",
  growth = "bguw",
  artifice = "bruw",
  altruism = "gruw",

  all = "bgruw",
}

local json = vim.json.encode(colors)

local file = io.open("./colorNames.json", "w+")

if file then
  file:write(json)
  file:close()
end
