#import "todo.typ": todo
#import "@preview/note-me:0.6.0": note
#import "limit-plot.typ": limit-plot

#let todo = todo

#let note = note

#let limit-plot = limit-plot

#let cpc = [_Compile Preserving Collaboration_]

#let bib = bibliography("../zotero.bib")

#let color_alice = "#3BA5A5"
#let color_bob = "#D17A22"
#let color_deletion = red

#let alice = text(fill: rgb(color_alice), "Alice")
#let bob = text(fill: rgb(color_bob), "Bob")

#let text_inset = (y: 3pt)

#let normal_text = textContent => box(
  inset: text_inset,
  text(font: "Dejavu Sans", size: 10pt, textContent),
)

#let insertion = (textContent, highlightColor: color_alice) => {
  show regex(" "): "␣"
  box(
  inset: text_inset,
  fill: rgb(highlightColor).lighten(85%),
  stroke: (bottom: rgb(highlightColor)),
  text(font: "Dejavu Sans", size: 10pt, textContent),
)
}

#let deletion = (textContent, highlightColor: color_bob, outset: 0pt, inset: text_inset) => box(
  inset: inset,
  fill: rgb(highlightColor).lighten(85%),
  stroke: (bottom: rgb(highlightColor)),
  outset: outset,
  text(font: "Dejavu Sans", size: 10pt, strike(textContent, stroke: 1pt + rgb(highlightColor))),
)

#let comment = (textContent, highlightColor: color_alice, outset: 0pt, inset: text_inset) => box(
  inset: inset,
  fill: rgb(highlightColor).lighten(85%),
  // stroke: (bottom: rgb(highlightColor)),
  outset: outset,
  text(font: "Dejavu Sans", size: 10pt, textContent),
)

#let fig-block = (body) => block(
  body,
  inset: 10pt,
  stroke: (left: gray),
)
