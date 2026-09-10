% noteformyself --- a document class for personal mathematical notes
% Maintainer: Tianle Yang
% !TeX program = xelatex
% !Bib program = biber
% !TEX encoding = UTF-8 Unicode
\ProvidesClass{noteformyself}[2026/09/10 v1.99 personal mathematical notes]

% Public interface at a glance:
%   Class options: sectionlevel=book|chapter|section, status=draft|published
%   Scope setup:   \notesetup{book,book-tag,chapter-tag,section-tag,status}
%   Metadata:      \authoremail, \authorpage, \citationkey, \noteurl,
%                  \coversentence, \coverimage, \texsource, \version
%   Tag registry:  \LoadNoteTagRegistry, \DeclarePublishedTag,
%                  \DeclareRetiredTag, \NoteTagRecord
%   References:    \externalnotedocument, \NoteExternalReference,
%                  \NoteImportedReference

% =============================================================================
% Class options and base class
% =============================================================================
% Select the standard class and establish the two public class options before
% any layout or content package is loaded.
\RequirePackage{etoolbox} % String tests and empty-value conditionals.
\RequirePackage{kvoptions} % Key-value class options with a private prefix.
\SetupKeyvalOptions{
  family=noteformyself,
  prefix=noteformyself@
}

\DeclareStringOption[section]{sectionlevel}
% \notesetup may override the current publication scope inside the document.
\DeclareStringOption[draft]{status}

% Forward unknown options to the selected standard class.
\DeclareDefaultOption{%
  \edef\@sectionlevel{\noteformyself@sectionlevel}%
  \ifdefstring{\@sectionlevel}{book}{%
    \PassOptionsToClass{\CurrentOption}{book}%
  }{%
    \PassOptionsToClass{\CurrentOption}{article}%
  }%
}

\ProcessKeyvalOptions*

\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\ifdefstring{\@sectionlevel}{book}{%
  \LoadClass[12pt]{book}
}{%
  \LoadClass[12pt]{article}
}%
\makeatother

% =============================================================================
% Page geometry and core packages
% =============================================================================
% Book builds reserve slightly more room for running heads; chapter and section
% builds share a compact article layout. All modes use an A4 text block.
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\RequirePackage{geometry} % Shared A4 page dimensions for all three modes.
\ifdefstring{\@sectionlevel}{book}{%
  \geometry{
    a4paper,
    top=50pt,
    bottom=36pt,
    left=36pt,
    right=36pt,
    headheight=14pt,
    includefoot,
    footskip=14pt
  }
}{%
  \geometry{
    a4paper,
    top=36pt,
    bottom=36pt,
    left=36pt,
    right=36pt,
    includefoot,
    footskip=14pt
  }
}%
\makeatother

\renewcommand{\baselinestretch}{1.2}

% Core content support. These packages are loaded by the class so individual
% note files can focus on mathematical content rather than boilerplate.
\RequirePackage{graphicx} % Cover images and ordinary included graphics.
\RequirePackage{longtable} % Multipage tables.
\RequirePackage{amsmath,amsthm,amssymb,amsfonts} % Mathematics and theorems.
\RequirePackage[dvipsnames]{xcolor} % Named colors used by boxes and links.
\RequirePackage{tikz} % Cover drawing and general vector graphics.
\RequirePackage{tikz-cd} % TikZ-based commutative diagrams.
\RequirePackage{mathtools} % Extensions and corrections for amsmath.
\RequirePackage[scheme=plain]{ctex} % CJK typesetting without a preset theme.
\RequirePackage{fontspec} % OpenType text-font selection under XeLaTeX.

% =============================================================================
% Text and mathematics fonts
% =============================================================================
% Open-source text families included in TeX Live.
\IfFontExistsTF{Libertinus Serif}{\setmainfont{Libertinus Serif}}{}
\IfFontExistsTF{Libertinus Sans}{\setsansfont{Libertinus Sans}}{}
\IfFontExistsTF{SourceCodePro-Regular.otf}{%
  \setmonofont{SourceCodePro-Regular.otf}[
    BoldFont=SourceCodePro-Bold.otf,
    ItalicFont=SourceCodePro-RegularIt.otf,
    BoldItalicFont=SourceCodePro-BoldIt.otf,
    Scale=MatchLowercase
  ]%
}{%
  \IfFontExistsTF{Libertinus Mono}{\setmonofont{Libertinus Mono}}{}%
}

% unicode-math provides the OpenType math alphabets and must follow mathtools.
\RequirePackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math}
% Use Libertinus for ordinary mathematics and blackboard bold. Keep the two
% calligraphic families selected independently: STIX Two for \mathcal and its
% stylistic set 1 for the visibly different \mathscr alphabet. Latin Modern
% remains the baseline fallback for smaller TeX installations.
\setmathfont{latinmodern-math.otf}
\IfFontExistsTF{LibertinusMath-Regular.otf}{%
  \setmathfont{LibertinusMath-Regular.otf}%
}{%
  \IfFontExistsTF{STIXTwoMath-Regular.otf}{%
    \setmathfont{STIXTwoMath-Regular.otf}%
  }{}%
}
\IfFontExistsTF{STIXTwoMath-Regular.otf}{%
  \setmathfont{STIXTwoMath-Regular.otf}[range={cal,bfcal}]
  \setmathfont{STIXTwoMath-Regular.otf}[
    range={scr,bfscr},
    StylisticSet=1
  ]
}{}

% =============================================================================
% Bibliography, hyperlinks, and lists
% =============================================================================
% These packages provide the shared citation style, PDF destinations,
% publication-aware clever references, and consistent list numbering.
\RequirePackage[backend=biber,style=alphabetic,backref]{biblatex} % Citations.
\ExecuteBibliographyOptions{maxbibnames=99}

\RequirePackage{xr-hyper} % Labels and destinations from separately built PDFs.
\RequirePackage{hyperref} % PDF links, metadata, and named destinations.
\hypersetup{
  colorlinks=true,
  linkcolor=blue,
  urlcolor=magenta,
  citecolor=cyan,
  hypertexnames=false,
}
\RequirePackage[nameinlink]{cleveref} % Type-aware \cref output.

\RequirePackage{enumitem} % Consistent nested list labels.
\setlist[enumerate,1]{label=(\alph*)}
\setlist[enumerate,2]{label=(\roman*)}

% Permit long aligned calculations to break across pages.
\allowdisplaybreaks

% =============================================================================
% Theorem environments and visual styles
% =============================================================================
% Define the amsthm layer first, then decorate it with tcolorbox. The later tag
% wrappers preserve these environments while extending their optional argument.
\RequirePackage[most]{tcolorbox} % Breakable theorem boxes and left rails.

% The publication wrapper sets this suffix before amsthm builds the heading.
\newcommand{\noteformyselfstatementtag}{}

