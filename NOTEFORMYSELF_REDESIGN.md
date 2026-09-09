# `noteformyself` Redesign Journal

> Temporary working document. Keep this file while the redesign is in progress
> and remove it after the revised class, documentation, and migration work are
> complete.

## Status

- Stage: TeX tag-system prototype implemented and under review
- Started: 2026-09-09
- Target: [`templates-of-latex/noteformyself/noteformyself.cls`](templates-of-latex/noteformyself/noteformyself.cls)
- Visual reference: [`tomb_of_typst/260315/note_for_myself.typ`](tomb_of_typst/260315/note_for_myself.typ)
- Current implementation: publication-aware theorem and structural metadata,
  searchable PDF tags, local and cross-document `\cref` formats, a small
  external TeX registry fixture, and strict per-entry publication diagnostics

## Goals

1. Add a permanent tag system for theorem-like environments.
   - Every published theorem-like entry has a globally unique tag displayed as
     searchable text in the compiled PDF.
   - A published tag must continue to identify the same mathematical item even
     if the note is reorganized or its ordinary theorem number changes.
   - Tags must work across the separate note repositories that use this class.
   - The design should be inspired by the Stacks Project tag system.
   - Published tags are stored in an external global index that can be queried.
   - Cross-repository references use source labels and display either the
     permanent tag or a structural locator, depending on publication status.
2. Redesign the title page.
   - Use the Typst template as a visual and structural reference, not necessarily
     as a pixel-for-pixel specification.
   - Make the implementation easier to read, customize, and maintain.
   - Avoid duplicating the same title-page implementation for `book` and
     `chapter` modes.
3. Adopt a clear, readable, open-source font set.
   - Choose compatible text and mathematics fonts.
   - Decide how Latin, mathematics, and CJK text should fall back on systems
     where not every preferred font is installed.
   - Remove defaults that depend on proprietary fonts.
4. Collect and evaluate further redesign ideas during discussion without
   silently changing established behavior.

## Design Principles

- Stable identity and displayed theorem numbering are separate concepts.
- Published identifiers are immutable; corrections should create an explicit
  redirect or deprecation record rather than silently reusing a tag.
- A tag should not depend on a mutable file path, section number, or theorem
  number. If its characters reflect a hierarchy, they record the allocation
  origin and do not change automatically when content moves.
- Existing note repositories need a practical migration path.
- The class interface should be small, documented, and consistent in all three
  section modes: `section`, `chapter`, and `book`.
- Missing optional assets or fonts should produce useful diagnostics and a
  readable fallback document.
- Visual choices should remain legible in print, grayscale, and on screen.

## Current Baseline

The current class already provides:

- `section`, `chapter`, and `book` modes;
- a shared counter for most theorem-like environments;
- colored `tcolorbox` theorem and proof styles;
- `cleveref` names for theorem-like environments;
- separate title-page branches for `chapter` and `book` modes;
- cover metadata such as author, homepage, image, sentence, version, and source;
- a layered mathematics-font configuration with several system-dependent
  fallbacks.

Known areas to revisit:

- the `chapter` and `book` cover code is largely duplicated;
- the default cover title font is Arial, which does not meet the open-source
  font goal;
- examples rely on fonts or paths that may not exist in a fresh checkout;
- global registry allocation and duplicate checking still need the external
  management tool planned for the next step;
- title-page and font work has not started.

## Decisions

