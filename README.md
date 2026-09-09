# accessories-tex

Shared LaTeX templates, notation, fonts, and related experiments for personal
mathematical notes. This README is a permanent work in progress and will be
expanded as the `noteformyself` redesign is discussed and implemented.

## Table of Contents

- [Overview](#overview)
- [Five Note Repositories and Reference System](#five-note-repositories-and-reference-system)
- [Repository Layout](#repository-layout)
- [LaTeX Templates](#latex-templates)
- [Reference Management](#reference-management)
- [Shared Resources](#shared-resources)
- [Development](#development)
- [License](#license)

## Overview

The repository collects reusable accessories for typesetting notes, including
the `noteformyself` document class and earlier Typst experiments.

## Five Note Repositories and Reference System

The notes are organized as five sibling repositories. Three cover different
parts of geometry, while the other two provide algebraic foundations and a
place for dynamics:

| Repository | Book title | Main role |
| --- | --- | --- |
| `algebras-toward-algebraic-geometry` | *Algebra toward Algebraic Geometry* | Commutative algebra, homological algebra, category theory, sites, sheaves, stacks, and derived categories |
| `algebraic-geometry` | *Notes in Algebraic Geometry* | Schemes, varieties, curves, surfaces, moduli, birational geometry, algebraic groups, and related topics |
| `complex-geometry` | *Complex Geometry* | Complex geometry, cohomology, intersection theory, and Hermitian and Kähler geometry |
| `arithmetic-geometry` | *Arithmetic Geometry* | Valuations, non-Archimedean analysis, Berkovich spaces, Arakelov geometry, and adelic line bundles |
| `aaa-dynamics` | *Algebraic, Analytic, and Arithmetic Dynamics* | Dynamics across algebraic, analytic, and arithmetic settings |

Each repository has the same three-level compilation hierarchy:

```text
<repository>/
├── notes.json
├── <book-id>.tex
├── refs.bib
├── accessories/                         shared Git submodule
└── chapters/
    └── <chapter-id>/
        ├── <chapter-id>.tex
        └── <section-id>/
            ├── <section-id>.tex
            └── text.tex
```

The root wrapper builds the complete book, each chapter wrapper builds one
chapter, and each section wrapper builds one section independently. The section
`text.tex` is the authoritative content file and is included by all three
wrappers. `notes.json` records stable IDs, ordering, titles, publication state,
wrapper paths, and public PDF routes. Every repository mounts this
`accessories-tex` repository at `accessories/`, so they share the same document
class, notation, management programs, and reference protocol.

### Permanent tags

A displayed number such as `Theorem 3.1.2` is a location that may change. A tag
is the permanent identity of published mathematical content. Tags use uppercase
letters and digits in a prefix hierarchy:

| Length | Identifies | Example |
| ---: | --- | --- |
| 1 | book/repository | `A` |
| 3 | chapter | `A01` |
| 5 | section | `A01B2` |
| 7 | subsection or theorem-like entry | `A01B2C3` |

Each level adds two base-36 characters, giving 1,296 child allocations beneath
one parent. Every allocated tag is globally unique across all five repositories,
and every child tag begins with its parent's complete tag. The examples above
illustrate the format only; actual codes must be allocated by the global
registry and are not assigned by this README.

The system follows these rules:

- Tags appear as searchable text in the PDF.
- Sections are the smallest publication units. A chapter or book publication
  is composed from published sections.
- Draft tags are provisional and are not reserved in the global registry.
- A mathematically unchanged statement keeps its tag when it moves. Its prefix
  records its allocation origin rather than its current file path.
- A mathematical or semantic change receives a new tag. The retired tag is
  never reused; its frozen registry record points to the replacement.
- Published theorems, definitions, propositions, lemmas, corollaries,
  conjectures, questions, remarks, claims, examples, exercises, constructions,
  notations, and tagged structural divisions participate in the system.
- Published scopes fail LaTeX validation when required labels or tags are
  missing, malformed, retired, or inconsistent with the loaded registry. The
  external registry tool is responsible for global allocation, duplicate-tag
  detection, and retirement records; that tool is the next implementation
  stage.

Titles remain optional. A published heading and its ordinary in-repository
reference have the forms:

```text
Theorem 1.2.3 (Fundamental comparison) (Tag A01B2C3)
Theorem 1.2.3 (Tag A01B2C3)
```

A draft reference is simply `Theorem 1.2.4`, without a permanent-tag suffix.

### Cross-references

There are two kinds of cross-document reference:

1. **Within one repository.** A section may cite a label owned by another
   independently compiled section. `manage-references sync` reads the compiled
   `.aux` and `.nfm-xref` records and generates one `*.external-labels.tex` file
   beside every book, chapter, and section wrapper. It excludes the current
   section, or content already included by the current chapter/book, so labels
   are not defined twice. When a full book build is available, its numbering is
   used for display while the hyperlink still targets the owning section PDF
   and that PDF's local anchor. Authors continue to write an ordinary source
   label, for example `\cref{thm:comparison}`.
2. **Across repositories.** Each repository publishes a validated
   `external-labels.json` catalog containing its labels, display records, tags,
   PDF anchors, and full section-level URLs. A consumer lists the catalog under
   `externalReferences` in `notes.json`, assigns it a short namespace, and runs
   `manage-references fetch`. If the namespace is `ag`, the imported label is
   cited as `\cref{ag:thm:comparison}`. Namespaces prevent identical source
   labels in different repositories from colliding.

An in-repository published reference is compact:

```text
Theorem 3.1.2 (Tag A01B2C3)
```

The same entry cited from another repository includes its source book:

```text
[Notes in Algebraic Geometry, Theorem 3.1.2, Tag A01B2C3]
```

An external draft reference includes its current structural location but no
tag. Released URLs follow the repository routes in `notes.json`; for example:

```text
https://www.tianleyang.com/aaa-dynamics/pdf/chapters/the-first-introduction/examples-of-dynamics/examples-of-dynamics.pdf
```

The URL opens the smallest independently compiled PDF containing the label, and
`xr-hyper` adds the label's PDF destination so compatible viewers jump directly
to the referenced item. The JSON catalog is validated as data before local TeX
records are generated; downloaded TeX source is never executed directly.

## Repository Layout

- `templates-of-latex/` — LaTeX classes and example templates.
- `tomb_of_typst/` — archived or experimental Typst templates.
- `fonts/` — fonts stored with the repository.
- `notation.tex` — shared mathematical notation.
- `packages-pdflatex.tex` — shared package configuration for pdfLaTeX documents.
- `manage-notes` — note-management utility.
- `manage-references` — local and cross-repository LaTeX reference manager.

## LaTeX Templates

Documentation for the templates will be added as their interfaces are reviewed.
The active redesign target is
[`noteformyself.cls`](templates-of-latex/noteformyself/noteformyself.cls).

## Reference Management

`manage-references` provides the first version of reference exchange for note
repositories described by `notes.json`. It keeps source labels unchanged inside
a repository and adds a required namespace, such as `ag:`, when another
repository imports them.

After compiling a changed section, regenerate the reference inputs and then
compile any section that cites it:

```console
./accessories/manage-references sync
(cd chapters/example/second-section && latexmk -xelatex second-section.tex)
```

Each book, chapter, and section wrapper receives a generated
`*.external-labels.tex` input. The input excludes labels already present in that
compilation unit, preventing duplicate definitions. Local reference data is
materialized under `.note-references/local/`; it uses canonical numbering from
the full book build when available, while links still target the independently
compiled section PDF and its own PDF anchor.

To import another repository, add its released catalog to the top level of
`notes.json`:

```json
{
  "externalReferences": [
    {
      "prefix": "ag",
      "url": "https://www.tianleyang.com/algebras-toward-algebraic-geometry/external-labels.json"
    }
  ]
}
```

Then download, validate, cache, and synchronize it:

```console
./accessories/manage-references fetch
```

The imported source label `thm:comparison` is cited as
`\cref{ag:thm:comparison}`. Its hyperlink opens the URL recorded for its source
section and appends the PDF named destination generated by LaTeX.

For a release, compile every book, chapter, and section wrapper and run:

```console
./accessories/manage-references release
./accessories/manage-references validate
```

`release` writes `external-labels.json`. By default it combines each relative
`notes.json` PDF route with
`https://www.tianleyang.com/<book.id>/`; use `--base-url` to override that
convention. A development-only `--allow-missing` option can omit uncompiled
documents, but should not be used for publication.

Useful commands are:

- `sync` — regenerate local caches, downloaded-catalog caches, and wrapper
  inputs;
- `fetch` (or `update`) — download every configured catalog and then run
  `sync`;
- `release` — validate compiled labels and write the public catalog;
- `validate` — fail if labels conflict or generated files are stale;
- `--dry-run` — report intended changes without writing them.

The downloaded catalog snapshots and `*.external-labels.tex` files may be
committed for reproducible builds. Their materialized `.aux` and `.nfm-xref`
files are generated and already covered by the LaTeX ignore rules. Global tag
allocation, retirement, and semantic-change review remain a separate next step.

## Shared Resources

Usage notes for shared notation, fonts, and package configuration will be added
here.

## Development

Run the reference-manager tests with:

```console
python3 -m unittest -v tests.test_manage_references
```

## License

See [`LICENSE`](LICENSE).
