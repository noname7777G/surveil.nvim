# `surveil.nvim`

Offline search for Magic, the Gathering(TM) cards.
Uses card data provided by Scryfall's bulk data API.
Aims to be print-agnostic; all print-specific fields are either removed to save memory/time or are collated into a list.
Eg, `set` is now `sets`, a list of every set the card has been printed in.

I work on this in fits and starts, expect changes to be rapid and bugs to be rampant.
I will try to leave it in a functioning state if I take a hiatus.

## Implemented fields and features
- simple card name search
- quotes
- `o`/oracle (currently functions similar to the fo/fulloracle field in that it will also search reminder text)
- `t`/`type`
- `c`/`color`
- `id`/`identity`
- `mv`/`manavalue` (no odd/even yet)
- `game`
- `f`/`format`
- `pow`/`power`
- `tou`/`toughness`
- `loy`/`loyalty`
- `in`
- `~` substitution
- logical `or`

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
## Priority
- grouping with `()`
    - Will involve a rework of the query functions
- optimize
    - make download and data grooming run in background
    - pre-generate color relationship data
        - this will make checking color relationships as fast as indexing two tables and comparing the returned relationship string to the operator field of the query object
    - Move as much evaluation of card data into `stripdata()` as possible, creating new fields:
        - `oracleTextSearch`
            - lowercase
            - no reminder text
            - replace self-referential subjects/objects with `~`
            - no white space or punctuation
        - `nameSearch`
            - lowercase
            - no white space or punctuation
        - `colorsCount`
        - `colorIdentityCount`
        - `colorIndicatorCount`
        - `producesCount`
- remove duplicate set codes, particularly "sld"
- proper support for DFCs
- `manacost`
- `devotion`
- `produces`
- `mv`/`manavalue` odd/even
- `pt`/`powtou`
- completion based on Scryfall catalogs
- rulings
- make `o`/`oracle` not search reminder text
- `fo`/`fulloracle`
- proper support for diacritics and other non-ASCII characters
- remove or eat Plenary dependency
- `artist`
    - return all cards an artist has had their art on
- text field queries starting with `v/` will use the vim regex engine, respecting user settings
- text field queries starting with `l/` will use the lua pattern engine

## Eventually
- `sort`
- `function`/`otag`
    - on hold; I have been told there are plans to include oracle and art tag data in the bulk data files
- `is`
    - will be implemented slowly over time, complete parity with Scryfall is unlikely

## Maybe
- mana-moji
- `face` field
    - options will be 'front', 'back', 'strict_back', and 'both'
- `apropos`
    - returns cards that synergizes with, tutor for, can be found with, or are combo pieces with the named card

## The following fields are not planned for implementation:
- all print specific fields except for `artist`
    - there are currently no plans to implement any sort of image display, so I do not think they would be particularly useful for this plugin
- cn/number
- b/block
- s/set
- date
- all cube fields
- all price fields
