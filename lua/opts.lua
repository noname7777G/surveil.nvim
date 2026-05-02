---@class surveilOpts
---@field bulkDataPath string?
---@field defaultQuery string?
---@field sortPredicate string?
---@field cacheDir string?
local opts = {}

opts.bulkDataPath = vim.fn.stdpath("cache") .. "/oracle_cards.json"
opts.curlArgs = " --header User-Agent:nvim-surveil --header Accept:*/* --silent "
opts.cacheDir = vim.fn.stdpath("cache")

return opts