| Date | Decision | Reason | Consequences |
| --- | --- | --- | --- |
| 2026-09-09 | Published entry tags are globally unique across all note repositories. | A tag must find an entry without first knowing its repository. | One central authority must allocate or validate tags. |
| 2026-09-09 | Tags appear as searchable text in compiled PDFs. | Readers must be able to find and copy them. | A tag cannot exist only as hidden PDF metadata or a hyperlink target. |
| 2026-09-09 | Every theorem-like entry type is eligible, including examples, exercises, remarks, constructions, and notation entries. | The index should cover all referenceable mathematical content consistently. | The implementation must share metadata behavior across all these environments. |
| 2026-09-09 | Only published tags are recorded in the external global index. | Draft tags are provisional. | Draft tags confer no reservation or uniqueness guarantee. |
| 2026-09-09 | A published entry that changes receives a new tag; the old tag is retired and never reused. | A tag identifies fixed published content. | The registry needs active and retired states, and preferably a `supersededBy` relation. |
| 2026-09-09 | A published scope fails validation when an eligible entry has a missing, duplicate, malformed, or unregistered tag. | Publication must not produce ambiguous or incomplete permanent references. | Draft builds and publication builds need different validation strictness. |
| 2026-09-09 | Cross-repository references are written using source labels. | Existing notes already use semantic labels extensively. | Labels need repository namespaces when imported to avoid collisions. |
| 2026-09-09 | A cross-repository reference to a published entry includes its tag; a reference to a draft entry uses a structural locator. | Published identity is permanent, while a draft has only a current location. | Auxiliary reference data must include publication and location metadata. |
| 2026-09-09 | Hierarchical tags use lengths 1, 3, 5, and 7 for books, chapters, sections, and section-level items, using uppercase alphanumeric characters. Subsections and theorem-like entries share the seven-character pool. | A subsection needs a permanent reference but is not another allocation or publication scope. | Each section can contain up to 1,296 globally unique subsection/entry tags in a shared base-36 pool. |
| 2026-09-09 | Publication occurs at section granularity or at a larger chapter/book scope composed of published sections. | A mixed section is still a draft section. | Strict tag validation is activated by the publication status of the compiled scope. |
| 2026-09-09 | Draft sections do not fail tag-uniqueness validation. | Provisional draft tags are not reservations in the global registry. | Conflicts must be resolved before the section is published. |
| 2026-09-09 | Only mathematical or semantic changes retire a tag. | Typographical, formatting, and meaning-preserving wording changes do not change the identified mathematical content. | Publication validation cannot rely only on a byte-for-byte source hash. |
| 2026-09-09 | Provisional tags are visibly marked as draft tags. | Readers should not mistake an unregistered identifier for a permanent published tag. | Published and provisional tag badges need distinct wording or styling. |
| 2026-09-09 | A published theorem heading displays its tag after the title, for example `Theorem 1.2.3 (Fundamental comparison) (Tag 0ABCDEF)`. | The tag must be visible and searchable at the entry itself. | The heading renderer must handle titled and untitled entries without awkward spacing. |
| 2026-09-09 | A published cross-repository reference displays book, current theorem number, and tag, for example `[Book, Theorem 3.1.24, Tag 0ABCDEF]`. | The theorem number is convenient for reading while the tag supplies permanent identity. | Exported metadata must contain the book name, current number, environment type, and tag. |
| 2026-09-09 | Moving a mathematically unchanged statement retains its original tag. | The tag identifies content, not a live address. | The hierarchical prefix records allocation origin and may differ from the current section. |
| 2026-09-09 | Retired tags remain queryable as frozen records and point to a replacement; no tag URL is added yet. | Old citations must continue to resolve without prematurely fixing a web architecture. | The registry stores the last published number and a replacement tag. |
| 2026-09-09 | Titles are optional for every theorem-like entry, including published theorems. | Many existing statements have no useful short title. | `title={...}` is an optional metadata key, not part of tag identity. |
| 2026-09-09 | Internal published references use `Theorem 1.1.1 (Tag 0ABCDEF)`; internal draft references use plain `Theorem 1.1.2`. | Repeating the book inside its own PDF is noisy. | Book-qualified bracketed references are reserved for imports from another repository. |
| 2026-09-09 | Global uniqueness and duplicate-use validation belong to an external tool rather than the LaTeX class. | The authority spans repositories and is easier to maintain outside TeX. | The current class validates each published entry against a loaded registry, while allocation tooling is deferred to the next step. |
| 2026-09-09 | Published chapters, sections, and subsections display their tags and include them in local and external `\cref` output. | Structural locations are themselves useful stable reference targets. | Their metadata syntax mirrors theorem metadata, while subsection metadata does not change the section status inherited by entries. |
| 2026-09-09 | Every repository releases a self-contained cross-reference export containing labels, display records, and public target URLs. | Consumers should not need the source repository's build tree or reconstruct its website routes. | A release script combines TeX metadata with the repository manifest and writes canonical per-label URLs. |
| 2026-09-09 | Cross-document reference management is a separate root-level `labels-ref-sync` program rather than part of `manage-notes`. | Reference exchange has its own lifecycle and should remain independently usable. | The program owns synchronization, catalog download, release, and validation commands. |
| 2026-09-09 | A released label links to its smallest compiled owner, normally a section PDF, but uses numbering from the full book build when available. | Section PDFs need valid local anchors while citations should retain canonical book numbering. | The generated record combines address fields from the owner build with display fields from the aggregate build. |
| 2026-09-09 | Locally fetched, Git-tracked catalog snapshots are the build baseline for same-repository and cross-repository references. | A local checkout does not compile every independent document, while CI should not depend on downloading mutable label state. | `fetch` updates `label-references/catalogs/`; `sync` writes tracked record shards and wrapper imports; local outputs overlay documents that are actually compiled. |
| 2026-09-09 | Incremental CI catalog publication merges rebuilt documents into the tracked self snapshot and performs no fetch or sync. | Requiring every document to compile or downloading catalogs during every deployment would complicate the existing incremental PDF workflow. | Removed labels disappear from rebuilt owners, unchanged owners remain available, and a missing self snapshot forces a full first build. |
| 2026-09-09 | The synchronizer is named `labels-ref-sync`, and every wrapper imports a nearby file named `external-labels.tex`. | `manage-references` was easily confused with `manage-notes`, while wrapper-derived generated filenames were unnecessarily long. | Existing managed wrapper blocks and generated import files are migrated during synchronization. |
| 2026-09-09 | Catalog artifact names and download locations are separate manifest fields. | A GitHub Release asset or Pages URL may change without changing the public PDF route. | `referenceCatalog.file` selects the release output; self and external `downloadUrl` values are used only by local `fetch`, and an empty external value is an inactive placeholder. |

