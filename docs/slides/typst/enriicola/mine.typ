// Template derivato dallo stile delle vecchie slide: fondo chiaro, titoli blu,
// banda azzurra inferiore e struttura semplice da presentazione tecnica.

#set page(
  width: 13in,
  height: 8in,
  margin: (x: 1.1cm, y: 0.7cm),
  background: place(bottom + left, dx: -1.1cm, dy: 0cm)[
    #box(width: 13in, height: 0.65cm, fill: gradient.linear(rgb("#dff5f8"), rgb("#36a9c1")))
  ],
)

#let blue = rgb("#287b9d")
#let dark = rgb("#1f2933")
#let light-blue = rgb("#e9f5f7")
#let gold = rgb("#d4af37")

#set text(font: ("Lato", "Liberation Sans", "Noto Sans"), size: 21pt, fill: dark)
#show link: set text(fill: blue.darken(25%))
#show heading: set text(fill: blue, weight: "bold")
#show list: set block(below: 8pt)
#show list.item: set block(below: 7pt)

#let header(title) = grid(
  columns: (1fr, auto),
  gutter: 1em,
  align: horizon,
  [#text(size: 19pt, fill: blue)[#title]],
  [#text(size: 11pt, fill: luma(45%))[Enrico Pezzano · UniGe]],
)

#let footer = grid(
  columns: (1fr, auto),
  align: horizon,
  [#text(size: 10pt, fill: luma(45%))[HPC · BIOMOD2 · Species Distribution Models]],
  [#context text(size: 10pt, fill: luma(45%))[#counter(page).display()]],
)

#let card(body) = box(
  fill: light-blue,
  stroke: 1pt + blue.lighten(45%),
  radius: 4pt,
  inset: 12pt,
)[#body]

#let codeblock(body) = box(
  fill: rgb("#f2f4f5"),
  stroke: (left: 3pt + blue),
  inset: 12pt,
  radius: 4pt,
)[
  #set text(font: "DejaVu Sans Mono", size: 16pt)
  #body
]

#let title-slide(title, subtitle, author) = page(header: none, footer: none)[
  #v(1fr)
  #box(
    width: 100%,
    fill: white,
    stroke: 1pt + luma(82%),
    inset: 1.1cm,
  )[
    #align(center)[
      #text(size: 32pt, weight: "bold", fill: blue)[#title]
      #v(0.35cm)
      #text(size: 21pt, fill: luma(35%))[#subtitle]
      #v(0.7cm)
      #line(length: 35%, stroke: 2pt + gold)
      #v(0.5cm)
      #text(size: 16pt, fill: luma(35%))[#author]
    ]
  ]
  #v(1fr)
]

#let slide(title, body) = page(
  header: header(title),
  footer: footer,
)[
  #v(0.25cm)
  #body
]

#title-slide(
  [Making BIOMOD2 executable and measurable on HPC],
  [Species Distribution Models in R · workflow, resources and experiments],
  [Enrico Pezzano · Master's thesis · Università di Genova],
)

#slide[Motivation and research question][
  #v(0.2cm)
  #card[
    *Question.* How can an R/BIOMOD2 workflow be made reproducible, executable and measurable on an HPC system without confusing computational optimisations with scientific results?
  ]
  #v(0.6cm)
  - A large presence dataset and raster projections create a substantial memory and I/O load.
  - The workflow combines five algorithms, ensemble models, current climate and eight future scenarios.
  - The experimental comparison focuses on raster representation and number of workers.
]

#slide[Workflow structure][
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.45cm,
    card[*Input data*\
      2,583,359 presence records\
      167 species\
      1 km² resolution],
    card[*Models*\
      GLM · GBM · ANN\
      FDA · MAXNET\
      two ensembles],
    card[*Execution*\
      R + BIOMOD2\
      Terra + Singularity\
      Slurm job arrays],
  )
  #v(0.8cm)
  #align(center)[
    #text(size: 25pt, fill: blue)[calibration → projection → isolated outputs → validation]
  ]
]

#slide[From script to HPC job][
  #codeblock[
    #raw(lang: "bash", block: true, "#!/bin/bash\n#SBATCH --array=0-166\n#SBATCH --cpus-per-task=8\n#SBATCH --mem=300G\n\nRscript run_species.R --species-index $SLURM_ARRAY_TASK_ID")
  ]
  #v(0.6cm)
  - One species per array task isolates outputs and failures.
  - Resources are explicit and measurable.
  - A completed job is not automatically a validated scientific result.
]

#slide[Experimental evidence][
  #table(
    columns: (1.3fr, 1fr, 1fr),
    inset: 9pt,
    stroke: 0.5pt + luma(75%),
    align: left,
    [*Experiment*], [*Observed result*], [*Status*],
    [Storage `FALSE/FALSE`], [about 261 GiB MaxRSS], [completed],
    [Storage `FALSE/TRUE`], [clamping-mask failure], [to investigate],
    [Workers 4 / 6 / 8], [completed for `Achillea.atrata`], [validated],
    [Workers 32], [out of memory], [failed],
  )
]

#slide[What the template is for][
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.6cm,
    [
      #text(size: 24pt, fill: blue)[*Long technical talk*]
      - workflow and design
      - resource model
      - experimental matrix
      - detailed plots and limitations
    ],
    [
      #text(size: 24pt, fill: blue)[*Short defence*]
      - one problem slide
      - one pipeline slide
      - two result slides
      - one conclusion slide
    ],
  )
  #v(0.7cm)
  #align(center)[#card[*Rule:* one message per slide, one evidence label per result.]]
]

#slide[Takeaways][
  #v(0.5cm)
  #set text(size: 25pt)
  - Reproducibility requires isolating species, scenarios and execution resources.
  - RAM, I/O and parallelism are coupled; more workers do not guarantee better throughput.
  - Results must distinguish completed runs, validated outputs and scientific conclusions.
  #v(0.8cm)
  #align(center)[#text(size: 28pt, weight: "bold", fill: blue)[Questions?]]
]
