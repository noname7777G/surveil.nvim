local deps = {
  attachFunction = attachFunction,
  inverted = inverted,
}

return vim.re.compile([[
  query <- {| branch (or branch)* |}

  --balanced <- "(" ([^()] / balanced)* ")"

  branch <- (!or queryPart)+ -> {}
  or <- ("or" space)+

  queryPart <- space (namePart / operationPair)
  namePart <- value space !operation

  operationPair <- {| {:inverted: "-"? -> inverted:} {:field: word :} {:operation: operation :} {:value: value :} space |} -> attachFunction

  operation <- ":" / "=" / "<=" / ">=" / "<" / ">"

  value <- {word} / quote
  quote <- '"' {~ ((word space)* / '""' -> '"') ~} '"'
  word <- [_%w-~.]+
  space <- %s*
]], deps)