## Open Design Questions

### 1. Permanent tag model

The approved shape is hierarchical and prefix-based:

- one character identifies a book/repository;
- three characters identify a chapter;
- five characters identify a section;
- seven characters identify a subsection or theorem-like entry.

For example, `A`, `A01`, `A01B2`, and `A01B2C3` identify a book, chapter,
section, and entry respectively. Tags use uppercase alphanumeric characters and
are validated against `[0-9A-Z]` at their required fixed length.

#### Capacity

Each lower level adds two base-36 characters. This gives:

- 36 globally registered book codes;
- 1,296 chapter codes within each book;
- 1,296 section codes within each chapter;
- 1,296 subsection/entry codes within each section, shared between both kinds.

This comfortably covers the current maximum of 55 taggable entries in one
section. The registry, rather than numeric chapter or section order, allocates
each two-character component.

An unchanged move keeps the same tag. The book/chapter/section prefix therefore
records where the tag was allocated, not necessarily where the statement lives
today. A retired tag remains a frozen record and points to its replacement. The
release-file URL architecture is implemented in the first reference-manager
version; global tag allocation remains the next external-tool phase.

Implemented author-facing syntax:

```tex
\begin{theorem}[
  title  = {Fundamental comparison},
  label  = {thm:fundamental-comparison},
  status = published,
  tag    = {A01B2C3},
]
  ...
\end{theorem}
```

Existing title-only syntax should remain valid for draft entries:

