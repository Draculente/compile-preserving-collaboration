/// Default pixel density (dots per inch) used to derive the map's pixel size.
#let default-density = 192

/// Default pixel size for maps whose resolution is not otherwise determined.
#let default-pixel-size = (1000, 700)

// ---- Web-Mercator geometry (mirrors crates/core/src/tile_math.rs) ----

#let _lon-to-world-x(lon, world) = (lon + 180) / 360 * world

#let _lat-to-world-y(lat, world) = {
  let r = lat * calc.pi / 180
  let merc = calc.ln(calc.tan(calc.pi / 4 + r / 2))
  (1 - merc / calc.pi) / 2 * world
}

#let _max(a, b) = if a > b { a } else { b }
#let _min(a, b) = if a < b { a } else { b }
#let _abs(x) = if x < 0 { -x } else { x }

#let _fit-zoom(west, south, east, north, canvas-w, canvas-h, tile-size: 256) = {
  let nw = _max((east - west) / 360, 1e-9)
  let nh = _max(_abs(_lat-to-world-y(south, 1.0) - _lat-to-world-y(north, 1.0)), 1e-9)
  let world = _max(canvas-w / nw, canvas-h / nh)
  let z = calc.floor(calc.ln(world / tile-size) / calc.ln(2))
  _min(_max(z, 0), 22)
}

// ---- Pins ----

/// Fractional (0..1) position of a coordinate within the rendered canvas.
#let _pin-fraction(lat, lon, center-lat, center-lon, zoom, width-px, height-px, tile-size: 256) = {
  let world = tile-size * calc.pow(2, zoom)
  let cx = _lon-to-world-x(center-lon, world)
  let cy = _lat-to-world-y(center-lat, world)
  let px = _lon-to-world-x(lon, world)
  let py = _lat-to-world-y(lat, world)
  (x: (px - cx + width-px / 2) / width-px, y: (py - cy + height-px / 2) / height-px)
}

/// The pin marker: a plain circle (the pinned coordinate is its center).
#let _pin-marker(color, size) = {
  circle(width: size, height: size, fill: color, stroke: 1.5pt + white)
}

/// A label chip rendered above the marker.
#let _pin-label(label) = {
  box(inset: (x: 4pt, y: 1pt), fill: white, radius: 2pt)[
    #text(size: 8pt, fill: black)[#label]
  ]
}

/// Lay out every pin over the map, centered on its coordinate.
/// `box-w`/`box-h` are the overlay box dimensions in points; the fraction is
/// computed from the render pixel size, then mapped to points with plain
/// lengths (percentage arithmetic is unreliable in this Typst build).
#let _pin-overlay(
  pins,
  center-lat,
  center-lon,
  zoom,
  width-px,
  height-px,
  box-w,
  box-h,
  color,
  size,
) = {
  context {
    for pin in pins {
      let is-array = type(pin) == type((0, 0))
      let (plat, plon) = if is-array { (pin.at(0), pin.at(1)) } else { (pin.lat, pin.lon) }
      let pcolor = if is-array { color } else { pin.at("color", default: color) }
      let label = if is-array { none } else { pin.at("label", default: none) }
      let f = _pin-fraction(plat, plon, center-lat, center-lon, zoom, width-px, height-px)
      let x = f.x * box-w
      let y = f.y * box-h
      place(dx: x - size / 2, dy: y - size / 2, _pin-marker(pcolor, size))
      if label != none {
        let chip = _pin-label(label)
        let s = measure(chip)
        place(dx: x - s.width / 2, dy: y - size / 2 - s.height - 2pt, chip)
      }
    }
  }
}

/// Resolve the overlay box size to lengths. Pins require an absolute `width`;
/// an `auto` height is derived from the render aspect ratio.
#let _resolve-box-size(width, height, res) = {
  assert(
    type(width) == type(1pt),
    message: "map: `pins` requires `width` to be an absolute length (e.g. 17cm)",
  )
  let box-w = width
  let box-h = if height == auto {
    box-w * (res.height-px / res.width-px)
  } else {
    assert(
      type(height) == type(1pt),
      message: "map: `pins` requires `height` to be an absolute length or `auto`",
    )
    height
  }
  (box-w, box-h)
}

/// Compute the render resolution in pixels for a map.
///
/// Resolution is taken from, in priority order:
///
/// - explicit `pixel-width` and `pixel-height`,
/// - one explicit dimension, with the other derived from a 10:7 aspect,
/// - the physical `width`/`height` (absolute lengths) at `pixel-density`,
/// - the default pixel size scaled by `pixel-density`.
///
/// Returns a dictionary with `width-px` and `height-px` keys.
#let pixel-size(
  width: none,
  height: none,
  pixel-density: auto,
  pixel-width: auto,
  pixel-height: auto,
  .._rest,
) = {
  let density = if pixel-density == auto { default-density } else { pixel-density }

  let length-pt = x => {
    if type(x) == type(1pt) {
      x / 1pt
    } else {
      none
    }
  }

  let base = default-pixel-size
  let base-w = calc.round(base.at(0) * density / 192)
  let base-h = calc.round(base.at(1) * density / 192)

  let from-width = if width != none and length-pt(width) != none {
    calc.round(length-pt(width) * density / 72)
  } else {
    none
  }
  let from-height = if height != none and length-pt(height) != none {
    calc.round(length-pt(height) * density / 72)
  } else {
    none
  }

  let pw = if pixel-width != auto {
    pixel-width
  } else if pixel-height != auto {
    calc.round(pixel-height * 10 / 7)
  } else if from-width != none {
    from-width
  } else {
    base-w
  }

  let ph = if pixel-height != auto {
    pixel-height
  } else if pixel-width != auto {
    calc.round(pixel-width * 7 / 10)
  } else if from-height != none {
    from-height
  } else {
    base-h
  }

  (width-px: pw, height-px: ph)
}

