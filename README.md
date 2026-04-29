# `surveil.nvim`

Offline search for Magic, the Gathering(TM) cards.
Uses card data provided by Scryfall's bulk data API.
Aims to be print-agnostic; all print-specific fields are either removed to save memory/time or are collated into a list.
eg, `set` is now `sets`, a list of every set the card has been printed in.

## Implemented fields and features
- simple card name search
- quotes
- o/oracle (currently functions similar to the fo/fullorcale field in that it will also search reminder text)
- t/type
- c/color
- id/identity
- mv/manavalue (no odd/even yet)
- game
- f/format
- pow/power
- tou/toughness
- loy/loyalty
- in
- ~ substitution

## Depends on:
- plenary.nvim
- curl

Set (in the math sense) functionality grabbed from https://github.com/EvandroLG/set-lua

# Use
## keybinds
`<leader>su` will open the search window. 
If this is the first time you have opened the window you will be prompted to download the bulk data, which will take up to a minute. 
Loading all cards into memory takes around 3 to 5 seconds.

`<leader>sc` will clear all card objects from memory. 
Please give the garbage collector a second to catch up.

## Commands
`:SurveilClear` will clear all card objects from memory.

`:SurveilPicker` will open the search window.

`:SurveilUpdate` will download all card data and perform some formatting operations. 
I advise you to run this after each update, just in case card fields were added.

## Opts
`opts.cacheDir` defaults to `~/.cache/`.

`opts.defaultQuery` runs this when loading all cards. 
I recommend setting to "game:paper f:vintage" to filter out tokens and memorabilia.

`opts.sortPredicate` partially implement. The only field with explicit support is "edhrec_rank".

# TODO:
- proper support for DFCs
    - fixing this will also fix defense
- remove or eat Plenary dependancy
- `manacost`
- `devotion`
- `produces`
- `mv`/`manavalue` odd/even
- `pt`/`powtou`
- grouping and logical `or`.
- completion based on Scryfall catalogs
- rulings
- mana-moji?
- make `o`/`oracle` not search reminder text
- `fo`/`fulloracle`
- `sort`
- proper support for diacritics and other non-ASCII characters
- `artist`
    - will return all cards an artist has had their art on.
- `function`/`otag`
    - on hold; I have been told there are plans to include oracle and art tag data in the bulk data files.
- `is`
    - this will be implemented slowly over time, complete parity with Scryfall is unlikely
- `face` field
    - options will be 'front', 'back', 'strict_back', and 'both'

## The following fields are not planned for implementation:
- all art related fields except for `artist`
    - there are currently no plans to implement any sort of image display, so I do not think they would be particularly useful for this plugin
- cn/number
- b/block
- s/set
- date
- all cube fields
- all price fields
