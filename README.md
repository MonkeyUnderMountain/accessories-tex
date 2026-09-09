# accessories-tex

Shared LaTeX infrastructure for Tianle Yang's mathematical notes. The main
component is `noteformyself` 2.0, a XeLaTeX class with three compilation modes,
publication-aware permanent tags, readable theorem styles, and support for
references between independently compiled notes.

## Table of Contents

- [Repository Layout](#repository-layout)
- [The Five Note Repositories](#the-five-note-repositories)
- [`noteformyself` 2.0](#noteformyself-20)
  - [Requirements](#requirements)
  - [Compilation Modes](#compilation-modes)
  - [Quick Start](#quick-start)
  - [Metadata and Covers](#metadata-and-covers)
  - [Typography](#typography)
  - [Statement Environments](#statement-environments)
- [Permanent Tags](#permanent-tags)
  - [Tag Hierarchy](#tag-hierarchy)
  - [Status and Publication Rules](#status-and-publication-rules)
  - [Tagging Statements](#tagging-statements)
  - [Tagging Divisions](#tagging-divisions)
  - [Registry and Retired Tags](#registry-and-retired-tags)
- [References Between Documents](#references-between-documents)
  - [Direct Auxiliary-File References](#direct-auxiliary-file-references)
  - [Repository Catalogs](#repository-catalogs)
  - [Manifest Configuration](#manifest-configuration)
  - [Local Workflow](#local-workflow)
  - [Release Workflow](#release-workflow)
- [Management Programs](#management-programs)
- [Development](#development)
- [License](#license)

## Repository Layout

The principal files are:

```text
accessories-tex/
├── labels-ref-sync                      reference catalog synchronizer
├── manage-notes                         chapter/section manager
├── notation.tex                         shared mathematical notation
├── packages-pdflatex.tex                older shared pdfLaTeX setup
├── tests/
│   └── test_labels_ref_sync.py
├── templates-of-latex/
│   ├── noteformyself/
│   │   ├── noteformyself.cls
│   │   ├── template_book.tex
│   │   ├── template_chapter.tex
│   │   ├── template_section.tex
│   │   ├── template_crossref.tex
│   │   ├── tag-registry.example.tex
│   │   └── references.example.bib
│   └── ...
└── tomb_of_typst/                       archived Typst experiments
```

The three source templates are executable documentation. Each shows every
statement environment; the book example additionally previews the full math
alphabet selection, a citation, a table, a diagram, lists, and a code listing.
Their compiled PDFs are kept beside the sources as visual references.

## The Five Note Repositories

Five sibling repositories consume this repository as shared infrastructure:

| Repository | Book | Main role |
| --- | --- | --- |
| `algebras-toward-algebraic-geometry` | *Algebra toward Algebraic Geometry* | Commutative and homological algebra, category theory, sheaves, stacks, and derived categories |
| `algebraic-geometry` | *Notes in Algebraic Geometry* | Schemes, varieties, curves, surfaces, moduli, birational geometry, and algebraic groups |
| `complex-geometry` | *Complex Geometry* | Complex geometry, cohomology, intersection theory, Hermitian geometry, and Kähler geometry |
| `arithmetic-geometry` | *Arithmetic Geometry* | Valuations, non-Archimedean analysis, Berkovich spaces, Arakelov geometry, and adelic line bundles |
| `aaa-dynamics` | *Algebraic, Analytic, and Arithmetic Dynamics* | Dynamics in algebraic, analytic, and arithmetic settings |

Each note repository follows the same independently compilable hierarchy:

```text
<repository>/
├── notes.json
├── <book-id>.tex
├── refs.bib
├── accessories/                         this repository, usually a submodule
├── label-references/                    tracked downloaded/generated records
└── chapters/
    └── <chapter-id>/
        ├── <chapter-id>.tex
        ├── external-labels.tex
        └── <section-id>/
            ├── <section-id>.tex
            ├── external-labels.tex
            └── text.tex
```

The book wrapper builds the complete note, a chapter wrapper builds one
chapter, and a section wrapper builds one section. A section's `text.tex` is
the authoritative content included by all three wrappers. `notes.json` records
stable IDs, ordering, wrapper paths, statuses, and public PDF routes.

## `noteformyself` 2.0

The class lives at
[`templates-of-latex/noteformyself/noteformyself.cls`](templates-of-latex/noteformyself/noteformyself.cls).
Version 2.0 keeps its source organized by responsibility; each block and loaded
package is commented with its effect so later changes can be made locally.

### Requirements

Use a recent TeX Live installation with XeLaTeX, `latexmk`, and Biber. The class
loads the packages needed for:

- AMS mathematics and theorem definitions;
- OpenType and Unicode mathematics;
- Chinese text through `ctex`;
- TikZ and `tikz-cd` diagrams;
- `biblatex` bibliographies;
- `hyperref`, `xr-hyper`, and `cleveref` references;
- `tcolorbox` statement styles;
- lists, long tables, footnotes, and source-code listings.

Xy-pic is not loaded in 2.0. New commutative diagrams should use `tikz-cd`.

Compile an example from its directory:

```console
cd templates-of-latex/noteformyself
latexmk -xelatex template_book.tex
```

`latexmk` runs XeLaTeX as many times as the table of contents and references
require and invokes Biber when a bibliography is present. A magic comment alone
selects an engine in an editor; it does not replace the multi-pass `latexmk`
recipe.

### Compilation Modes

Set `sectionlevel` on the document class:

| Mode | Base class | Opening | Statement numbering |
| --- | --- | --- | --- |
| `book` | `book` | Full cover and information/citation page | Within each section |
| `chapter` | `article` | Full cover marked `CHAPTER` | Within each section |
| `section` | `article` | Compact author/date line, no cover | One local sequence |

For example:

```tex
\documentclass[sectionlevel=chapter,status=draft]{noteformyself}
```

The default mode is `section`; the default publication status is `draft`.

### Quick Start

A minimal draft document needs no registry:

```tex
% !TeX program = xelatex
\documentclass[sectionlevel=section,status=draft]{noteformyself}

\title{A Standalone Section}
\author{Tianle Yang}
\date{\today}

\notesetup{
  book={Notes in Algebraic Geometry},
  book-tag=A,
  chapter-tag=A01,
  status=draft
}

\begin{document}
\maketitle

\section[status=draft,tag=A01B2,label=sec:introduction]{Introduction}

\begin{theorem}[title={Comparison},label=thm:comparison]
  Two objects with the same universal property are uniquely isomorphic.
\end{theorem}

See \cref{thm:comparison}.
\end{document}
```

Use the complete book, chapter, and section templates when starting a new
wrapper; remove demonstrations that are irrelevant to the note.

### Metadata and Covers

Standard LaTeX metadata is extended by:

| Command | Effect |
| --- | --- |
| `\authoremail{...}` | Author email on the book information page |
| `\authorpage{...}` | Author homepage or other formatted contact line |
| `\citationkey{...}` | Enables a copyable BibTeX `@misc` entry in book mode |
| `\noteurl{...}` | Adds the URL field to that suggested citation |
| `\coversentence{...}` | Short sentence near the bottom of a full cover |
| `\coverimage{...}` | Optional image below the title field |
| `\texsource{...}` | Source note on the book information page |
| `\version{...}` | Version displayed on the cover and information page |
| `\copyrightyear{...}` | Overrides the current year |

The visual palette can be adjusted with `\coveraccentcolor`,
`\coverpapercolor`, `\covertextcolor`, and `\covertitlefont`. The compatibility
command `\coverlinecolor` now controls the solid accent field.

A book cover intentionally has no `BOOK` label. A chapter cover is labeled
`CHAPTER`. If `\coverimage` is omitted, the center remains open; a missing
nonempty image produces a warning and the build continues. Long titles use
fixed-width, ragged-right blocks on the cover and information page.

### Typography

The open-source default families are:

| Use | Typeface |
| --- | --- |
| Body text | Libertinus Serif |
| Headings and interface text | Libertinus Sans |
| Tags, suggested BibTeX, and code | Source Code Pro, with Libertinus Mono fallback |
| Ordinary mathematics, `\mathcal`, and `\mathfrak` | STIX Two Math |
| `\mathscr` | STIX Two Math stylistic set 1 |
| `\mathbb` | Libertinus Math |

Latin Modern Math is the baseline fallback when a preferred math font is not
installed. The book template contains uppercase, lowercase, inline, and
ordinary formula specimens for visual checking.

### Statement Environments

The following numbered environments accept publication metadata and share one
counter, except `mainthm`, whose global display is `A`, `B`, `C`, and so on:

| Filled background | Left rail only |
| --- | --- |
| `definition` | `remark` |
| `proposition` | `claim` |
| `theorem` | `example` |
| `mainthm` | `exercise` |
| `lemma` | `construction` |
| `corollary` | `notation` |
| `conjecture` | |
| `question` | |

Filled boxes round only the upper-left and lower-left corners; their right edge
is sharp. Rail-only environments use a rounded-ended left line. All are
breakable. `slogan` is unnumbered and deliberately retains a sharp full frame.

`proof` uses a quiet left rail. Inside it, `step` and `case` restart at one
for each proof while separate internal counters keep their hyperlink anchors
unique:

```tex
\begin{proof}
  \begin{step}[Construct the map]\label{step:construct}
    Use the universal property.
  \end{step}
  \begin{case}[The affine case]\label{case:affine}
    Compute on rings.
  \end{case}
\end{proof}
```

`proof`, `step`, `case`, and `slogan` are presentation helpers rather than
publication-tagged statement wrappers. Ordinary `\label` works for `step` and
`case`.

## Permanent Tags

A theorem number records a current location. A tag records the permanent
identity of published mathematical content. Tags are ordinary searchable and
copyable PDF text.

### Tag Hierarchy

Tags use uppercase ASCII letters and digits:

| Length | Identifies | Example |
| ---: | --- | --- |
| 1 | Book/repository | `A` |
| 3 | Chapter | `A01` |
| 5 | Section | `A01B2` |
| 7 | Subsection or theorem-like entry | `A01B2C3` |

Each child begins with its parent's complete tag and appends two base-36
characters. Subsections are referenceable items, not a new allocation scope;
they share a section's seven-character pool with theorem-like entries.

The prefix records allocation origin. If an unchanged theorem moves, it keeps
its original tag even though the current chapter, section, and theorem number
change.

### Status and Publication Rules

- A section containing any draft mathematical content is itself a draft
  section. Publication normally proceeds section by section, or as a chapter or
  book composed from published sections.
- A draft entry may omit its tag. A supplied draft tag is provisional, appears
  as `Draft tag ...` in its heading, and is not globally reserved.
- A published entry requires both a tag and a source label.
- Every statement inside a published scope must explicitly use
  `status=published`; an accidental draft statement makes the build fail.
- A published theorem-like tag must be active in the loaded TeX registry and
  must match its book, environment type, and source label.
- LaTeX validates format and local consistency. The external allocation tool is
  responsible for global uniqueness across repositories and for detecting
  duplicate provisional allocations before publication.
- A mathematically or semantically changed item receives a new tag. Pure
  formatting, typo, or meaning-preserving wording changes do not require one.
- A retired tag is never reused. Its frozen record remains queryable and points
  to its replacement.

### Tagging Statements

The optional argument accepts either the traditional title or a key list:

```tex
\begin{theorem}[
  title={Fundamental comparison},
  status=published,
  tag=A01B2C3,
  label=thm:fundamental-comparison
]
  The statement goes here.
\end{theorem}
```

`title` is optional. A legacy draft title remains valid:

```tex
\begin{lemma}[A legacy optional title]
  The statement goes here.
\end{lemma}
```

The metadata-aware environments are `definition`, `proposition`, `theorem`,
`lemma`, `corollary`, `conjecture`, `question`, `remark`, `claim`, `example`,
`exercise`, `construction`, `notation`, and `mainthm`.

### Tagging Divisions

Chapters, sections, and subsections accept the same publication keys plus an
optional short title:

```tex
\section[
  short-title={Comparison},
  status=published,
  tag=A01B2,
  label=sec:comparison
]{A comparison theorem and its applications}
```

Traditional `\section[Short title]{Long title}` syntax and starred divisions
remain available. Chapter and section metadata update the current tag/status
scope. A subsection is referenceable but does not open a new status scope.
Published division tags are checked for length and parent prefix; the external
allocator remains the authority for their global uniqueness.

### Registry and Retired Tags

Load the repository's generated or maintained registry before the document:

```tex
\LoadNoteTagRegistry{tag-registry.tex}
```

An active statement record has stable identity fields:

```tex
\DeclarePublishedTag{
  tag=A01B2C3,
  book-tag=A,
  chapter-tag=A01,
  section-tag=A01B2,
  book={Notes in Algebraic Geometry},
  type=theorem,
  label=thm:fundamental-comparison
}
```

A retired record adds its last published number and replacement:

```tex
\DeclareRetiredTag{
  tag=A01B2C2,
  book-tag=A,
  chapter-tag=A01,
  section-tag=A01B2,
  book={Notes in Algebraic Geometry},
  type={Theorem},
  label=thm:old-comparison,
  number=3.1.2,
  replacement=A01B2C3
}
```

Print a frozen record with `\NoteTagRecord{A01B2C2}`. The class requires every
declared replacement to exist, but redirect-chain and cycle validation belongs
to the external registry tool.

## References Between Documents

Local published references have the form:

```text
Theorem 3.1.2 (Tag A01B2C3)
```

A cross-repository reference includes the source book:

```text
[Notes in Algebraic Geometry, Theorem 3.1.2, Tag A01B2C3]
```

A draft local reference is simply `Theorem 3.1.3`. Draft external records use
their available structural locator and never claim a permanent tag.

Version 2.0 defines singular custom `\cref` output. Use one tagged/draft label
per `\cref` call; plural and range formatting for the custom reference records
is a possible later extension.

### Direct Auxiliary-File References

Every build writes its ordinary `.aux` file and a companion `.nfm-xref` file.
The first keeps references inside the same book compact; the companion stores
the book-qualified text needed by an external consumer.

After compiling `template_book.tex`, another document can use:

```tex
\externalnotedocument[source]{template_book}
...
\cref{source:thm:published-comparison}
```

The optional first argument adds a namespace. The optional final argument is an
`xr-hyper` URL prefix:

```tex
\externalnotedocument[ag]{path/to/book}[https://example.com/book.pdf]
```

This direct method is useful for local experiments. The catalog workflow below
is the durable method for repositories whose sections are not all compiled on
one machine.

### Repository Catalogs

`labels-ref-sync` exchanges validated JSON rather than downloaded TeX source:

1. A repository publishes one `external-labels.json` catalog. Every source
   label occurs once and records its display text, tag/status, PDF anchor, and
   full owning-document URL.
2. `fetch` downloads configured catalogs into tracked JSON snapshots.
3. `sync` validates the data, creates safe TeX record shards under
   `label-references/records/`, and writes one short `external-labels.tex`
   beside every wrapper.
4. The program inserts a managed `\InputIfFileExists{external-labels.tex}`
   block before `\begin{document}`.

For a section target, its own records are excluded. A chapter excludes records
owned by its included sections, and a book excludes its entire repository.
This prevents a local label and an imported copy from being defined twice.

Same-repository labels keep their source spelling, for example
`\cref{thm:comparison}`. Cross-repository labels receive the configured prefix,
for example `\cref{ag:thm:comparison}`.

### Manifest Configuration

Configure this repository's released catalog at the top level of `notes.json`:

```json
{
  "referenceCatalog": {
    "file": "external-labels.json",
    "downloadUrl": "https://example.com/releases/external-labels.json"
  }
}
```

`file` is the artifact created by `release`. `downloadUrl` is the address used
by local `fetch`; it may be a GitHub Release asset or another stable HTTP(S)
location. It is separate from the public PDF routes stored inside the catalog.

Add other note repositories under `externalReferences`:

```json
{
  "externalReferences": [
    {
      "prefix": "ag",
      "downloadUrl": "https://example.com/algebraic-geometry/external-labels.json"
    },
    {
      "prefix": "cg",
      "downloadUrl": ""
    }
  ]
}
```

An empty download URL is an inactive placeholder and is skipped with a warning.
Prefixes must be unique lowercase slugs and prevent identical source labels in
different repositories from colliding.

### Local Workflow

The normal author workflow is:

```console
./accessories/labels-ref-sync fetch
# Edit and compile the current section, chapter, or book.
./accessories/labels-ref-sync sync
./accessories/labels-ref-sync validate
git add notes.json label-references chapters
```

`fetch` downloads both the repository's last published self catalog and all
configured external catalogs, then runs `sync`. Available local compilation
outputs overlay their downloaded records; uncompiled documents continue to use
the published snapshot.

The `label-references/` tree, per-directory `external-labels.tex` files, and
managed wrapper blocks are intentionally tracked. A clean checkout can
therefore compile one section without first compiling every sibling section.

### Release Workflow

For a first complete release, compile every wrapper and run:

```console
./accessories/labels-ref-sync release
./accessories/labels-ref-sync validate
```

The default public base is
`https://www.tianleyang.com/<book.id>/`, combined with each relative PDF route
from `notes.json`. Override it when necessary:

```console
./accessories/labels-ref-sync release \
  --base-url https://example.com/my-note/
```

`--allow-missing` is intended only for development; publication should not omit
uncompiled documents.

An incremental GitHub Actions build supplies the previously published catalog
and a newline-separated list of wrappers compiled in that run:

```console
./accessories/labels-ref-sync release \
  --previous label-references/catalogs/self.json \
  --documents-file .reference-build-documents
```

Records owned by rebuilt wrappers are replaced or removed; untouched records
remain in the release. The intended division of responsibility is simple:
local development performs `fetch` and `sync` and commits their output; CI
compiles the selected wrappers, runs `release`, and uploads the PDFs plus the
single catalog artifact.

## Management Programs

### `labels-ref-sync`

```text
sync       regenerate tracked record shards and per-wrapper imports
fetch      download configured catalogs, then synchronize
update     alias for fetch
validate   validate catalogs, labels, and generated files
release    create or incrementally merge external-labels.json
```

Pass `--dry-run` before the subcommand to inspect changes. Set
`MANAGE_REFERENCES_ROOT` when the script cannot infer the consuming note
repository; `MANAGE_NOTES_ROOT` is accepted as a fallback.

### `manage-notes`

`manage-notes` maintains the `notes.json` hierarchy and generated wrapper
regions. Its commands are:

```text
list
validate
sync
create chapter|section
delete
rename
move
retitle
set-status
```

It must run in the context of a consuming note repository. Set
`MANAGE_NOTES_ROOT=/path/to/repository` when automatic submodule detection is
not available. Use `--dry-run` for a preview and `--yes` only when an intended
mutation would otherwise ask for confirmation.

## Development

Run the synchronizer tests from this repository root:

```console
python3 -m unittest -v tests.test_labels_ref_sync
```

Build all class examples from their directory:

```console
cd templates-of-latex/noteformyself
latexmk -xelatex template_book.tex
latexmk -xelatex template_chapter.tex
latexmk -xelatex template_section.tex
latexmk -xelatex template_crossref.tex
```

The book template contains two disabled negative tests. Define
`\NFMTestMissingTag` or `\NFMTestDraftInPublished` on the command line to verify
that strict publication checks fail as intended.

## License

See [`LICENSE`](LICENSE).
