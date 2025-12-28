# `surveil.nvim`

Offline search for Magic, the Gathering(TM) cards.
Uses card data provided by Scryfall's bulk data API.
Currently supports the following Scryfall-based syntax:
- simple card name search
- quotes
- o/oracle (currently functions similar to the fo/fullorcale field in that it will also search reminder text)
- t/type
- c/color
- id/identity
- mv/manavalue
- game
- f/format
- pow/power
- tou/toughness
- loy/loyalty
- defense
- s/set/e/edition

The following fields are not planned for implementation:
- function
    - relies on the tagger project, which does not release their data in bulk publicly
- all art fields
    - there are currently no plans to implement any sort of image display, so I do not think they would be particularly useful for this plugin
    - this would also require changing the bulk-data source used to one of scryfall's larger files and neovim already chugs with just over 35k card objects loaded
- is field
    - like the function field this relies on data that is not public.
    - some of these may be implemented as "preset" queries, eg `is:commander` just translates to `t:legend f:commander (t:creature or t:vehicle or t:spaceship)`
- cn/number
- b/block
- in
- all cube fields
- all price fields

# TODO:
- manacost field
- devotion field
- produces field
- mv/manavalue odd/even
- pt/powtou field
- grouping and logical `OR`.
- completion based on Scryfall catalogs
- proper support for double-faced cards
- rulings
- mana-moji?
- ~ substitution
- make o/oracle not search reminder text
- fo/fulloracle field
- r/rarity field
- Use set-lua for color and identity comparison
