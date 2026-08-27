#import "@preview/cetz:0.4.1"
#import cetz.draw: *

#let letter-box = (
  coords,
  name: none,
  pad-x: 0.25,
  pad-y: 0.4,
  w: none,
  h: none,
  content,
  reduced: false,
  font-size: 4em,
  font-family: "Liberation Mono",
  bg-color: rgb("#f4f8f4"),
  text-color: black,
  reduced-color: gray,
  // none, front, back, both
  attachment-points: "both",
  attachment-point-radius: 0.05,
  attachment-point-color: (front: white, back: white),
  attachment-point-stroke-color: gray,
) => {
  let content = [
    #set text(
      size: font-size,
      font: font-family,
      fill: if reduced {
        reduced-color
      } else {
        text-color
      },
    )
    #pad(x: pad-x * 1cm, y: pad-y * 1cm, content)
  ]
  let w = if w != none {
    w
  } else {
    measure(content).width
  }
  let h = if h != none {
    h
  } else {
    measure(content).height
  }
  rect(
    name: name,
    (rel: (-w / 2, -h / 2), to: coords),
    (rel: (w / 2, h / 2), to: coords),
    stroke: if reduced {
      (paint: reduced-color, thickness: 0.5pt)
    },
    fill: if reduced {
      none
    } else {
      rgb("#f4f8f4")
    },
    radius: 0.08,
  )
  cetz.draw.content(
    name + ".center",
    content,
  )

  let attachment-point = direction => {
    circle(
      name
        + if direction == "front" {
          ".west"
        } else {
          ".east"
        },
      name: name + "-" + direction,
      radius: attachment-point-radius,
      stroke: (paint: attachment-point-stroke-color, thickness: 0.01),
      fill: attachment-point-color.at(direction),
    )
  }
  if attachment-points != none {
    if attachment-points == "both" or attachment-points == "front" {
      attachment-point("front")
    }
    if attachment-points == "both" or attachment-points == "back" {
      attachment-point("back")
    }
  }
}