```tex
\begin{theorem}[Fundamental comparison]
  \label{thm:draft-result}
  ...
\end{theorem}
```

An untitled statement simply omits `title`:

```tex
\begin{theorem}[
  status = published,
  tag    = {A01B2C3},
  label  = {thm:comparison},
]
  ...
\end{theorem}
```

The final API should avoid confusing permanent tags with LaTeX's existing
`\tag` command for equation numbers.

Tagged structural commands use the same keys. Their ordinary optional argument
remains available as a legacy short title; metadata mode also offers an explicit
`short-title` key:

```tex
\chapter[status=published, tag=A01, label=chap:foundations]
  {Foundations}
\section[status=published, tag=A01B2, label=sec:comparison]
  {Comparison theorems}
\subsection[status=published, tag=A01B2C3, label=subsec:derived]
  {Derived comparison}
```

The chapter and section commands update the current scope metadata. A subsection
is only a tagged reference target and does not change the status or tag context
used by following theorem-like entries.

### 2. Publication status and validation

The neighboring structured repositories already have a `notes.json` manifest
with `published` and `finished` flags for books, chapters, and sections. This is
useful for selecting validation strictness, but it is not enough by itself: a
draft section may contain a published entry A and a draft entry B.

Approved two-level model:

1. **Scope/build status:** reuse the manifest's book/chapter/section publication
   status. Publication is performed one section at a time, or for a chapter/book
   whose included sections are all publishable. A publishing build requires
   every eligible entry in its scope to be registered and tagged; a draft build
   permits provisional entries and does not enforce tag uniqueness.
2. **Entry status:** record `published` or `draft` on each entry. A published
   entry requires a registered tag. A draft entry may have no tag or an
   unregistered provisional tag.

This answers the need for a status variable: status is required per entry, while
the manifest supplies the status of the compiled scope. An entry without
explicit status defaults to `draft`. A provisional tag is displayed as
`Draft tag A01B2C3`, not as a published tag.

The prototype makes TeX fail immediately for a missing, malformed, unknown,
retired, or registry-mismatched published entry, and for a draft entry found in
a published scope. Cross-repository uniqueness and duplicate-use checks are
reserved for the external registry tool in the next step.

### 3. External registry

The final registry should be machine-readable and remain the canonical global
record. Its management commands and storage location are the next design step.
A possible record remains:

```json
{
  "tag": "A01B2C3",
  "status": "active",
  "repository": "algebraic-geometry",
  "chapter": "schemes-and-varieties",
  "section": "definition-and-first-properties",
  "type": "theorem",
  "label": "thm:fundamental-comparison",
  "source": "chapters/.../text.tex",
  "url": "...",
  "supersededBy": null
}
```

The existing `manage-notes` program and `notes.json` manifests already know
repository IDs, stable chapter/section IDs, TeX paths, URLs, and publication
status. Extending this workflow is preferable to asking TeX alone to discover
and validate every repository.

Likely division of responsibility:

| Component | Responsibility |
| --- | --- |
| Central JSON index | Canonical allocation, active/retired state, label-to-tag lookup, current location |
| Generated TeX index | Lets the class check registered tags during compilation |
| Generated `.nfm-xref` file | Supplies publication-aware `cleveref` display metadata alongside each compiled `.aux` file |
| Released `external-labels.json` | Exports validated labels, display records, tags, owning-document URLs, and PDF anchors |
| `labels-ref-sync` | Synchronizes local imports, downloads namespaced catalogs, creates releases, and detects duplicate source labels |
| Future tag-registry tool | Allocates global tags and fails publication on global tag conflicts or invalid retirement records |

Open question for the next step: should the canonical registry live in this
`accessories-tex` repository or in a small dedicated registry repository?

### 4. Cross-repository references

