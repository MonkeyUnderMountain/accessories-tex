% noteformyself --- a document class for personal mathematical notes
% Maintainer: Tianle Yang
% !TeX program = xelatex
% !Bib program = biber
% !TEX encoding = UTF-8 Unicode
\ProvidesClass{noteformyself}[2026/11/14 v2.1 personal mathematical notes]

% Public interface at a glance:
%   Class options: sectionlevel=book|chapter|section, status=draft|published
%   Metadata:      \authoremail, \authorpage, \citationkey, \noteurl,
%                  \coversentence, \coverimage, \texsource, \version
%   Optional tags: \usepackage{noteformyself-tags} adds \notesetup,
%                  tag registries, tagged headings, and external references.

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
\ifdefstring{\noteformyself@status}{draft}{}{%
  \ifdefstring{\noteformyself@status}{published}{}{%
    \ClassError{noteformyself}{Unknown status '\noteformyself@status'}
      {Use status=draft or status=published.}%
  }%
}

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
% A draft class option marks the output except full covers. Later \notesetup
% status changes affect publication validation only, not this watermark.
\makeatletter
\ifdefstring{\noteformyself@status}{draft}{%
  \RequirePackage{draftwatermark}%
}{}%
\makeatother
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


% Preserve the semantic reference type even though statements share a counter.
% Each alias is local to its environment; the optional tag package can still
% install its publication-aware label records without changing these styles.
\makeatletter
\newcommand{\nfm@statementreference}[1]{%
  \AtBeginEnvironment{#1}{\crefalias{definition}{#1}}%
}
\forcsvlist{\nfm@statementreference}{%
  definition,proposition,theorem,lemma,corollary,conjecture,question,remark,claim,example,%
  exercise,construction,notation}
\makeatother

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

\definecolor{nfmCoverAccent}{HTML}{397D7F}
\definecolor{nfmCoverSecondary}{HTML}{B58B52}
\definecolor{nfmCoverPaper}{HTML}{FFFFFF}
\definecolor{nfmCoverInk}{HTML}{17343E}
\definecolor{nfmMutedInk}{HTML}{667175}
\gdef\@coveraccentcolor{nfmCoverAccent}
\newcommand{\coveraccentcolor}[1]{\gdef\@coveraccentcolor{#1}}
\newcommand{\coverlinecolor}[1]{\coveraccentcolor{#1}}
\gdef\@coverpapercolor{nfmCoverPaper}
\newcommand{\coverpapercolor}[1]{\gdef\@coverpapercolor{#1}}
\gdef\@covertextcolor{nfmCoverInk}
\newcommand{\covertextcolor}[1]{\gdef\@covertextcolor{#1}}
\gdef\@covertitlefont{Libertinus Serif}
\newcommand{\covertitlefont}[1]{\gdef\@covertitlefont{#1}}

\gdef\@texsource{}
\newcommand{\texsource}[1]{\gdef\@texsource{#1}}
\gdef\@version{0.0.1}
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
  \fancyhead[LE]{\rmfamily\small\color{nfmMutedInk}\thepage}
  \fancyhead[RE]{\rmfamily\small\color{nfmMutedInk}\nouppercase{\leftmark}}
  \fancyhead[LO]{\rmfamily\small\color{nfmMutedInk}\nouppercase{\rightmark}}
  \fancyhead[RO]{\rmfamily\small\color{nfmMutedInk}\thepage}
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
  \IfFontExistsTF{\@covertitlefont}{\fontspec{\@covertitlefont}}{\rmfamily}%
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

% Preserve the original cover positions; colour is confined to fine rules.
\newcommand{\nfm@makecover}[1]{%
  \begin{titlepage}
    \thispagestyle{empty}
    % The old opaque cover hid this mark. Keep that appearance without a fill;
    % the titlepage group restores the document's watermark setting afterwards.
    \@ifpackageloaded{draftwatermark}{\DraftwatermarkOptions{stamp=false}}{}%
    \begin{tikzpicture}[remember picture,overlay]
      % Two coloured segments replace the old solid title band.
      \draw[\@coveraccentcolor,line width=1pt]
        ([xshift=0.08\paperwidth,yshift=-0.21\paperheight]current page.north west)
        -- ([xshift=0.69\paperwidth,yshift=-0.21\paperheight]current page.north west);
      \draw[nfmCoverSecondary,line width=1pt]
        ([xshift=0.71\paperwidth,yshift=-0.21\paperheight]current page.north west)
        -- ([xshift=0.92\paperwidth,yshift=-0.21\paperheight]current page.north west);
      \draw[\@coveraccentcolor!45,line width=0.4pt]
        ([xshift=0.08\paperwidth,yshift=0.105\paperheight]current page.south west)
        -- ([xshift=-0.08\paperwidth,yshift=0.105\paperheight]current page.south east);

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
        {\fontsize{32pt}{40pt}\selectfont\bfseries
          \spaceskip=1.25\fontdimen2\font\relax
          \@title\par}%
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
        \rmfamily\small\color{nfmMutedInk}
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
    {\rmfamily\small\bfseries\color{nfmCoverInk}Suggested citation\par}%
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
    \rmfamily\bfseries\color{nfmCoverInk}\Huge\@title\par
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
  {\rmfamily\small\color{nfmMutedInk}
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
      \nfm@makecover{}
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
% Preserve the original heading sizes, labels, and spacing; only the font
% family changes. The optional tag package wraps these finished commands.
\RequirePackage{titlesec} % Mode-specific chapter and section typography.
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\ifdefstring{\@sectionlevel}{book}{%
  \titleformat{\chapter}[display]
    {\thispagestyle{bookmainmatter}\rmfamily\Huge\bfseries\color{nfmCoverInk}}
    {\chaptertitlename\ \thechapter}
    {10pt}
    {}
    [\vspace{1em}]
  \titleformat{\section}
    {\rmfamily\LARGE\bfseries\color{nfmCoverInk}}
    {\thesection}
    {1em}
    {}
    []
  \titleformat{\subsection}[block]
    {\rmfamily\Large\bfseries\color{nfmCoverInk}}
    {\thesubsection}{1em}{}
  \titlespacing{\section}{0pt}{3em}{1em}
}{%
  \ifdefstring{\@sectionlevel}{chapter}{%
    \renewcommand{\thesection}{\arabic{section}}
    \renewcommand{\thesubsection}{\thesection.\arabic{subsection}}
    \titleformat{\section}[block]{\rmfamily\LARGE\bfseries\color{nfmCoverInk}}{\thesection}{1em}{}
    \titleformat{\subsection}[block]
      {\rmfamily\Large\bfseries\color{nfmCoverInk}}
      {\thesubsection}{1em}{}
  }{%
    \renewcommand{\thesubsection}{\arabic{subsection}}
    \titleformat{\section}[block]{\rmfamily\LARGE\bfseries\color{nfmCoverInk}}{}{0em}{}
    \titleformat{\subsection}[block]
      {\rmfamily\Large\bfseries\color{nfmCoverInk}}
      {\thesubsection}{1em}{}
  }%
}%
\makeatother

\endinput