#let item-row = (
  coord,
  deleted-row: true,
  items,
  markers: (),
  datapoints: (),
  item-font-size: 1.3em,
  item-font: "Liberation Mono",
  item-width: 0.7,
  item-height: 0.8,
  id-bottom-padding: 0.15,
  id-font-size: 0.8em,
  deleted-row-top-padding: 0.3,
  marker-row-padding: 1,
  marker-height: 0.8,
  marker-id-font: "Roboto",
  marker-id-font-size: 0.8em,
  marker-id-font-weight: 600,
  initial-marker-padding: 1.5,
) => {
  for (i, item) in items.enumerate() {
    let marker = markers.find(e => e.from.id == item.id or e.to.id == item.id)

    let marker-direction = if marker != none {
      if marker.from.id == item.id {
        marker.from.anchor
      } else {
        marker.to.anchor
      }
    } else {
      none
    }

    letter-box(
      (rel: (i * 0.9, 0), to: coord),
      name: item.id,
      item.content,
      w: item-width,
      h: item-height,
      font-size: item-font-size,
      font-family: item-font,
      reduced: item.at("deleted", default: false) or item.id == "start" or item.id == "end",
      attachment-points: if markers.len() == 0 {
        "none"
      } else if item.id == "start" {
        "back"
      } else if item.id == "end" {
        "front"
      } else {
        "both"
      },
      attachment-point-color: (
        front: if marker-direction == "front" { marker.color } else { white },
        back: if marker-direction == "back" { marker.color } else { white },
      ),
    )

    cetz.draw.content(
      item.id + ".north",
      anchor: "south",
      padding: id-bottom-padding,
      text(font: "Liberation Mono", fill: gray, size: id-font-size)[#item.id],
    )

    if deleted-row {
      let deleted_text = if item.at("deleted", default: false) {
        text(red, "1")
      } else if item.id == "start" {
        text(font: "Roboto", size: 0.7em, weight: "bold", "Deleted")
      } else if item.id == "end" {
        ""
      } else {
        "0"
      }
      cetz.draw.content(
        item.id + ".south",
        padding: deleted-row-top-padding,
        anchor: "north",
        [
          #set text(font: "Liberation Mono")
          #deleted_text
        ],
      )
    }
  }

  let line-thickness = 0.02
  let marker-radius = 0.1
  for (i, marker) in markers.enumerate() {
    let y = -initial-marker-padding - i * marker-row-padding
    let name = marker.id + "-marker"
    rect(
      name: name,
      (rel: (0, y - marker-height / 2), to: marker.from.id + "-" + marker.from.anchor),
      (rel: (0, y + marker-height / 2), to: marker.to.id + "-" + marker.to.anchor),
      radius: marker-radius,
      stroke: (paint: marker.color, thickness: 0.02),
      fill: marker.color.lighten(98%),
    )

    let line-style = (dash: "dotted", thickness: 0.02, paint: marker.color)

    line(
      marker.from.id + "-" + marker.from.anchor,
      name + ".west",
      stroke: line-style,
    )
    line(marker.to.id + "-" + marker.to.anchor, name + ".east", stroke: line-style)

    let marker-id = [
      #set text(
        font: marker-id-font,
        size: marker-id-font-size,
        fill: marker.at("text-color", default: white),
        weight: marker-id-font-weight,
      )
      #pad(2pt, marker.id)]
    let marker-id-width = measure(marker-id).width
    let marker-id-padding = 0.08

    rect(
      name: name + "-marker-id",
      (rel: (marker-id-padding, marker-id-padding), to: name + ".south-west"),
      (rel: (marker-id-width, marker-height - 2 * marker-id-padding)),
      fill: marker.color,
      stroke: none,
      radius: marker-radius,
    )

    cetz.draw.content(name + "-marker-id", marker-id)
    cetz.draw.content(
      name + "-marker-id.east",
      anchor: "west",
      padding: 0.3,
      marker.content,
    )
  }

  for (i, datapoint) in datapoints.enumerate() {
    let y = -initial-marker-padding - markers.len() * marker-row-padding
    let name = datapoint.position + "-datapoint"

    let datapoint-marker-height = 0.5

    // Get max width of content
    let max-width = datapoint
      .content
      .map(c => {
        let marker-id = [
          #set text(
            font: marker-id-font,
            size: marker-id-font-size,
            weight: marker-id-font-weight,
          )
          #pad(3pt, c.id)
        ]
        return measure(marker-id).width
      })
      .reduce((a, b) => calc.max(a, b))

    rect(
      name: name,
      (rel: (0, y - datapoint-marker-height * datapoint.content.len()), to: datapoint.position + ".west"),
      (rel: (max-width + 3.6pt, y + 0.16), to: datapoint.position + ".west"),
      stroke: (paint: gray, thickness: 0.02),
      fill: rgb("#f4f8f4"),
      radius: marker-radius,
    )

    let marker-id-padding = 0.08
    for (j, marker) in datapoint.content.enumerate() {
      let marker-y = -(datapoint-marker-height * j)

      let marker-id = [
        #set text(
          font: marker-id-font,
          size: marker-id-font-size,
          fill: if marker.ending {
            gray
          } else {
            marker.text_color
          },
          weight: marker-id-font-weight,
        )
        #pad(3pt, if marker.ending {
          strike(marker.id)
        } else {
          marker.id
        })
      ]

      let marker-id-width = measure(marker-id).width

      rect(
        name: name + "-marker-id-" + marker.id,
        (rel: (0.05, marker-y - 0.08), to: name + ".north-west"),
        (rel: (marker-id-width, marker-y - datapoint-marker-height), to: name + ".north-west"),
        fill: if marker.ending {
          gray.lighten(90%)
        } else {
          marker.color
        },
        stroke: if marker.ending {
          (paint: marker.color, thickness: 0.02)
        } else {
          none
        },
        radius: marker-radius,
      )
      cetz.draw.content(name + "-marker-id-" + marker.id, marker-id)
    }
  }
}