The compiled `algebraic-geometry.aux` already contains both ordinary `\newlabel`
records and the corresponding `@cref` records. The prototype supplements these
with `.nfm-xref` metadata. For publication, each repository will release a
self-contained cross-reference export so consumers do not depend on its local
`.aux` path. A repository prefix is still necessary to prevent two books from
exporting the same label.

A basic import could look like:

```tex
\externalnotedocument[ag]{../algebraic-geometry/algebraic-geometry}

See \cref{ag:thm:fundamental-comparison}.
```

The approved published-reference form is:

```text
[Book, Theorem 3.1.24, Tag 0ABCDEF]
```

Here `Book` is replaced by the configured short or full book name. The ordinary
theorem number gives a convenient current location, while the tag supplies the
permanent identity. An external draft reference uses a structural locator such
as `[Book, Chapter 1, Section 2, Theorem 2]`.

Within the source book, published and draft references are deliberately shorter:

```text
Theorem 1.1.1 (Tag 0ABCDEF)
Theorem 1.1.2
```

The prototype keeps the ordinary compact record in `.aux` and writes a generated
`.nfm-xref` companion containing the book-qualified form. `\externalnotedocument`
imports both, so authors continue to use `\cref` directly with namespaced source
labels.

The first `labels-ref-sync release` implementation combines three inputs:

1. the generated label and `cleveref` metadata;
2. the repository manifest's base URL and chapter/section routes;
3. the final public PDF layout.

It writes an absolute canonical URL for every exported label. For example, a
theorem in chapter 3, section 1 can target:

```text
https://example.com/algebraic-geometry/chapter3/section1.pdf
```

Opening the exact item should be an additive refinement, not a change to the
registry model. The class can later emit a stable named PDF destination such as
`nfm-tag-0ABCDEF`; the release script can then use:

```text
https://example.com/algebraic-geometry/chapter3/section1.pdf#nameddest=nfm-tag-0ABCDEF
```

If a PDF viewer ignores the fragment, the same link still opens the correct
section PDF. URL generation and route validation belong to the release script,
not to theorem rendering in the class.

### 5. Title-page architecture

The Typst reference suggests a cover with a title band, a large image region,
an attached sentence, and a bottom band. Before implementation, decide:

- whether this visual structure should be preserved closely or only used as
  inspiration;
- whether `chapter` and `book` use exactly the same cover;
- whether the information page in `book` mode remains separate;
- what a cover should show when no image is supplied;
- which colors and dimensions are defaults versus document-level options;
- whether the current commands remain supported as compatibility aliases.

Recommended implementation direction: separate cover data from layout, build
one internal cover renderer, and keep mode-specific behavior in small wrappers.

### 6. Font system

Candidate open-source combinations to test:

| Text | Mathematics | Character | Notes |
| --- | --- | --- | --- |
| Libertinus Serif | Libertinus Math | compact, book-like | Closely matched family |
| TeX Gyre Pagella | TeX Gyre Pagella Math | spacious, classical | Strong readability and TeX availability |
| Source Serif 4 | STIX Two Math | contemporary, clear | Requires checking visual compatibility |

For Chinese text, LXGW WenKai is already stored under `fonts/`, but a serif body
font may be more suitable for long formal notes. We should inspect installed and
vendored fonts, then compile representative Latin, mathematics, and Chinese test
pages before choosing defaults.

### 7. Compatibility and scope

- Minimum required TeX Live version and engine: XeLaTeX only, or LuaLaTeX too?
- Keep all current public commands and environments for the first redesign
  release, or allow a breaking major version?
- Should the class remain a single `.cls` file, or may internal implementation
  move into one or more `.sty` files?
- How will dependent note repositories receive updates: copied file, Git
  submodule/subtree, local TeX tree, or a packaged release?

## Proposed Work Phases

1. **Requirements:** settle tag semantics, publication workflow, compatibility,
   and the desired cover direction.
2. **Prototype:** create a small representative document and test candidate tag
   APIs, title pages, and font combinations.
