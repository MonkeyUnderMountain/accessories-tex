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
   independently compiled section. `labels-ref-sync fetch` downloads the
   repository's own published catalog, and `sync` creates tracked TeX records
   plus one `external-labels.tex` file beside every book, chapter, and section
   wrapper. It excludes the current section, or content already included by
   the current chapter/book, so labels are not defined twice. A locally
   compiled document may overlay its downloaded record during development;
   every uncompiled document continues to come from the published snapshot.
   Authors use an ordinary unprefixed source label, for example
   `\cref{thm:comparison}`.
2. **Across repositories.** Each repository publishes a validated
   `external-labels.json` catalog containing its labels, display records, tags,
   PDF anchors, and full section-level URLs. A consumer lists the catalog under
   `externalReferences` in `notes.json`, assigns it a short namespace, and runs
   `labels-ref-sync fetch`. If the namespace is `ag`, the imported label is
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
- `labels-ref-sync` — local and cross-repository label/reference synchronizer.

## LaTeX Templates

Documentation for the templates will be added as their interfaces are reviewed.
The active redesign target is
[`noteformyself.cls`](templates-of-latex/noteformyself/noteformyself.cls).

## Reference Management

`labels-ref-sync` provides the first version of reference exchange for note
repositories described by `notes.json`. It keeps source labels unchanged inside
a repository and adds a required namespace, such as `ag:`, when another
repository imports them.

Declare both the released filename and the URL used to download this
repository's published catalog at the top level of `notes.json`:

```json
{
  "referenceCatalog": {
    "file": "external-labels.json",
    "downloadUrl": "https://www.tianleyang.com/example-book/external-labels.json"
  }
}
```

`file` is the artifact written by `release`; `downloadUrl` is used only by
`fetch`. In particular, the catalog's hosting location does not determine the
public PDF URLs stored inside it.

Download all published catalogs and generate the reference inputs before
compiling a section:

```console
./accessories/labels-ref-sync fetch
(cd chapters/example/second-section && latexmk -xelatex second-section.tex)
```

Each book, chapter, and section wrapper receives a generated
`external-labels.tex` input in its own directory. The input excludes labels
already present in that compilation unit, preventing duplicate definitions.
All downloaded and generated reference data is tracked in Git:

```text
label-references/
├── catalogs/
│   ├── self.json
│   └── <external-prefix>.json
└── records/
    ├── self/
    └── <external-prefix>/
```

Each source label occurs once in its catalog and once in the corresponding
record shard. The nearby `external-labels.tex` files contain only imports of
the shards allowed for that compilation target; they do not copy label
records. Same-repository links use the owning section URL stored in the
downloaded catalog.

To import another repository, add its released catalog to the top level of
`notes.json`:

```json
{
  "externalReferences": [
    {
      "prefix": "ag",
      "downloadUrl": "https://www.tianleyang.com/algebras-toward-algebraic-geometry/external-labels.json"
    }
  ]
}
```

An entry may temporarily use an empty `downloadUrl` as a placeholder. It is
ignored until a URL or an already tracked catalog is available.

Then download, validate, cache, and synchronize it:

```console
./accessories/labels-ref-sync fetch
```

The imported source label `thm:comparison` is cited as
`\cref{ag:thm:comparison}`. Its hyperlink opens the URL recorded for its source
section and appends the PDF named destination generated by LaTeX.

The normal local workflow is:

```console
./accessories/labels-ref-sync fetch
# Compile the section/chapter/book whose local labels changed.
./accessories/labels-ref-sync sync
./accessories/labels-ref-sync validate
git add label-references '**/external-labels.tex' notes.json
```

Commit the generated wrapper changes as well when `sync` first inserts their
managed import blocks. A new same-repository label must be compiled and synced
before the push that first cites it.

For an initial catalog release, compile every book, chapter, and section
wrapper and run:

```console
./accessories/labels-ref-sync release
./accessories/labels-ref-sync validate
```

`release` writes `referenceCatalog.file`, or `external-labels.json` when no
catalog is declared. It combines each relative `notes.json` PDF route with
`https://www.tianleyang.com/<book.id>/`; use `--base-url` to override that
public PDF base. A development-only `--allow-missing` option can omit
uncompiled documents, but should not be used for publication.

An incremental CI build passes the previous published catalog and the exact
wrappers rebuilt in that run:

```console
./accessories/labels-ref-sync release \
  --previous label-references/catalogs/self.json \
  --documents-file .reference-build-documents
```

Records owned by rebuilt documents are replaced or removed; records owned by
uncompiled documents are retained. Fresh book numbering may update a retained
record without replacing its section-level PDF page and anchor. GitHub Actions
does not fetch catalogs or regenerate committed imports. It compiles the
selected wrappers, merges their output into the tracked self snapshot, and
publishes the resulting catalog with the PDFs. If no tracked self snapshot
exists yet, the first deployment performs a full build.

Useful commands are:

- `sync` — regenerate tracked TeX records and per-wrapper imports from the
  tracked catalogs, with available local compilation outputs as overrides;
- `fetch` (or `update`) — download every configured catalog and then run
  `sync`;
- `release` — write a full catalog or merge selected compiled documents into a
  previous published catalog;
- `validate` — fail if labels conflict or generated files are stale;
- `--dry-run` — report intended changes without writing them.

The `label-references/` tree, per-directory `external-labels.tex` files, and
managed wrapper changes are committed for reproducible builds. Global tag
allocation, retirement, and semantic-change review remain a separate next
step.

## Shared Resources

Usage notes for shared notation, fonts, and package configuration will be added
here.

## Development

Run the reference-manager tests with:

```console
python3 -m unittest -v tests.test_labels_ref_sync
```

## License

See [`LICENSE`](LICENSE).
