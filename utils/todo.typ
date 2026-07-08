#let warning = content => box(
  text(
    font: "DejaVu Sans Mono",
    size: 9pt,
  )[#content],
  fill: yellow,
  inset: 2pt,
  outset: 2pt,
  baseline: 20%,
)

#let TODO = (..txt) => warning[
  #if txt.at(0, default: none) == none {
    [_\#TODO_]
  } else {
    [_\#TODO_: #txt.pos().join(", ", last: " & ")]
  }
]

#let todo = (..txt) => TODO(..txt)

#let missing-source = warning[
  Quelle fehlt!
]