3. **Implementation:** refactor the class in approved, reviewable batches.
4. **Migration:** document how existing notes adopt tags and the revised metadata
   interface.
5. **Verification:** compile all three section modes; test references, duplicate
   tags, missing fonts/assets, long titles, CJK text, and print legibility.
6. **Documentation and release:** finalize the repository README and template
   examples, record the class version, then remove this temporary journal.

## Verification Checklist

- [ ] Existing example documents compile before redesign.
- [x] Tag syntax and lifecycle are approved.
- [x] The TeX prototype permits stable tags when a statement moves unchanged.
- [x] Duplicate LaTeX labels across independently compiled sections fail validation.
- [ ] Global permanent-tag duplicate detection is implemented in the registry tool.
- [x] Malformed or unregistered published tags fail in TeX.
- [x] Cross-repository namespace and display behavior is tested.
- [ ] Title page works with short/long titles and with/without an image.
- [x] The revised theorem wrappers compile in `section`, `chapter`, and `book` modes.
- [ ] Latin, mathematics, and CJK font samples are visually reviewed.
- [ ] All default fonts are open source and redistribution terms are recorded.
- [ ] Migration and usage examples are documented.
- [ ] Permanent README is complete.
- [ ] This temporary journal is removed at the end of the redesign.

## Discussion Log

### 2026-09-09 — Redesign opened

- Requested a permanent tag system inspired by the Stacks Project.
- Requested a cleaner title page and more maintainable title-page code, using
  the Typst version as a reference.
- Requested clearer open-source fonts.
- Created this journal and the repository README skeleton.
- Left all behavioral and visual choices open for discussion.

### 2026-09-09 — Tag requirements refined

- Confirmed global uniqueness, searchable PDF display, an external registry,
  strict publication failure, and coverage of every theorem-like entry.
- Confirmed that provisional draft tags are not registered.
- Confirmed that changed published content retires its old tag and receives a
  new one.
- Requested hierarchical identifiers and label-based cross-repository
  references with publication-aware display.
- Inspected the sibling repositories, manifests, source labels, and an existing
  `.aux` file to ground the architecture discussion.
- Identified a capacity conflict between a four-character prefix hierarchy and
  sections that already contain more than 36 taggable entries.

### 2026-09-09 — Tag hierarchy and display approved

- Selected prefix lengths 1, 3, 5, and 7 for books, chapters, sections, and
  entries, using uppercase base-36 characters.
- Confirmed that publication is section-by-section, with chapter/book
  publication built from publishable sections.
- Confirmed that a mixed section remains draft and does not enforce draft-tag
  uniqueness.
- Limited tag retirement to mathematical or semantic changes.
- Approved visibly marked provisional draft tags.
- Approved the published heading form
  `Theorem 1.2.3 (Fundamental comparison) (Tag 0ABCDEF)`.
- Approved the published cross-reference form
  `[Book, Theorem 3.1.24, Tag 0ABCDEF]`.

### 2026-09-09 — TeX tag prototype implemented

- Replaced `template_book.tex` with a focused tag-system example containing
  titled and untitled published statements, an untagged draft theorem,
  provisional draft tags, a published item in a draft section, and a simulated
  unchanged move whose allocation prefix differs from its current section.
- Added `status`, `tag`, `label`, and optional `title` keys to all numbered
  theorem-like environments while retaining legacy title-only draft syntax.
- Added scope metadata through `\notesetup`, registry loading through
  `\LoadNoteTagRegistry`, and frozen lookup through `\NoteTagRecord`.
- Added `\externalnotedocument`, using `xr-hyper`, the normal `.aux`, and a
  generated `.nfm-xref` companion so internal references omit the book while
  imported references include it.
- Verified exact searchable PDF text for headings and internal/external
  references. Verified expected build failures for a missing published tag and
  for a draft theorem in a published section.
