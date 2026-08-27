#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4"

#let limit-plot = (raw-data, legend: (0.5, 5.5)) => cetz.canvas({
  import cetz-plot: *

  plot.plot(
    size: (12, 6),
    x-label: [Limit],
    y-label: [Wert],
    x-min: 1,
    x-max: raw-data.len(),
    y-min: 0,
    y-max: calc.max(raw-data.map(e => calc.max(e.at(1), e.at(2) / 1000000)).sorted().last(), 80),
    x-tick-step: 1,
    y-tick-step: 10,
    x-grid: true,
    y-grid: true,
    legend: legend,
    {
      plot.add(
        raw-data.map(d => (d.at(0), (d.at(1) / 104) * 100)),
        mark: "o",
        label: [% exakt gelöste Tests],
        style: (stroke: blue + 1.5pt)
      )
      plot.add(
        raw-data.map(d => (d.at(0), d.at(2) / 1000000)),
        mark: "triangle",
        label: [Ø Laufzeit in `ms`],
        style: (stroke: red + 1.5pt),
      )
    },
  )
})