\newtheoremstyle{mystyle}{}{}{}{}{\bfseries}{.}{ }{%
  \thmname{#1}\thmnumber{ #2}\thmnote{ (#3)}\noteformyselfstatementtag}
\theoremstyle{mystyle}

% All ordinary statement environments share the definition counter.
\makeatletter
\ifdefstring{\@sectionlevel}{book}{%
  \newtheorem{definition}{Definition}[section]
}{%
  \ifdefstring{\@sectionlevel}{chapter}{%
    \newtheorem{definition}{Definition}[section]
  }{%
    \newtheorem{definition}{Definition}
  }%
}%
\makeatother
\newtheorem{proposition}[definition]{Proposition}
\newtheorem{theorem}[definition]{Theorem}
\newtheorem{lemma}[definition]{Lemma}
\newtheorem{corollary}[definition]{Corollary}
\newtheorem{conjecture}[definition]{Conjecture}
\newtheorem{question}[definition]{Question}
\newtheorem{remark}[definition]{Remark}
\newtheorem{claim}[definition]{Claim}
\newtheorem{example}[definition]{Example}
\newtheorem{exercise}[definition]{Exercise}
\newtheorem{construction}[definition]{Construction}
\newtheorem{notation}[definition]{Notation}
\newtheorem{mainthm}{Theorem}
\renewcommand{\themainthm}{\Alph{mainthm}}

% Steps and cases restart in each proof, but separate monotone counters provide
% globally unique hyperlink anchors.
\newcounter{step}
\newcounter{globalstep}
\newenvironment{step}[1][]{%
  \refstepcounter{step}%
  \refstepcounter{globalstep}%
  \par\smallskip%
  \noindent\textbf{Step \thestep\if\relax\detokenize{#1}\relax\else\ (#1)\fi.}\ %
}{%
  \par\smallskip%
}
\renewcommand{\theglobalstep}{\arabic{step}}

\newcounter{case}
\newcounter{globalcase}
\newenvironment{case}[1][]{%
  \refstepcounter{case}%
  \refstepcounter{globalcase}%
  \par\smallskip%
  \noindent\textbf{Case \thecase\if\relax\detokenize{#1}\relax\else\ (#1)\fi.}\ %
}{%
  \par\smallskip%
}
\renewcommand{\theglobalcase}{\arabic{case}}

\AtBeginEnvironment{proof}{%
  \setcounter{case}{0}%
  \setcounter{step}{0}%
}

% Human-readable cleveref names.
\crefname{definition}{Definition}{Definitions}
\crefname{proposition}{Proposition}{Propositions}
\crefname{theorem}{Theorem}{Theorems}
\crefname{lemma}{Lemma}{Lemmas}
\crefname{corollary}{Corollary}{Corollaries}
\crefname{conjecture}{Conjecture}{Conjectures}
\crefname{question}{Question}{Questions}
\crefname{remark}{Remark}{Remarks}
\crefname{example}{Example}{Examples}
\crefname{exercise}{Exercise}{Exercises}
\crefname{construction}{Construction}{Constructions}
\crefname{notation}{Notation}{Notations}
\crefname{proof}{Proof}{Proofs}
\crefname{claim}{Claim}{Claims}
\crefname{globalstep}{Step}{Steps}
\crefname{globalcase}{Case}{Cases}
\crefname{section}{Section}{Sections}
\crefname{subsection}{Subsection}{Subsections}
\crefname{mainthm}{Theorem}{Theorems}


% Filled statements: rounded on the left, square on the right.
\newcommand{\mybackgroundtcbsetup}[3]{%
  \tcolorboxenvironment{#1}{
    boxrule=0pt,
    boxsep=0pt,
    colback={#2!10},
    left=8pt,
    right=8pt,
    enhanced jigsaw,
    arc=4pt,
    outer arc=4pt,
    sharp corners=east,
    borderline west={2pt}{0pt}{#2,line cap=round},
    before skip=10pt,
    after skip=10pt,
    breakable,
    #3
  }
}
\mybackgroundtcbsetup{definition}{blue}{}
\mybackgroundtcbsetup{proposition}{purple}{}
\mybackgroundtcbsetup{theorem}{red}{}
\mybackgroundtcbsetup{mainthm}{red}{}
\mybackgroundtcbsetup{lemma}{orange}{}
\mybackgroundtcbsetup{corollary}{magenta}{}
\mybackgroundtcbsetup{conjecture}{violet}{}
\mybackgroundtcbsetup{question}{Thistle}{}

% Lightweight statements: a rounded-ended left rail without a background.
\newcommand{\myemptybgtcdsetup}[3]{%
  \tcolorboxenvironment{#1}{
    boxrule=0pt,
    boxsep=0pt,
    blanker,
    borderline west={2pt}{0pt}{#2,line cap=round},
    left=8pt,
    right=8pt,
    before skip=10pt,
    after skip=10pt,
    breakable,
    before upper={\setlength{\parindent}{2em}},
    #3
  }
}
\myemptybgtcdsetup{proof}{CadetBlue!80!white}{}
\myemptybgtcdsetup{example}{Green}{}
\myemptybgtcdsetup{step}{orange}{before skip=5pt,after skip=5pt}
\myemptybgtcdsetup{case}{orange}{before skip=5pt,after skip=5pt}
\myemptybgtcdsetup{claim}{orange}{}
\myemptybgtcdsetup{exercise}{teal}{}
\myemptybgtcdsetup{remark}{olive}{}
\myemptybgtcdsetup{construction}{Blue}{}
\myemptybgtcdsetup{notation}{MidnightBlue}{}


% Slogans intentionally keep a fully sharp frame.
\newtheoremstyle{sloganstyle}{}{}{\itshape}{}{\bfseries}{}{ }{}
\theoremstyle{sloganstyle}
\newtheorem*{slogan}{Slogan}
\tcolorboxenvironment{slogan}{
  boxrule=0pt,
  boxsep=0pt,
  colback={Green!10},
  left=8pt,
  right=8pt,
  enhanced jigsaw,
  borderline={2pt}{0pt}{Green},
  sharp corners,
  before skip=10pt,
  after skip=10pt,
  breakable,
  before upper={\setlength{\parindent}{2em}},
}


% =============================================================================
% Publication tags and cross-document references
% =============================================================================
% This subsystem validates published entries, writes compact local labels plus
% book-qualified external labels, and provides frozen lookup for retired tags.
% Supply cleveref with the publication-aware record before it writes the
% ordinary label and the matching @cref label to the auxiliary file.
\makeatletter
\newcommand{\noteformyselfstatementlabel}[2]{%
  \begingroup
    % The 2025 LaTeX cleveref first-aid hook otherwise reconstructs this from
    % the shared theorem counter immediately before \label writes the record.
    \let\@currentcounter\@empty
    \def\cref@currentlabel{#2}%
    \label{#1}%
  \endgroup
}
\makeatother

\ExplSyntaxOn

% Current publication scope. Tags are stable identifiers, not display numbers.
\tl_new:N \g_nfm_scope_status_tl
\tl_new:N \g_nfm_book_tag_tl
\tl_new:N \g_nfm_chapter_tag_tl
\tl_new:N \g_nfm_section_tag_tl
\tl_new:N \g_nfm_book_name_tl

\tl_gset:Nn \g_nfm_scope_status_tl { draft }
\str_case_e:nnF { \use:c { noteformyself@status } }
  {
    { draft }     { \tl_gset:Nn \g_nfm_scope_status_tl { draft } }
    { published } { \tl_gset:Nn \g_nfm_scope_status_tl { published } }
  }
  {
    \ClassError{noteformyself}
      {Unknown~class~status~'\use:c { noteformyself@status }'}
      {Use~status=draft~or~status=published.}
  }

% Diagnostics are centralized here so validation failures remain consistent.
\msg_new:nnnn { noteformyself } { invalid-code }
  { Invalid~#1~tag~'#2'. }
  { Use~exactly~#3~uppercase~alphanumeric~characters~(0--9,~A--Z). }
\msg_new:nnnn { noteformyself } { invalid-prefix }
  { Tag~'#1'~does~not~extend~its~#2~tag~'#3'. }
  { Tags~must~use~the~registered~1/3/5/7-character~prefix~hierarchy. }
\msg_new:nnnn { noteformyself } { missing-context }
  { A~published~item~has~no~#1~metadata. }
  { Set~the~required~scope~metadata~with~\string\notesetup~or~tagged~division~keys. }
\msg_new:nnnn { noteformyself } { draft-in-published }
  { Draft~#1~found~in~a~published~scope. }
  { Mark~the~entry~published~and~register~its~tag,~or~compile~the~scope~as~draft. }
\msg_new:nnnn { noteformyself } { published-missing }
  { Published~#1~is~missing~its~#2. }
  { Every~published~item~requires~both~a~label~and~a~tag. }
\msg_new:nnnn { noteformyself } { unknown-tag }
  { Published~tag~'#1'~is~not~in~the~loaded~registry. }
  { Add~it~to~the~global~registry~before~publishing. }
\msg_new:nnnn { noteformyself } { retired-tag }
  { Published~tag~'#1'~is~retired;~its~replacement~is~'#2'. }
  { Use~a~new~active~tag.~Retired~tags~may~only~be~queried~as~frozen~records. }
\msg_new:nnnn { noteformyself } { registry-mismatch }
  { Registry~field~'#1'~for~tag~'#2'~is~'#3',~not~'#4'. }
  { Correct~the~entry~metadata~or~the~global~registry~before~publishing. }
\msg_new:nnnn { noteformyself } { missing-registry-field }
  { Registry~record~'#1'~is~missing~the~required~field~'#2'. }
  { Complete~the~record~in~the~external~tag~registry. }
\msg_new:nnnn { noteformyself } { missing-registry }
  { Tag~registry~file~'#1'~was~not~found. }
  { Pass~an~existing~external~registry~to~\string\LoadNoteTagRegistry. }
\msg_new:nnnn { noteformyself } { missing-replacement }
  { Retired~tag~'#1'~points~to~unknown~replacement~'#2'. }
  { Declare~the~replacement~tag~in~the~same~registry. }
\msg_new:nnnn { noteformyself } { provisional-code }
  { Provisional~draft~tag~'#1'~does~not~have~seven~base-36~characters. }
  { Draft~compilation~continues,~but~the~tag~must~be~fixed~before~publication. }
\msg_new:nnnn { noteformyself } { provisional-division-code }
  { Provisional~draft~#1~tag~'#2'~is~malformed. }
  { It~must~have~exactly~#3~uppercase~alphanumeric~characters~before~publication. }
\msg_new:nnnn { noteformyself } { missing-xref-index }
  { External~reference~index~'#1.nfm-xref'~was~not~found. }
  { Compile~the~source~document~first.~Imported~references~will~omit~its~book~name. }

\cs_generate_variant:Nn \regex_match:nnTF { nVTF }
\cs_generate_variant:Nn \str_range:nnn { Vnn }
\cs_generate_variant:Nn \prop_if_in:NnTF { NVTF }
\cs_generate_variant:Nn \prop_get:NnNTF { NVNTF }
\cs_generate_variant:Nn \prop_gput:Nnn { NVV, NVn }

% Public scope configuration and hierarchy validation.
\keys_define:nn { nfm/setup }
  {
    status .choice:,
    status / draft .code:n =
      { \tl_gset:Nn \g_nfm_scope_status_tl { draft } },
    status / published .code:n =
      { \tl_gset:Nn \g_nfm_scope_status_tl { published } },
    book-tag .tl_gset:N = \g_nfm_book_tag_tl,
    chapter-tag .tl_gset:N = \g_nfm_chapter_tag_tl,
    section-tag .tl_gset:N = \g_nfm_section_tag_tl,
    book .tl_gset:N = \g_nfm_book_name_tl,
  }

\cs_new_protected:Npn \nfm_validate_code:Nnn #1#2#3
  {
    \regex_match:nVTF { \A [0-9A-Z]{#2} \Z } #1
      { }
      { \msg_error:nnnnn { noteformyself } { invalid-code } {#3} { \tl_use:N #1 } {#2} }
  }

\cs_new_protected:Npn \nfm_validate_prefix:NNnn #1#2#3#4
  {
    \str_if_eq:eeF
      { \str_range:Vnn #1 { 1 } {#4} }
      { \tl_to_str:V #2 }
      {
        \msg_error:nnnnn { noteformyself } { invalid-prefix }
          { \tl_use:N #1 } {#3} { \tl_use:N #2 }
      }
  }

\cs_new_protected:Npn \nfm_validate_context:
  {
    \tl_if_blank:VF \g_nfm_book_tag_tl
      { \nfm_validate_code:Nnn \g_nfm_book_tag_tl { 1 } { book } }
    \tl_if_blank:VF \g_nfm_chapter_tag_tl
      { \nfm_validate_code:Nnn \g_nfm_chapter_tag_tl { 3 } { chapter } }
    \tl_if_blank:VF \g_nfm_section_tag_tl
      { \nfm_validate_code:Nnn \g_nfm_section_tag_tl { 5 } { section } }
    \tl_if_blank:VF \g_nfm_chapter_tag_tl
      {
        \tl_if_blank:VF \g_nfm_book_tag_tl
          { \nfm_validate_prefix:NNnn \g_nfm_chapter_tag_tl \g_nfm_book_tag_tl { book } { 1 } }
      }
    \tl_if_blank:VF \g_nfm_section_tag_tl
      {
        \tl_if_blank:VF \g_nfm_chapter_tag_tl
          {
            \nfm_validate_prefix:NNnn
              \g_nfm_section_tag_tl \g_nfm_chapter_tag_tl { chapter } { 3 }
          }
      }
  }

\NewDocumentCommand \notesetup { m }
  {
    \keys_set:nn { nfm/setup } {#1}
    \nfm_validate_context:
  }

% -----------------------------------------------------------------------------
% External global tag registry
% -----------------------------------------------------------------------------
% Active records bind a permanent tag to a book, statement type, and source
% label. Retired records retain their last number and point to a replacement.
\prop_new:N \g_nfm_registry_status_prop
\prop_new:N \g_nfm_registry_book_tag_prop
\prop_new:N \g_nfm_registry_chapter_tag_prop
\prop_new:N \g_nfm_registry_section_tag_prop
\prop_new:N \g_nfm_registry_book_name_prop
\prop_new:N \g_nfm_registry_type_prop
\prop_new:N \g_nfm_registry_label_prop
\prop_new:N \g_nfm_registry_number_prop
\prop_new:N \g_nfm_registry_replacement_prop
\seq_new:N  \g_nfm_retired_tags_seq
\iow_new:N  \g_nfm_xref_iow

% The normal .aux record stays compact for references within the same book.
% This companion file replaces only the imported cleveref record, adding the
% source book name while retaining the ordinary xr-hyper label and hyperlink.
\AtBeginDocument{\iow_open:Nn \g_nfm_xref_iow { \jobname.nfm-xref }}
\AtEndDocument{\iow_close:N \g_nfm_xref_iow}

\tl_new:N \l_nfm_registry_tag_tl
\tl_new:N \l_nfm_registry_book_tag_tl
\tl_new:N \l_nfm_registry_chapter_tag_tl
\tl_new:N \l_nfm_registry_section_tag_tl
\tl_new:N \l_nfm_registry_book_name_tl
\tl_new:N \l_nfm_registry_type_tl
\tl_new:N \l_nfm_registry_label_tl
\tl_new:N \l_nfm_registry_number_tl
\tl_new:N \l_nfm_registry_replacement_tl

\keys_define:nn { nfm/registry }
  {
    tag .tl_set:N = \l_nfm_registry_tag_tl,
    book-tag .tl_set:N = \l_nfm_registry_book_tag_tl,
    chapter-tag .tl_set:N = \l_nfm_registry_chapter_tag_tl,
    section-tag .tl_set:N = \l_nfm_registry_section_tag_tl,
    book .tl_set:N = \l_nfm_registry_book_name_tl,
    type .tl_set:N = \l_nfm_registry_type_tl,
    label .tl_set:N = \l_nfm_registry_label_tl,
    number .tl_set:N = \l_nfm_registry_number_tl,
    replacement .tl_set:N = \l_nfm_registry_replacement_tl,
  }

\cs_new_protected:Npn \nfm_registry_reset:
  {
    \tl_clear:N \l_nfm_registry_tag_tl
    \tl_clear:N \l_nfm_registry_book_tag_tl
    \tl_clear:N \l_nfm_registry_chapter_tag_tl
    \tl_clear:N \l_nfm_registry_section_tag_tl
    \tl_clear:N \l_nfm_registry_book_name_tl
    \tl_clear:N \l_nfm_registry_type_tl
    \tl_clear:N \l_nfm_registry_label_tl
    \tl_clear:N \l_nfm_registry_number_tl
    \tl_clear:N \l_nfm_registry_replacement_tl
  }

\cs_new_protected:Npn \nfm_registry_require:Nn #1#2
  {
    \tl_if_blank:VT #1
      {
        \msg_error:nnnn { noteformyself } { missing-registry-field }
          { \tl_use:N \l_nfm_registry_tag_tl } {#2}
      }
  }

\cs_new_protected:Npn \nfm_registry_validate_hierarchy:
  {
    \nfm_validate_code:Nnn \l_nfm_registry_tag_tl { 7 } { entry }
    \nfm_validate_code:Nnn \l_nfm_registry_book_tag_tl { 1 } { book }
    \nfm_validate_code:Nnn \l_nfm_registry_chapter_tag_tl { 3 } { chapter }
    \nfm_validate_code:Nnn \l_nfm_registry_section_tag_tl { 5 } { section }
    \nfm_validate_prefix:NNnn
      \l_nfm_registry_chapter_tag_tl \l_nfm_registry_book_tag_tl { book } { 1 }
    \nfm_validate_prefix:NNnn
      \l_nfm_registry_section_tag_tl \l_nfm_registry_chapter_tag_tl { chapter } { 3 }
    \nfm_validate_prefix:NNnn
      \l_nfm_registry_tag_tl \l_nfm_registry_section_tag_tl { section } { 5 }
  }

\cs_new_protected:Npn \nfm_registry_store:n #1
  {
    \prop_gput:NVn \g_nfm_registry_status_prop
      \l_nfm_registry_tag_tl {#1}
    \prop_gput:NVV \g_nfm_registry_book_tag_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_book_tag_tl
    \prop_gput:NVV \g_nfm_registry_chapter_tag_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_chapter_tag_tl
    \prop_gput:NVV \g_nfm_registry_section_tag_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_section_tag_tl
    \prop_gput:NVV \g_nfm_registry_book_name_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_book_name_tl
    \prop_gput:NVV \g_nfm_registry_type_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_type_tl
    \prop_gput:NVV \g_nfm_registry_label_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_label_tl
    \prop_gput:NVV \g_nfm_registry_number_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_number_tl
    \prop_gput:NVV \g_nfm_registry_replacement_prop
      \l_nfm_registry_tag_tl \l_nfm_registry_replacement_tl
  }

\cs_new_protected:Npn \nfm_declare_published_tag:n #1
  {
    \nfm_registry_reset:
    \keys_set:nn { nfm/registry } {#1}
    \nfm_registry_require:Nn \l_nfm_registry_tag_tl { tag }
    \nfm_registry_require:Nn \l_nfm_registry_book_tag_tl { book-tag }
    \nfm_registry_require:Nn \l_nfm_registry_chapter_tag_tl { chapter-tag }
    \nfm_registry_require:Nn \l_nfm_registry_section_tag_tl { section-tag }
    \nfm_registry_require:Nn \l_nfm_registry_book_name_tl { book }
    \nfm_registry_require:Nn \l_nfm_registry_type_tl { type }
    \nfm_registry_require:Nn \l_nfm_registry_label_tl { label }
    \nfm_registry_validate_hierarchy:
    \nfm_registry_store:n { active }
  }

\cs_new_protected:Npn \nfm_declare_retired_tag:n #1
  {
    \nfm_registry_reset:
    \keys_set:nn { nfm/registry } {#1}
    \nfm_registry_require:Nn \l_nfm_registry_tag_tl { tag }
    \nfm_registry_require:Nn \l_nfm_registry_book_tag_tl { book-tag }
    \nfm_registry_require:Nn \l_nfm_registry_chapter_tag_tl { chapter-tag }
    \nfm_registry_require:Nn \l_nfm_registry_section_tag_tl { section-tag }
    \nfm_registry_require:Nn \l_nfm_registry_book_name_tl { book }
    \nfm_registry_require:Nn \l_nfm_registry_type_tl { type }
    \nfm_registry_require:Nn \l_nfm_registry_number_tl { number }
    \nfm_registry_require:Nn \l_nfm_registry_replacement_tl { replacement }
    \nfm_registry_validate_hierarchy:
    \nfm_validate_code:Nnn \l_nfm_registry_replacement_tl { 7 } { entry }
    \nfm_registry_store:n { retired }
    \seq_gput_right:NV \g_nfm_retired_tags_seq \l_nfm_registry_tag_tl
  }

\NewDocumentCommand \DeclarePublishedTag { m }
  { \nfm_declare_published_tag:n {#1} }
\NewDocumentCommand \DeclareRetiredTag { m }
  { \nfm_declare_retired_tag:n {#1} }
\NewDocumentCommand \LoadNoteTagRegistry { m }
  {
    \InputIfFileExists{#1} { }
      { \msg_error:nnn { noteformyself } { missing-registry } {#1} }
  }

\cs_new_protected:Npn \nfm_validate_retired_replacements:
  {
    \seq_map_inline:Nn \g_nfm_retired_tags_seq
      {
        \prop_get:NnNT \g_nfm_registry_replacement_prop {##1} \l_tmpa_tl
          {
            % A replacement may itself later be retired.  The external registry
            % tool checks redirect chains and cycles; TeX only requires the
            % next frozen record to exist.
            \prop_if_in:NVTF \g_nfm_registry_status_prop \l_tmpa_tl
              { }
              {
                \msg_error:nnnn { noteformyself } { missing-replacement }
                  {##1} { \tl_use:N \l_tmpa_tl }
              }
          }
      }
  }
\AtBeginDocument{\nfm_validate_retired_replacements:}

% -----------------------------------------------------------------------------
% Theorem-like statement metadata
% -----------------------------------------------------------------------------
% The optional argument accepts either the traditional title or the keys
% title, status, tag, and label. Published entries are checked against the
% registry before the original amsthm environment begins.
\tl_new:N \l_nfm_statement_title_tl
\tl_new:N \l_nfm_statement_status_tl
\tl_new:N \l_nfm_statement_tag_tl
\tl_new:N \l_nfm_statement_label_tl
\tl_new:N \l_nfm_statement_number_tl
\tl_new:N \l_nfm_statement_reference_tl
\tl_new:N \l_nfm_statement_external_reference_tl
\tl_new:N \l_nfm_statement_counter_tl
\tl_new:N \l_nfm_statement_cref_tl
\tl_new:N \l_nfm_statement_external_cref_tl

\keys_define:nn { nfm/statement }
  {
    title .tl_set:N = \l_nfm_statement_title_tl,
    status .choice:,
    status / draft .code:n =
      { \tl_set:Nn \l_nfm_statement_status_tl { draft } },
    status / published .code:n =
      { \tl_set:Nn \l_nfm_statement_status_tl { published } },
    tag .tl_set:N = \l_nfm_statement_tag_tl,
    label .tl_set:N = \l_nfm_statement_label_tl,
  }

\cs_new_protected:Npn \nfm_statement_reset:
  {
    \tl_clear:N \l_nfm_statement_title_tl
    \tl_set:Nn \l_nfm_statement_status_tl { draft }
    \tl_clear:N \l_nfm_statement_tag_tl
    \tl_clear:N \l_nfm_statement_label_tl
    \tl_clear:N \l_nfm_statement_number_tl
    \tl_clear:N \l_nfm_statement_reference_tl
    \tl_clear:N \l_nfm_statement_external_reference_tl
    \tl_clear:N \l_nfm_statement_counter_tl
    \tl_clear:N \l_nfm_statement_cref_tl
    \tl_clear:N \l_nfm_statement_external_cref_tl
    \cs_set:Npn \noteformyselfstatementtag { }
  }

\cs_new_protected:Npn \nfm_statement_parse:n #1
  {
    \IfNoValueF{#1}
      {
        \regex_match:nnTF
          { \A \s* (title|status|tag|label) \s* = }
          {#1}
          { \keys_set:nn { nfm/statement } {#1} }
          { \tl_set:Nn \l_nfm_statement_title_tl {#1} }
      }
  }

\cs_new_protected:Npn \nfm_require_context:Nn #1#2
  {
    \tl_if_blank:VT #1
      { \msg_error:nnn { noteformyself } { missing-context } {#2} }
  }

\cs_new_protected:Npn \nfm_registry_expect:NNn #1#2#3
  {
    \prop_get:NVNTF #1 \l_nfm_statement_tag_tl \l_tmpa_tl
      {
        \tl_if_eq:NNF \l_tmpa_tl #2
          {
            \msg_error:nnnnnn { noteformyself } { registry-mismatch }
              {#3}
              { \tl_use:N \l_nfm_statement_tag_tl }
              { \tl_use:N \l_tmpa_tl }
              { \tl_use:N #2 }
          }
      }
      { }
  }

\cs_new_protected:Npn \nfm_validate_published_statement:n #1
  {
    \tl_if_blank:VT \l_nfm_statement_tag_tl
      {
        \msg_error:nnnn { noteformyself } { published-missing }
          {#1} { tag }
      }
    \tl_if_blank:VT \l_nfm_statement_label_tl
      {
        \msg_error:nnnn { noteformyself } { published-missing }
          {#1} { label }
      }
    \nfm_require_context:Nn \g_nfm_book_tag_tl { book-tag }
    \nfm_require_context:Nn \g_nfm_chapter_tag_tl { chapter-tag }
    \nfm_require_context:Nn \g_nfm_section_tag_tl { section-tag }
    \nfm_require_context:Nn \g_nfm_book_name_tl { book }
    \nfm_validate_code:Nnn \l_nfm_statement_tag_tl { 7 } { entry }
    \nfm_validate_context:
    \prop_get:NVNTF
      \g_nfm_registry_status_prop \l_nfm_statement_tag_tl \l_tmpa_tl
      {
        \tl_if_eq:VnTF \l_tmpa_tl { retired }
          {
            \prop_get:NVNTF \g_nfm_registry_replacement_prop
              \l_nfm_statement_tag_tl \l_tmpb_tl
              {
                \msg_error:nnnn { noteformyself } { retired-tag }
                  { \tl_use:N \l_nfm_statement_tag_tl } { \tl_use:N \l_tmpb_tl }
              }
              { }
          }
          {
            % Hierarchical tag components record allocation origin.  They do
            % not have to match the entry's present location after a move.
            \nfm_registry_expect:NNn
              \g_nfm_registry_book_name_prop \g_nfm_book_name_tl { book }
            \tl_set:Nn \l_tmpb_tl {#1}
            \nfm_registry_expect:NNn
              \g_nfm_registry_type_prop \l_tmpb_tl { type }
            \nfm_registry_expect:NNn
              \g_nfm_registry_label_prop \l_nfm_statement_label_tl { label }
          }
      }
      {
        \msg_error:nnn { noteformyself } { unknown-tag }
          { \tl_use:N \l_nfm_statement_tag_tl }
      }
  }

\cs_new_protected:Npn \nfm_prepare_statement:nn #1#2
  {
    \tl_if_eq:VnTF \l_nfm_statement_status_tl { published }
      { \nfm_validate_published_statement:n {#1} }
      {
        \tl_if_eq:VnT \g_nfm_scope_status_tl { published }
          { \msg_error:nnn { noteformyself } { draft-in-published } {#1} }
        \tl_if_blank:VF \l_nfm_statement_tag_tl
          {
            \regex_match:nVTF
              { \A [0-9A-Z]{7} \Z } \l_nfm_statement_tag_tl
              { }
              {
                \msg_warning:nnn { noteformyself } { provisional-code }
                  { \tl_use:N \l_nfm_statement_tag_tl }
              }
          }
      }
    \tl_if_blank:VF \l_nfm_statement_tag_tl
      {
        \tl_if_eq:VnTF \l_nfm_statement_status_tl { published }
          {
            \cs_set_protected:Npx \noteformyselfstatementtag
              {
                \nobreakspace
                \exp_not:N \mbox
                  { \exp_not:N \normalfont (Tag~\exp_not:N \texttt
                    { \exp_not:V \l_nfm_statement_tag_tl }) }
              }
          }
          {
            \cs_set_protected:Npx \noteformyselfstatementtag
              {
                \nobreakspace
                \exp_not:N \mbox
                  { \exp_not:N \normalfont (Draft~tag~\exp_not:N \texttt
                    { \exp_not:V \l_nfm_statement_tag_tl }) }
              }
          }
      }
  }

\cs_new_protected:Npn \nfm_make_statement_reference:nn #1#2
  {
    \str_if_eq:nnTF {#1} { mainthm }
      { \tl_set:Nn \l_nfm_statement_counter_tl { mainthm } }
      { \tl_set:Nn \l_nfm_statement_counter_tl { definition } }
    \tl_set:Nx \l_nfm_statement_number_tl { \use:c { the#1 } }
    \tl_if_blank:VTF \g_nfm_book_name_tl
      { \tl_set_eq:NN \l_tmpa_tl \g_nfm_book_tag_tl }
      { \tl_set_eq:NN \l_tmpa_tl \g_nfm_book_name_tl }
    \tl_if_eq:VnTF \l_nfm_statement_status_tl { published }
      {
        \tl_set:Nx \l_nfm_statement_reference_tl
          {
            #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl
            \c_space_tl (Tag\c_space_tl
            \exp_not:N \texttt { \exp_not:V \l_nfm_statement_tag_tl })
          }
        \tl_set:Nx \l_nfm_statement_external_reference_tl
          {
            [\exp_not:V \l_tmpa_tl,\c_space_tl
            #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl,
            \c_space_tl Tag\c_space_tl
            \exp_not:N \texttt { \exp_not:V \l_nfm_statement_tag_tl }]
          }
        \tl_set:Nn \l_tmpb_tl { nfmpublished }
      }
      {
        \cs_if_exist:cTF { c@chapter }
          {
            \tl_set:Nx \l_nfm_statement_reference_tl
              {
                #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl
              }
            \tl_set:Nx \l_nfm_statement_external_reference_tl
              {
                [\exp_not:V \l_tmpa_tl,\c_space_tl
                Chapter\c_space_tl \int_use:c { c@chapter },\c_space_tl
                Section\c_space_tl \int_use:c { c@section },\c_space_tl
                #2\c_space_tl
                \int_use:c { c@\tl_use:N \l_nfm_statement_counter_tl }]
              }
          }
          {
            \tl_set:Nx \l_nfm_statement_reference_tl
              {
                #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl
              }
            \tl_set:Nx \l_nfm_statement_external_reference_tl
              {
                [\exp_not:V \l_tmpa_tl,\c_space_tl
                #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl]
              }
          }
        \tl_set:Nn \l_tmpb_tl { nfmdraft }
      }
    \tl_set:Nx \l_nfm_statement_cref_tl
      {
        [\exp_not:V \l_tmpb_tl]
        [\int_use:c { c@\tl_use:N \l_nfm_statement_counter_tl }][]
        \exp_not:V \l_nfm_statement_reference_tl
      }
    \tl_set:Nx \l_nfm_statement_external_cref_tl
      {
        [\exp_not:V \l_tmpb_tl]
        [\int_use:c { c@\tl_use:N \l_nfm_statement_counter_tl }][]
        \exp_not:V \l_nfm_statement_external_reference_tl
      }
  }

\cs_new_protected:Npn \nfm_write_statement_label:
  {
    \exp_args:NVV \noteformyselfstatementlabel
      \l_nfm_statement_label_tl \l_nfm_statement_cref_tl
    \iow_now:Nx \g_nfm_xref_iow
      {
        \token_to_str:N \NoteExternalReference
        {\tl_to_str:V \l_nfm_statement_label_tl}
        {
          {\exp_not:V \l_nfm_statement_external_cref_tl}
          {[\thepage][\arabic{page}][]\thepage}{}{}{}
        }
      }
  }

\cs_new_protected:Npn \nfm_begin_titled_statement:nn #1#2
  { \use:c { nfm_base_#1_begin: } [#2] }

\cs_new_protected:Npn \nfm_statement_begin:nnn #1#2#3
  {
    \nfm_statement_reset:
    \nfm_statement_parse:n {#3}
    \nfm_prepare_statement:nn {#1} {#2}
    \tl_if_blank:VTF \l_nfm_statement_title_tl
      { \use:c { nfm_base_#1_begin: } }
      {
        \exp_args:NnV \nfm_begin_titled_statement:nn
          {#1} \l_nfm_statement_title_tl
      }
    \tl_if_blank:VF \l_nfm_statement_label_tl
      {
        \nfm_make_statement_reference:nn {#1} {#2}
        \nfm_write_statement_label:
      }
  }

\cs_new_protected:Npn \nfm_statement_end:n #1
  { \use:c { nfm_base_#1_end: } }

\cs_new_protected:Npn \nfm_wrap_statement_environment:nn #1#2
  {
    \cs_new_eq:cc { nfm_base_#1_begin: } {#1}
    \cs_new_eq:cc { nfm_base_#1_end: } { end#1 }
    \RenewDocumentEnvironment{#1}{o}
      { \nfm_statement_begin:nnn {#1} {#2} {##1} }
      { \nfm_statement_end:n {#1} }
  }

\nfm_wrap_statement_environment:nn { definition }   { Definition }
\nfm_wrap_statement_environment:nn { proposition }  { Proposition }
\nfm_wrap_statement_environment:nn { theorem }      { Theorem }
\nfm_wrap_statement_environment:nn { lemma }        { Lemma }
\nfm_wrap_statement_environment:nn { corollary }    { Corollary }
\nfm_wrap_statement_environment:nn { conjecture }   { Conjecture }
\nfm_wrap_statement_environment:nn { question }     { Question }
\nfm_wrap_statement_environment:nn { remark }       { Remark }
\nfm_wrap_statement_environment:nn { claim }        { Claim }
\nfm_wrap_statement_environment:nn { example }      { Example }
\nfm_wrap_statement_environment:nn { exercise }     { Exercise }
\nfm_wrap_statement_environment:nn { construction } { Construction }
\nfm_wrap_statement_environment:nn { notation }     { Notation }
\nfm_wrap_statement_environment:nn { mainthm }      { Theorem }

% -----------------------------------------------------------------------------
% Chapter, section, and subsection metadata
% -----------------------------------------------------------------------------
% Subsections are tagged referenceable items, not a new allocation or status
% scope. Their seven-character tags share the section-level pool with entries.
% A normal short title remains compatible; metadata mode begins with one of the
% keys short-title, status, tag, or label.
\tl_new:N \l_nfm_division_short_title_tl
\tl_new:N \l_nfm_division_status_tl
\tl_new:N \l_nfm_division_tag_tl
\tl_new:N \l_nfm_division_label_tl
\tl_new:N \l_nfm_division_number_tl
\tl_new:N \l_nfm_division_reference_tl
\tl_new:N \l_nfm_division_external_reference_tl
\tl_new:N \l_nfm_division_cref_tl
\tl_new:N \l_nfm_division_external_cref_tl
\tl_new:N \l_nfm_division_full_title_tl

\keys_define:nn { nfm/division }
  {
    short-title .tl_set:N = \l_nfm_division_short_title_tl,
    status .choice:,
    status / draft .code:n =
      { \tl_set:Nn \l_nfm_division_status_tl { draft } },
    status / published .code:n =
      { \tl_set:Nn \l_nfm_division_status_tl { published } },
    tag .tl_set:N = \l_nfm_division_tag_tl,
    label .tl_set:N = \l_nfm_division_label_tl,
  }

\cs_new_protected:Npn \nfm_division_reset:
  {
    \tl_clear:N \l_nfm_division_short_title_tl
    \tl_set:Nx \l_nfm_division_status_tl
      { \exp_not:V \g_nfm_scope_status_tl }
    \tl_clear:N \l_nfm_division_tag_tl
    \tl_clear:N \l_nfm_division_label_tl
    \tl_clear:N \l_nfm_division_number_tl
    \tl_clear:N \l_nfm_division_reference_tl
    \tl_clear:N \l_nfm_division_external_reference_tl
    \tl_clear:N \l_nfm_division_cref_tl
    \tl_clear:N \l_nfm_division_external_cref_tl
    \tl_clear:N \l_nfm_division_full_title_tl
    \cs_set:Npn \noteformyselfdivisiontag { }
  }

\cs_new_protected:Npn \nfm_division_require:Nnn #1#2#3
  {
    \tl_if_blank:VT #1
      { \msg_error:nnnn { noteformyself } { published-missing } {#2} {#3} }
  }

\cs_new_protected:Npn \nfm_validate_published_division:nnn #1#2#3
  {
    \nfm_division_require:Nnn \l_nfm_division_tag_tl {#2} { tag }
    \nfm_division_require:Nnn \l_nfm_division_label_tl {#2} { label }
    \nfm_require_context:Nn \g_nfm_book_tag_tl { book-tag }
    \nfm_require_context:Nn \g_nfm_book_name_tl { book }
    \str_case:nn {#1}
      {
        { chapter }
          {
            \nfm_validate_code:Nnn \l_nfm_division_tag_tl { 3 } { chapter }
            \nfm_validate_prefix:NNnn
              \l_nfm_division_tag_tl \g_nfm_book_tag_tl { book } { 1 }
          }
        { section }
          {
            \nfm_require_context:Nn \g_nfm_chapter_tag_tl { chapter-tag }
            \nfm_validate_code:Nnn \l_nfm_division_tag_tl { 5 } { section }
            \nfm_validate_prefix:NNnn
              \l_nfm_division_tag_tl \g_nfm_chapter_tag_tl { chapter } { 3 }
          }
        { subsection }
          {
            \nfm_require_context:Nn \g_nfm_chapter_tag_tl { chapter-tag }
            \nfm_require_context:Nn \g_nfm_section_tag_tl { section-tag }
            \nfm_validate_code:Nnn \l_nfm_division_tag_tl { 7 } { subsection }
            \nfm_validate_prefix:NNnn
              \l_nfm_division_tag_tl \g_nfm_section_tag_tl { section } { 5 }
          }
      }
  }

\cs_new_protected:Npn \nfm_prepare_division:nnn #1#2#3
  {
    \tl_if_eq:VnTF \l_nfm_division_status_tl { published }
      { \nfm_validate_published_division:nnn {#1} {#2} {#3} }
      {
        \tl_if_blank:VF \l_nfm_division_tag_tl
          {
            \regex_match:nVTF
              { \A [0-9A-Z]{#3} \Z } \l_nfm_division_tag_tl
              { }
              {
                \msg_warning:nnnnn { noteformyself }
                  { provisional-division-code }
                  {#1} { \tl_use:N \l_nfm_division_tag_tl } {#3}
              }
          }
      }
    \tl_if_blank:VF \l_nfm_division_tag_tl
      {
        \tl_if_eq:VnTF \l_nfm_division_status_tl { published }
          {
            \cs_set_protected:Npx \noteformyselfdivisiontag
              {
                \nobreakspace
                \exp_not:N \mbox
                  { \exp_not:N \normalfont (Tag~\exp_not:N \texttt
                    { \exp_not:V \l_nfm_division_tag_tl }) }
              }
          }
          {
            \cs_set_protected:Npx \noteformyselfdivisiontag
              {
                \nobreakspace
                \exp_not:N \mbox
                  { \exp_not:N \normalfont (Draft~tag~\exp_not:N \texttt
                    { \exp_not:V \l_nfm_division_tag_tl }) }
              }
          }
      }
  }

\cs_new_protected:Npn \nfm_update_division_scope:n #1
  {
    \str_case:nn {#1}
      {
        { chapter }
          {
            \tl_gset:Nx \g_nfm_chapter_tag_tl
              { \exp_not:V \l_nfm_division_tag_tl }
            \tl_gclear:N \g_nfm_section_tag_tl
            \tl_gset:Nx \g_nfm_scope_status_tl
              { \exp_not:V \l_nfm_division_status_tl }
          }
        { section }
          {
            \tl_gset:Nx \g_nfm_section_tag_tl
              { \exp_not:V \l_nfm_division_tag_tl }
            \tl_gset:Nx \g_nfm_scope_status_tl
              { \exp_not:V \l_nfm_division_status_tl }
          }
      }
  }

\cs_new_protected:Npn \nfm_make_division_reference:nn #1#2
  {
    \tl_set:Nx \l_nfm_division_number_tl { \use:c { the#1 } }
    \tl_if_blank:VTF \g_nfm_book_name_tl
      { \tl_set_eq:NN \l_tmpa_tl \g_nfm_book_tag_tl }
      { \tl_set_eq:NN \l_tmpa_tl \g_nfm_book_name_tl }
    \tl_if_eq:VnTF \l_nfm_division_status_tl { published }
      {
        \tl_set:Nx \l_nfm_division_reference_tl
          {
            #2\c_space_tl \exp_not:V \l_nfm_division_number_tl
            \c_space_tl (Tag\c_space_tl
            \exp_not:N \texttt { \exp_not:V \l_nfm_division_tag_tl })
          }
        \tl_set:Nx \l_nfm_division_external_reference_tl
          {
            [\exp_not:V \l_tmpa_tl,\c_space_tl
            #2\c_space_tl \exp_not:V \l_nfm_division_number_tl,
            \c_space_tl Tag\c_space_tl
            \exp_not:N \texttt { \exp_not:V \l_nfm_division_tag_tl }]
          }
        \tl_set:Nn \l_tmpb_tl { nfmpublished }
      }
      {
        \tl_set:Nx \l_nfm_division_reference_tl
          { #2\c_space_tl \exp_not:V \l_nfm_division_number_tl }
        \tl_set:Nx \l_nfm_division_external_reference_tl
          {
            [\exp_not:V \l_tmpa_tl,\c_space_tl
            #2\c_space_tl \exp_not:V \l_nfm_division_number_tl]
          }
        \tl_set:Nn \l_tmpb_tl { nfmdraft }
      }
    \tl_set:Nx \l_nfm_division_cref_tl
      {
        [\exp_not:V \l_tmpb_tl][\int_use:c { c@#1 }][]
        \exp_not:V \l_nfm_division_reference_tl
      }
    \tl_set:Nx \l_nfm_division_external_cref_tl
      {
        [\exp_not:V \l_tmpb_tl][\int_use:c { c@#1 }][]
        \exp_not:V \l_nfm_division_external_reference_tl
      }
  }

\cs_new_protected:Npn \nfm_write_division_label:
  {
    \exp_args:NVV \noteformyselfstatementlabel
      \l_nfm_division_label_tl \l_nfm_division_cref_tl
    \iow_now:Nx \g_nfm_xref_iow
      {
        \token_to_str:N \NoteExternalReference
        {\tl_to_str:V \l_nfm_division_label_tl}
        {
          {\exp_not:V \l_nfm_division_external_cref_tl}
          {[\thepage][\arabic{page}][]\thepage}{}{}{}
        }
      }
  }

\cs_new_protected:Npn \nfm_call_division:Nnn #1#2#3
  { #1[#2]{#3} }
\cs_generate_variant:Nn \nfm_call_division:Nnn { NVV }

\cs_new_protected:Npn \nfm_division_metadata:Nnnnnn #1#2#3#4#5#6
  {
    \nfm_division_reset:
    \keys_set:nn { nfm/division } {#5}
    \tl_if_blank:VT \l_nfm_division_short_title_tl
      { \tl_set:Nn \l_nfm_division_short_title_tl {#6} }
    \nfm_prepare_division:nnn {#2} {#3} {#4}
    \nfm_update_division_scope:n {#2}
    \tl_set:Nn \l_nfm_division_full_title_tl {#6}
    \tl_put_right:Nn \l_nfm_division_full_title_tl
      { \noteformyselfdivisiontag }
    \nfm_call_division:NVV #1
      \l_nfm_division_short_title_tl \l_nfm_division_full_title_tl
    \tl_if_blank:VF \l_nfm_division_label_tl
      {
        \nfm_make_division_reference:nn {#2} {#3}
        \nfm_write_division_label:
      }
  }

\cs_new_protected:Npn \nfm_division_command:Nnnnnn #1#2#3#4#5#6
  {
    \IfNoValueTF{#5}
      { #1{#6} }
      {
        \regex_match:nnTF
          { \A \s* (short-title|status|tag|label) \s* = }
          {#5}
          { \nfm_division_metadata:Nnnnnn #1 {#2} {#3} {#4} {#5} {#6} }
          { #1[#5]{#6} }
      }
  }

\cs_new_protected:Npn \nfm_chapter_command:nnn #1#2#3
  {
    \IfBooleanTF{#1}
      { \nfm_base_chapter*{#3} }
      { \nfm_division_command:Nnnnnn \nfm_base_chapter { chapter } { Chapter } { 3 } {#2} {#3} }
  }

\cs_new_protected:Npn \nfm_section_command:nnn #1#2#3
  {
    \IfBooleanTF{#1}
      { \nfm_base_section*{#3} }
      { \nfm_division_command:Nnnnnn \nfm_base_section { section } { Section } { 5 } {#2} {#3} }
  }

\cs_new_protected:Npn \nfm_subsection_command:nnn #1#2#3
  {
    \IfBooleanTF{#1}
      { \nfm_base_subsection*{#3} }
      {
        \nfm_division_command:Nnnnnn
          \nfm_base_subsection { subsection } { Subsection } { 7 } {#2} {#3}
      }
  }

% -----------------------------------------------------------------------------
% Imported references and frozen tag lookup
% -----------------------------------------------------------------------------
% \externalnotedocument combines xr-hyper's ordinary auxiliary labels with the
% companion .nfm-xref descriptions written above. Generated catalog imports use
% \NoteImportedReference instead and never execute downloaded TeX directly.
\tl_new:N \l_nfm_external_prefix_tl

\cs_new_protected:Npn \nfm_external_reference:nn #1#2
  {
    \cs_gset:cpn
      { r@\tl_use:N \l_nfm_external_prefix_tl #1@cref }
      {#2}
  }

\NewDocumentCommand \NoteExternalReference { m m }
  { \nfm_external_reference:nn {#1} {#2} }

\cs_new_protected:Npn \nfm_imported_reference:nnn #1#2#3
  {
    \cs_gset:cpn { r@#1 } {#2}
    \cs_gset:cpn { r@#1@cref } {#3}
  }

\NewDocumentCommand \NoteImportedReference { m m m }
  { \nfm_imported_reference:nnn {#1} {#2} {#3} }

\NewDocumentCommand \externalnotedocument { O{} m O{} }
  {
    \tl_if_blank:nTF {#1}
      {
        \tl_if_blank:nTF {#3}
          { \externaldocument{#2} }
          { \externaldocument{#2}[#3] }
        \tl_clear:N \l_nfm_external_prefix_tl
      }
      {
        \tl_if_blank:nTF {#3}
          { \externaldocument[#1:]{#2} }
          { \externaldocument[#1:]{#2}[#3] }
        \tl_set:Nn \l_nfm_external_prefix_tl {#1:}
      }
    \InputIfFileExists{#2.nfm-xref} { }
      { \msg_warning:nnn { noteformyself } { missing-xref-index } {#2} }
  }

\NewDocumentCommand \NoteTagRecord { m }
  {
    \prop_get:NnNTF \g_nfm_registry_status_prop {#1} \l_tmpa_tl
      {
        \prop_get:NnN \g_nfm_registry_book_name_prop {#1} \l_tmpb_tl
        \prop_get:NnN \g_nfm_registry_type_prop {#1} \l_tmpc_tl
        \tl_if_eq:VnTF \l_tmpa_tl { retired }
          {
            \prop_get:NnN \g_nfm_registry_number_prop {#1} \l_tmpd_tl
            \prop_get:NnN \g_nfm_registry_replacement_prop {#1} \l_tmpe_tl
            [\tl_use:N \l_tmpb_tl,\c_space_tl \tl_use:N \l_tmpc_tl
            \c_space_tl \tl_use:N \l_tmpd_tl,\c_space_tl
            retired\c_space_tl Tag\c_space_tl \texttt{#1};\c_space_tl
            replaced\c_space_tl by\c_space_tl Tag\c_space_tl
            \texttt{\tl_use:N \l_tmpe_tl}]
          }
          {
            [\tl_use:N \l_tmpb_tl,\c_space_tl \tl_use:N \l_tmpc_tl,
            \c_space_tl Tag\c_space_tl \texttt{#1}]
          }
      }
      { \msg_error:nnn { noteformyself } { unknown-tag } {#1} }
  }

\ExplSyntaxOff

\crefformat{nfmpublished}{#2#1#3}
\Crefformat{nfmpublished}{#2#1#3}
\crefformat{nfmdraft}{#2#1#3}
\Crefformat{nfmdraft}{#2#1#3}

% =============================================================================
% Source-code listings
% =============================================================================
% Install one restrained default style and make listing labels available to
% cleveref. Documents may still override it locally with ordinary listings keys.
\RequirePackage{listings} % Highlighted, referenceable source-code examples.
\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.92}

\lstdefinestyle{mystyle}{
  backgroundcolor=\color{backcolour},
  commentstyle=\color{red!50!green!50!blue!50},
  keywordstyle=\color{blue!70},
  numberstyle=\tiny\color{codegray},
  stringstyle=\color{codepurple},
  basicstyle=\ttfamily\footnotesize,
  breakatwhitespace=false,
  breaklines=true,
  captionpos=b,
  keepspaces=true,
  numbers=left,
  numbersep=5pt,
  showspaces=false,
  showstringspaces=false,
  showtabs=false,
  tabsize=2,
  frame=single
}
\lstset{style=mystyle}

\crefname{lstlisting}{Code}{Codes}

% =============================================================================
% Document and cover metadata
% =============================================================================
% Store public metadata without imposing it on modes that do not display it.
% Book mode uses every field; chapter and section modes use smaller subsets.
\makeatletter
\gdef\@authoremail{}
\newcommand{\authoremail}[1]{\gdef\@authoremail{#1}}
\gdef\@authorpage{}
\newcommand{\authorpage}[1]{\gdef\@authorpage{#1}}
\gdef\@citationkey{}
\newcommand{\citationkey}[1]{\gdef\@citationkey{#1}}
\gdef\@noteurl{}
\newcommand{\noteurl}[1]{\gdef\@noteurl{#1}}
\gdef\@coversentence{}
\newcommand{\coversentence}[1]{\gdef\@coversentence{#1}}
\gdef\@coverimage{}
\newcommand{\coverimage}[1]{\gdef\@coverimage{#1}}

\definecolor{nfmCoverAccent}{HTML}{B8DCE8}
\definecolor{nfmCoverPaper}{HTML}{F3F0E5}
\definecolor{nfmCoverInk}{HTML}{17343E}
\definecolor{nfmMutedInk}{HTML}{667175}
\gdef\@coveraccentcolor{nfmCoverAccent}
\newcommand{\coveraccentcolor}[1]{\gdef\@coveraccentcolor{#1}}
\gdef\@coverpapercolor{nfmCoverPaper}
\newcommand{\coverpapercolor}[1]{\gdef\@coverpapercolor{#1}}
\gdef\@covertextcolor{nfmCoverInk}
\newcommand{\covertextcolor}[1]{\gdef\@covertextcolor{#1}}
\gdef\@covertitlefont{Libertinus Sans}
\newcommand{\covertitlefont}[1]{\gdef\@covertitlefont{#1}}

\gdef\@texsource{}
\newcommand{\texsource}[1]{\gdef\@texsource{#1}}
\gdef\@version{2.0.0}
\newcommand{\version}[1]{\gdef\@version{#1}}
\gdef\@copyrightyear{\number\year}
\newcommand{\copyrightyear}[1]{\gdef\@copyrightyear{#1}}
\makeatother

% =============================================================================
% Page styles
% =============================================================================
% Book pages use quiet title-case running heads and outer page numbers. Article
% modes keep only a centered page number. No mode draws header or footer rules.
\RequirePackage{fancyhdr} % Rule-free running heads and page numbers.
\RequirePackage[bottom,multiple]{footmisc} % Stable placement of footnotes.

\makeatletter
\fancypagestyle{sectionmainmatter}{
  \fancyhf{}
  \fancyfoot[C]{\sffamily\small\color{nfmMutedInk}\thepage}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
}

\fancypagestyle{bookmainmatter}{
  \fancyhf{}
  \fancyhead[LE]{\sffamily\small\color{nfmMutedInk}\thepage}
  \fancyhead[RE]{\sffamily\small\color{nfmMutedInk}\nouppercase{\leftmark}}
  \fancyhead[LO]{\sffamily\small\color{nfmMutedInk}\nouppercase{\rightmark}}
  \fancyhead[RO]{\sffamily\small\color{nfmMutedInk}\thepage}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
}

% Preserve title case in the book's running heads.
\ifdefstring{\@sectionlevel}{book}{%
  \renewcommand{\chaptermark}[1]{%
    \markboth{\thechapter.\ #1}{}
  }
  \renewcommand{\sectionmark}[1]{%
    \markright{\thesection.\ #1}
  }
}{}%

\ifdefstring{\@sectionlevel}{book}{%
  \pagestyle{bookmainmatter}
}{%
  \pagestyle{sectionmainmatter}
}%
\makeatother

% =============================================================================
% Title pages
% =============================================================================
% Book and chapter modes share the same TikZ renderer. Book mode follows it with
% an aligned information/citation page; section mode prints compact metadata.
\makeatletter
\newcommand{\nfm@selectcovertitlefont}{%
  \IfFontExistsTF{\@covertitlefont}{\fontspec{\@covertitlefont}}{\sffamily}%
}

\newcommand{\nfm@drawcoverimage}{%
  \ifdefempty{\@coverimage}{}{%
    \IfFileExists{\@coverimage}{%
      \node at ([yshift=-0.56\paperheight]current page.north) {%
        \includegraphics[
          width=0.62\paperwidth,
          height=0.40\paperheight,
          keepaspectratio
        ]{\@coverimage}%
      };%
    }{%
      \PackageWarning{noteformyself}{%
        Cover image file '\@coverimage' not found; continuing without it%
      }%
    }%
  }%
}

% One full-page renderer is shared by book and chapter modes.
\newcommand{\nfm@makecover}[1]{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begin{tikzpicture}[remember picture,overlay]
      \fill[\@coverpapercolor]
        (current page.south west) rectangle (current page.north east);
      \fill[\@coveraccentcolor]
        (current page.north west) rectangle
        ([yshift=-0.21\paperheight]current page.north east);

      \node[
        anchor=west,
        align=left,
        inner sep=0pt,
        text width=0.84\paperwidth
      ] at ([xshift=0.08\paperwidth,yshift=-0.105\paperheight]current page.north west) {%
        \nfm@selectcovertitlefont
        \raggedright
        \color{\@covertextcolor}
        \ifstrempty{#1}{}{%
          {\fontsize{10pt}{12pt}\selectfont\bfseries\MakeUppercase{#1}\par}%
          \vspace{8pt}%
        }%
        {\fontsize{34pt}{40pt}\selectfont\bfseries\@title\par}%
      };

      \nfm@drawcoverimage

      \ifdefempty{\@coversentence}{}{%
        \node[
          anchor=south east,
          align=flush right,
          text width=0.64\paperwidth
        ] at ([xshift=-0.08\paperwidth,yshift=0.13\paperheight]current page.south east) {%
          \color{\@covertextcolor}\large\itshape\@coversentence
        };%
      }%

      \node[
        anchor=south west,
        align=left,
        text width=0.84\paperwidth
      ] at ([xshift=0.08\paperwidth,yshift=0.055\paperheight]current page.south west) {%
        \sffamily\small\color{nfmMutedInk}
        \ifdefempty{\@author}{}{\textbf{\@author}\par}
        \@date
        \ifdefempty{\@version}{}{%
          \enspace\textperiodcentered\enspace Version \@version
        }%
      };
    \end{tikzpicture}
    \null
  \end{titlepage}%
}

\newcommand{\nfm@makecitation}{%
  \ifdefempty{\@citationkey}{}{%
    \vspace{1.8em}%
    {\sffamily\small\bfseries\color{nfmCoverInk}Suggested citation\par}%
    \vspace{0.55em}%
    \begingroup
      \ttfamily\footnotesize\raggedright
      @misc\{\@citationkey,\par
      \hangindent=1.5em\hangafter=1
      \hspace*{1.5em}author = \{\@author\},\par
      \hangindent=1.5em\hangafter=1
      \hspace*{1.5em}title = \{\@title\},\par
      \hangindent=1.5em\hangafter=1
      \hspace*{1.5em}year = \{\@copyrightyear\},\par
      \ifdefempty{\@version}{}{%
        \hangindent=1.5em\hangafter=1
        \hspace*{1.5em}version = \{\@version\},\par
      }%
      \ifdefempty{\@noteurl}{}{%
        \hangindent=1.5em\hangafter=1
        \hspace*{1.5em}url = \{%
          \expandafter\nolinkurl\expandafter{\@noteurl}%
        \},\par
      }%
      \}\par
    \endgroup
  }%
}

\newcommand{\nfm@makebookinfo}{%
  \begingroup
  \setlength{\parindent}{0pt}%
  \thispagestyle{empty}
  \vspace*{0.10\textheight}
  \begin{minipage}{0.84\textwidth}
    \raggedright
    \sffamily\bfseries\color{nfmCoverInk}\Huge\@title\par
  \end{minipage}\par
  \vspace{1.4em}
  {\large\@author\par}
  \ifdefempty{\@authoremail}{}{\vspace{0.4em}\@authoremail\par}
  \ifdefempty{\@authorpage}{}{\vspace{0.4em}\@authorpage\par}
  \nfm@makecitation
  \vfill
  {\small\color{nfmMutedInk}
    \ifdefempty{\@texsource}{}{\@texsource\par\vspace{0.35em}}
    \ifdefempty{\@version}{}{Version \@version\par\vspace{0.35em}}
    Last updated \@date\par\vspace{0.35em}
    Copyright © \@copyrightyear\ \@author\par
  }
  \clearpage
  \endgroup
}

\newcommand{\nfm@makesectionmetadata}{%
  \par\noindent
  \hfill
  {\sffamily\small\color{nfmMutedInk}
    \ifdefempty{\@author}{}{\@author}
    \ifdefempty{\@author}{}{%
      \ifdefempty{\@date}{}{\enspace\textperiodcentered\enspace}%
    }%
    \ifdefempty{\@date}{}{\@date}%
  }
  \par\vspace{1em}
}

\renewcommand{\maketitle}{%
  \ifdefstring{\@sectionlevel}{book}{%
    \nfm@makecover{}
    \nfm@makebookinfo
    \pagestyle{bookmainmatter}
  }{%
    \ifdefstring{\@sectionlevel}{chapter}{%
      \nfm@makecover{Chapter}
      \pagestyle{sectionmainmatter}
    }{%
      \pagestyle{sectionmainmatter}
      \nfm@makesectionmetadata
    }%
  }%
}
\makeatother

% =============================================================================
% Division headings
% =============================================================================
% Apply the visual hierarchy for each compilation mode, then wrap the resulting
% commands so tagged structural metadata does not interfere with titlesec.
\RequirePackage{titlesec} % Mode-specific chapter and section typography.
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\ifdefstring{\@sectionlevel}{book}{%
  \titleformat{\chapter}[display]
    {\thispagestyle{bookmainmatter}\sffamily\Huge\bfseries\color{nfmCoverInk}}
    {\chaptertitlename\ \thechapter}
    {10pt}
    {}
    [\vspace{1em}]
  \titleformat{\section}
    {\sffamily\LARGE\bfseries\color{nfmCoverInk}}
    {\thesection}
    {1em}
    {}
    []
  \titleformat{\subsection}[block]
    {\sffamily\Large\bfseries\color{nfmCoverInk}}
    {\thesubsection}{1em}{}
  \titlespacing{\section}{0pt}{3em}{1em}
}{%
  \ifdefstring{\@sectionlevel}{chapter}{%
    \renewcommand{\thesection}{\arabic{section}}
    \renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
    \titleformat{\section}[block]{\sffamily\LARGE\bfseries\color{nfmCoverInk}}{\thesection}{1em}{}
    \titleformat{\subsection}[block]
      {\sffamily\Large\bfseries\color{nfmCoverInk}}
      {\thesubsection}{1em}{}
  }{%
    \renewcommand{\thesubsection}{\arabic{subsection}}
    \titleformat{\section}[block]{\sffamily\LARGE\bfseries\color{nfmCoverInk}}{}{0em}{}
    \titleformat{\subsection}[block]
      {\sffamily\Large\bfseries\color{nfmCoverInk}}
      {\thesubsection}{1em}{}
  }%
}%
\makeatother

% titlesec may redefine the sectioning commands, so install the metadata
% wrappers only after all title formats have been configured.
\ExplSyntaxOn
\cs_if_exist:NT \chapter
  {
    \cs_new_eq:NN \nfm_base_chapter \chapter
    \RenewDocumentCommand \chapter { s o m }
      { \nfm_chapter_command:nnn {#1} {#2} {#3} }
  }
\cs_new_eq:NN \nfm_base_section \section
\RenewDocumentCommand \section { s o m }
  { \nfm_section_command:nnn {#1} {#2} {#3} }
\cs_new_eq:NN \nfm_base_subsection \subsection
\RenewDocumentCommand \subsection { s o m }
  { \nfm_subsection_command:nnn {#1} {#2} {#3} }
\ExplSyntaxOff