- Confirmed the wrapper compiles in the class's `section`, `chapter`, and `book`
  modes. Global tag allocation and retirement commands remain the next
  external-tool step.

### 2026-09-09 — Structural references and release URLs refined

- Added publication-aware metadata to `\chapter`, `\section`, and
  `\subsection`, while preserving ordinary optional short-title syntax and
  starred forms.
- Confirmed that subsections use seven-character tags from the same allocation
  pool as theorem-like entries; a subsection is not another status or tag
  hierarchy level.
- Verified published and draft structural references locally and through the
  generated cross-document import fixture.
- Decided that each repository will publish a self-contained cross-reference
  export with canonical per-label URLs.
- Reserved stable PDF named destinations as an optional exact-item refinement;
  a public link can first target the containing section PDF.
- Diagnosed the apparent one-pass editor build: LaTeX Workshop gives the
  document's `% !TeX program = xelatex` comment priority over configured
  recipes, while the current VS Code setting disables automatic builds. The
  configured `latexmk` tool also uses pdfLaTeX mode (`-pdf`) rather than
  XeLaTeX mode (`-xelatex`). No class change is needed; editor/generator changes
  should be made together after approval.

### 2026-09-09 — First label-reference synchronizer implemented

- Added the executable root-level `labels-ref-sync`, independent of
  `manage-notes`.
- Added `sync` to generate a reference input beside every book, chapter, and
  section wrapper. A target excludes its own labels and any labels already
  compiled into the same aggregate document.
- Added a validated versioned `external-labels.json` release format and
  `release`, with full public PDF URLs built from the routes in `notes.json`.
  The default public base follows
  `https://www.tianleyang.com/<book.id>/` and remains overridable.
- Added `fetch`/`update` to download configured catalogs, keep repository
  prefixes isolated, cache the JSON snapshots, and safely generate TeX import
  records instead of evaluating downloaded TeX.
- Kept canonical display numbering from the book build while using the owning
  section's page and anchor, so an imported link opens the correct independently
  compiled PDF.
- Kept same-repository imports compact (`Theorem 3.1.2 (Tag ...)`) while
  reserving the book-qualified bracketed form for cross-repository imports.
- Added `validate`, strict missing-output checks for publication, repository-wide
  duplicate-label detection, atomic writes/download replacement, and a
  reference-manager automated test suite.
- Verified the workflow against a temporary copy of
  `algebras-toward-algebraic-geometry`: a same-repository `\cref` opened the
  sibling section PDF, and a namespaced remote `\cref` opened the public section
  URL with its named PDF destination.

### 2026-09-09 — Tracked published catalogs made authoritative

- Added `referenceCatalog.file` for the released artifact and a separate
  `referenceCatalog.downloadUrl` used only by local pulls. External repository
  entries likewise use `downloadUrl`, which may be empty while still a
  placeholder.
- Changed `fetch` to download and validate the self catalog without a
  namespace, alongside namespaced external repositories, then save snapshots
  under the tracked `label-references/catalogs/` tree.
- Kept per-target filtering: sections omit themselves, chapters omit their own
  chapter tree, and books omit their entire repository.
- Added a local overlay for compiled documents while retaining downloaded data
  for every uncompiled document.
- Materialized each catalog owner once under `label-references/records/`; every
  nearby `external-labels.tex` now imports the allowed shards instead of
  duplicating label records.
- Added incremental `release --previous --documents-file` merging so GitHub
  Actions can replace rebuilt owners, remove deleted labels, and retain all
  untouched records.
- Renamed the executable to `labels-ref-sync` and shortened every per-directory
  generated import filename to `external-labels.tex`.
- Updated the algebra repository's Pages workflow to compile and release only.
  Catalog download, synchronization, and generated-file updates are explicit
  local steps whose results are committed.
- Kept each released source label exactly once, including safe support for
  existing unnumbered semantic environments such as `slogan`.
