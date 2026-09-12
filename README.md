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
- [Implementation Guide](#implementation-guide)
  - [Reading the Internal Names](#reading-the-internal-names)
  - [The Tag Pipeline in the Class](#the-tag-pipeline-in-the-class)
  - [Reference Files Written by the Class](#reference-files-written-by-the-class)
  - [The `labels-ref-sync` Pipeline](#the-labels-ref-sync-pipeline)
  - [Responsibility Boundary](#responsibility-boundary)
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
│   ├── test_labels_ref_sync.py
│   └── test_manage_notes.py
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
stable IDs, ordering, wrapper paths, statuses, structural tags and labels, and
public PDF routes.

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
- automatic draft watermarks;
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
Selecting `status=draft` on `\documentclass` automatically loads
`draftwatermark` for the complete output. A later `\notesetup{status=...}` call
changes publication validation scope but does not toggle the document-level
watermark.

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

\section[
  status=draft,
  tag=A01B2,
  label=\labelNFM{sec:introduction}
]{Introduction}

\begin{theorem}[title={Comparison},label=\labelNFM{thm:comparison}]
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
| Ordinary mathematics, `\mathbb`, and `\mathfrak` | Libertinus Math |
| `\mathcal` | STIX Two Math |
| `\mathscr` | STIX Two Math stylistic set 1 |

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

The length identifies the kind of item. An allocator may use parent prefixes to
record where a permanent tag was first assigned, but the live document does
not require a tag to begin with its current parent's tag. If a chapter,
section, or theorem moves, it keeps its original tag even though its current
location and number change. Registry records may still retain the original
allocation hierarchy.

### Status and Publication Rules

- A section containing any draft mathematical content is itself a draft
  section. Publication normally proceeds section by section, or as a chapter or
  book composed from published sections.
- A draft entry may omit its tag. A supplied draft tag is provisional, appears
  as `Draft tag ...` in its heading, and is not globally reserved.
- A visible heading tag stays together as one unit, but may move as a whole to
  the next line when it does not fit after the title.
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
  label=\labelNFM{thm:fundamental-comparison}
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

Wrap statement and division metadata labels in `\labelNFM{...}`. The command is
an expandable bridge: the class receives the plain label name, while TexLab can
recognize the label definition when
`texlab.experimental.labelDefinitionCommands` includes `"labelNFM"`. Continue
to use ordinary `\label{...}` for equations, proof steps, cases, listings, and
other standard LaTeX constructs. Registry records store label names for
validation rather than define labels, so their `label` fields remain plain.

### Tagging Divisions

Chapters, sections, and subsections accept the same publication keys plus an
optional short title:

```tex
\section[
  short-title={Comparison},
  status=published,
  tag=A01B2,
  label=\labelNFM{sec:comparison}
]{A comparison theorem and its applications}
```

Traditional `\section[Short title]{Long title}` syntax and starred divisions
remain available. Chapter and section metadata update the current tag/status
scope. A subsection is referenceable but does not open a new status scope.
Published division tags are checked for length, but not against the current
parent tag. The external allocator remains the authority for permanent-tag
uniqueness and allocation history.

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
    "downloadUrl": "https://www.tianleyang.com/algebraic-geometry/external-labels.json"
  }
}
```

`file` is the artifact created by `release`. `downloadUrl` is the stable address
used by local `fetch`. The five note repositories publish this file through
GitHub Pages beside their PDFs. It is separate from the individual PDF routes
stored inside the catalog.

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
compiles the selected wrappers, runs `release`, and deploys the PDFs plus the
single catalog through GitHub Pages.

The Pages workflow runs automatically on every push to `main` and may also be
started manually. The first catalog build compiles every wrapper because no
previous ownership map exists. After that deployment, run
`labels-ref-sync fetch` locally and commit
`label-references/catalogs/self.json` together with
its record files. Once this published ownership map is tracked, later runs
compare with the last deployed commit and compile only affected wrappers. If
the self catalog is absent, CI deliberately falls back to a full build.

There is intentionally no GitHub Release for each push. Pages provides one
predictable current URL, matches the PDF host, and does not create an unbounded
sequence of release tags. A GitHub Release remains appropriate for an explicit
versioned or archival snapshot, but it is not needed by routine reference
synchronization. The workflow has read-only repository-content permission and
contains no release-creation step, so a successful Pages deployment does not
create a GitHub Release. Each catalog includes its source Git revision for
provenance.

## Implementation Guide

This section explains the two longer implementations: the tag subsystem in
`noteformyself.cls` and the `labels-ref-sync` program. Their public commands are
small; most of the code preserves old LaTeX syntax, produces useful errors,
keeps internal and external references different, and treats downloaded data
as untrusted input.

### Reading the Internal Names

The tag subsystem uses LaTeX3 naming conventions. Once these prefixes and
suffixes are familiar, the long names describe their own scope and data type:

| Form | Meaning |
| --- | --- |
| `nfm` | Private module prefix for `noteformyself` |
| `g_...` | Global state retained across sections |
| `l_...` | Local working state for the current entry |
| `..._tl` | Token list, used like a string |
| `..._prop` | Property list, used like a dictionary |
| `..._seq` | Ordered sequence |
| `..._iow` | Output stream for writing a file |
| `\function:nn`, `\function:Nn` | Function argument types after the colon |

For example, `\g_nfm_section_tag_tl` is the global current section-tag string,
while `\l_nfm_statement_label_tl` is the label being processed for one
statement.

### The Tag Pipeline in the Class

The class performs the following work during one XeLaTeX compilation:

```text
optional theorem/division argument
              │
              ▼
 parse metadata keys and expand \labelNFM
              │
              ▼
 validate status, tag format, and registry record
              │
              ▼
 call the original theorem or division command
              │
              ▼
 write local .aux data and external .nfm-xref data
```

The implementation is divided into these blocks:

1. **Scope state and `\notesetup`.** Global token lists remember the book name,
   the current 1/3/5-character tags, and whether the current section is draft
   or published. `\nfm_validate_context:` checks tag lengths whenever the scope
   changes; it does not compare a moved item with its current parent.
2. **Diagnostics.** Named messages centralize errors for malformed tags,
   missing metadata, draft content in a published scope, unknown or retired
   tags, and registry mismatches. Keeping messages separate makes validation
   functions shorter and gives authors actionable compilation errors.
3. **Registry storage.** `\DeclarePublishedTag` and `\DeclareRetiredTag` parse a
   record and store each field in a property list keyed by the permanent tag.
   Active records bind tag, book, type, and source label. Retired records also
   retain their last number and replacement. At the beginning of the document,
   each immediate replacement is required to exist.
4. **Statement wrapper.** The original `amsthm` begin/end commands are saved,
   then each supported environment is redefined through one generic wrapper.
   `\nfm_statement_parse:n` accepts either an old-fashioned optional title or
   the `title`, `status`, `tag`, and `label` keys. The `label` key expands
   `\labelNFM{...}` to the plain source-label string before preparation
   validates the entry and builds the visible heading tag. The original
   environment then performs numbering and typesetting.
5. **Statement references.** After the original environment advances its
   counter, `\nfm_make_statement_reference:nn` builds two cleveref displays: a
   compact local form such as `Theorem 3.1.2 (Tag A01B2C3)` and a book-qualified
   external form. `\noteformyselfstatementlabel` installs that custom cleveref
   record immediately before ordinary `\label` data is written.
6. **Division wrapper.** Chapters, sections, and subsections follow the same
   parse–validate–write sequence. A chapter updates the current chapter and
   clears the section; a section updates the current section and publication
   scope; a subsection is referenceable but does not open a new scope.
7. **Imported records.** `\NoteImportedReference` installs already-validated
   label and cleveref records generated by the external program.
   `\externalnotedocument` provides the simpler direct `.aux`/`.nfm-xref`
   mechanism, and `\NoteTagRecord` prints an active or frozen retired record.

Published statements are checked against the registry by book, environment
type, and source label. Their current chapter and section are deliberately not
compared with the allocation prefix: an unchanged statement may move and keep
its permanent tag. Deciding whether a mathematical change requires a new tag
remains an author decision; the class cannot infer semantic equivalence.

### Reference Files Written by the Class

Every normal `\label` writes an ordinary `.aux` entry containing its number,
page, and exact Hyperref PDF destination. The class also writes a companion
`.nfm-xref` entry for metadata-aware labels:

| File | Intended consumer | Display style |
| --- | --- | --- |
| `<job>.aux` | The same book or direct `xr-hyper` import | No book prefix |
| `<job>.nfm-xref` | Another independently compiled document | Includes book name |

The PDF destination is opaque: values such as `definition.12` and
`construction*.303` must be preserved exactly. The destination and page must
come from the PDF being linked, whereas the displayed number may come from the
complete book build.

### The `labels-ref-sync` Pipeline

`labels-ref-sync` runs outside LaTeX and knows about every wrapper listed in
`notes.json`. Its source follows the data from parsing to command dispatch:

1. **Constants and data models.** Regular expressions define the accepted
   manifest, label, counter, URL, and PDF-anchor syntax. `NoteDocument`,
   `RemoteRepository`, and `ReferenceCatalog` hold normalized configuration.
2. **Manifest parsing.** `documents()` converts the nested book/chapter/section
   tree into one ordered list of independently compilable wrappers. Paths,
   identities, public PDF routes, catalog settings, and remote prefixes are
   validated before any generated file is changed.
3. **Restricted TeX parsing.** `parse_commands()` and `parse_braced()` read only
   the expected `\newlabel` and `\NoteExternalReference` records. General TeX
   is never evaluated. Display text and anchors pass strict allowlists; the only
   recognized formatting markup is the class-generated monospace tag.
4. **Record extraction.** `reference_records()` joins each ordinary label with
   its cleveref record and optional external display. It extracts the number,
   page, anchor, status, and tag into plain Python dictionaries.
5. **Ownership resolution.** A label may appear in its section, chapter, and
   book builds without being a duplicate. `combine_reference_occurrences()`
   chooses the smallest independently published PDF as owner—normally the
   section—but prefers the book build for canonical numbering and display.
   Two occurrences in equally small independent sections are a real duplicate
   and fail.
6. **Catalog validation.** `validate_catalog()` requires a supported schema,
   unique document IDs, one occurrence of each source label, absolute HTTP(S)
   PDF URLs, valid anchors, and a tag on every published record.
7. **Materialization.** Validated JSON is converted into small trusted
   `\NoteImportedReference` shards. Text is escaped before TeX is written;
   published tag values are restored in the configured monospace font.
8. **Per-wrapper imports.** `target_import_text()` creates the short
   `external-labels.tex` beside every wrapper. A section excludes itself, a
   chapter excludes labels already contained in that chapter, and a book
   excludes its whole repository. Remote repositories are always imported with
   their configured namespace.
9. **Commands.** `fetch` downloads and validates self/remote catalogs before
   replacing tracked snapshots; `sync` regenerates shards and imports;
   `validate` proves tracked generated files are current; and `release` creates
   the public catalog from compiled outputs.

For an incremental release, the previous catalog is the ownership baseline.
Records from recompiled wrappers replace or remove their old versions, while
unaffected records retain the page, anchor, and URL belonging to the previously
deployed PDF. This is why a push can rebuild one section without invalidating
links to every other section.

### Responsibility Boundary

The class and program intentionally enforce different invariants:

| Responsibility | `noteformyself.cls` | `labels-ref-sync` |
| --- | :---: | :---: |
| Typeset tags and customize `\cref` | Yes | No |
| Validate one published entry against a loaded registry | Yes | No |
| Write `.aux` and `.nfm-xref` | Yes | No |
| Read all independently compiled wrappers | No | Yes |
| Detect duplicate labels across sections | No | Yes |
| Choose PDF owner, page, anchor, and URL | No | Yes |
| Download and namespace other repositories | No | Yes |
| Allocate globally unique tags | No | Not yet |
| Detect mathematical/semantic change | No | No |

The remaining tag-management stage is a global allocator/registry tool. It
must reserve book, chapter, section, subsection, and entry tags across all five
repositories; reject reuse; and validate retirement chains and cycles. The
current class consumes that registry, while `labels-ref-sync` distributes the
resulting references.

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
regions. Generated wrappers use explicit `sectionlevel` and `status` class
options, plain titles without a `(draft)` suffix, and key-value chapter and
section metadata. The manifest's `published` field selects `status=draft` or
`status=published`; `finished` remains an independent progress indicator.

Chapter and section records receive stable source labels when synchronized.
New chapters automatically receive the placeholder tag `000`, and new sections
receive `00000`; creation does not prompt for either tag. The manager validates
tag length and characters, but does not require parent tags, compare prefixes,
or require placeholder tags to be unique. Tags and generated labels are both
retained when an item is renamed or moved.

The commands are:

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

Creation works without tag input. Use `--tag` only to override a placeholder,
or use `set-status --tag` later:

```console
manage-notes create chapter "Schemes"
manage-notes create section 1 "Affine schemes"
manage-notes set-status 1 --tag A01
manage-notes set-status 1.1 --published 1 --finished 1 --tag Q72M4
```

Running `manage-notes sync` migrates existing wrappers: it adds the class status
and managed `\notesetup` block, removes legacy `draftwatermark` package lines,
and rewrites managed divisions with `\labelNFM{...}` metadata.

It must run in the context of a consuming note repository. Set
`MANAGE_NOTES_ROOT=/path/to/repository` when automatic submodule detection is
not available. Use `--dry-run` for a preview and `--yes` only when an intended
mutation would otherwise ask for confirmation.

## Development

Run all management and synchronizer tests from this repository root:

```console
python3 -m unittest discover -s tests -v
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