/// Embed a map rendered by the `atlas` CLI.
///
/// The raster tiles are fetched and stitched ahead of time:
///
/// ```sh
/// atlas render --center 52.52,13.405 --zoom 12 --size 2000x1400 -o map.png
/// ```
///
/// Parameters:
///
/// - `file`: the rendered PNG, as a path or raw image bytes. When using the
///   package (e.g. `@local/atlas`), pass bytes read from your own document so
///   the path resolves against your file, not the package:
///   `read("map.png", encoding: none)`.
/// - `center`, `zoom` | `bbox`: locate the map. Pass `center` (lat, lon) with
///   `zoom`, or `bbox` (west, south, east, north) to auto-fit the zoom.
/// - `width`, `height`: display size. An absolute `width` is required for
///   `pins`; an `auto` height is derived from the render's aspect ratio.
/// - `fit`: how the image fills the box — `"contain"` (default), `"cover"`, or
///   `"stretch"`.
/// - `alt`: alternative description for assistive technology; only embedded in
///   PDF output.
/// - `pixel-density` (or `pixel-width`/`pixel-height`): the render resolution.
///   Match it in `atlas render` (e.g. `--size-pt 481.89x226.77 --dpi 300` for a
///   17cm x 8cm map at 300 dpi, which yields 2008x945 px) so the image stays
///   sharp at the requested `width`/`height` and pins align.
/// - `pins`: vector pin markers at `(lat:, lon:)` coordinates. Each entry is a
///   bare `(lat, lon)` tuple or `(lat:, lon:, label:, color:)`; `label` renders
///   a caption chip above the marker, `color` overrides `pin-color`.
/// - `pin-color`, `pin-size`: default pin fill color and marker size.
///
/// To add a caption (e.g. the OSM attribution required when using
/// OpenStreetMap tiles), wrap the map in a `figure` yourself — the
/// `atlas render --snippet` output does exactly this:
///
/// ```typst
/// #figure(
///   map(center: (52.52, 13.405), zoom: 12, file: "map.png", width: 17cm),
///   caption: [
///     #sym.copyright #link("https://www.openstreetmap.org/copyright")[OpenStreetMap], image created using https://tile.openstreetmap.org/12/2200/1343.png
///   ],
/// )
/// ```
///
/// This function only lays the resulting image out; it does not render.
#let map(
  file: none,
  center: none,
  zoom: none,
  bbox: none,
  width: 100%,
  height: auto,
  fit: "contain",
  alt: none,
  pixel-density: auto,
  pixel-width: auto,
  pixel-height: auto,
  pins: none,
  pin-color: red,
  pin-size: 12pt,
) = {
  assert(
    file != none,
    message: "map: `file` is required (path to a PNG produced by `atlas render`)",
  )

  if pins == none or pins.len() == 0 {
    image(file, width: width, height: height, fit: fit, alt: alt)
  } else {
    // Named arguments: positional args are swallowed by pixel-size's catch-all
    // sink in this Typst build.
    let res = pixel-size(
      width: width,
      height: height,
      pixel-density: pixel-density,
      pixel-width: pixel-width,
      pixel-height: pixel-height,
    )
    let (eff-lat, eff-lon, eff-zoom) = if center != none {
      let (clat, clon) = center
      (clat, clon, if zoom == none { 12 } else { zoom })
    } else if bbox != none {
      let (west, south, east, north) = bbox
      let z = _fit-zoom(west, south, east, north, res.width-px, res.height-px)
      ((north + south) / 2, (west + east) / 2, z)
    } else {
      (none, none, none)
    }
    assert(
      eff-lat != none,
      message: "map: `pins` requires `center` or `bbox`",
    )
    let (box-w, box-h) = _resolve-box-size(width, height, res)
    // Placed content is drawn beneath flow content in this Typst build, so
    // the image must share the placed layer with the pins.
    box(width: box-w, height: box-h)[
      #place(
        dx: 0%,
        dy: 0%,
        image(file, width: box-w, height: box-h, fit: fit, alt: alt),
      )
      #_pin-overlay(
        pins,
        eff-lat,
        eff-lon,
        eff-zoom,
        res.width-px,
        res.height-px,
        box-w,
        box-h,
        pin-color,
        pin-size,
      )
    ]
  }
}