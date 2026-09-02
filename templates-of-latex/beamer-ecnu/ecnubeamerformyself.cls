% ECNU Beamer Class 
% maintained by Tianle Yang, forked from https://www.texpage.com/zh/template/8c704e26-abab-4864-9174-36e86914c506/
% !TeX program = xelatex
% !Bib program = biber
% !TEX encoding = UTF-8 Unicode
\NeedsTeXFormat{LaTeX2e}               % Require LaTeX2e
\ProvidesClass{ecnubeamerformyself}[2025/12/28 v1.00 ECNU Beamer Class] % Provide class metadata

% Pass all unknown options through to beamer
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}} % Forward options
\ProcessOptions\relax

% Force top alignment for frames (make content align up instead of centered)
\PassOptionsToClass{t}{beamer}

% Load base class
\LoadClass{beamer}                     % Base beamer class

% Theme: Metropolis with footer progress bar and fractional numbering
\usetheme[progressbar=foot, numbering=fraction]{metropolis} % Metropolis theme

% Disable Beamer automatic section pages (show no dedicated section slide)
\AtBeginSection{}% prevent beamer from inserting section pages
\setbeamertemplate{section page}{}% clear any section page template




% --------------------------------------------------------------------------
% Core packages and configurations
% --------------------------------------------------------------------------
\RequirePackage{graphicx}                    		% Include graphics (\includegraphics)
\RequirePackage{longtable}                			% Multi-page tables (longtable environment)
\RequirePackage{amsmath,amsthm,amssymb,amsfonts} 	% Standard AMS math packages
\RequirePackage{thmtools}              				% Advanced theorem tools (declaretheorem, etc.)
\RequirePackage[dvipsnames]{xcolor}    				% Extended color names
\RequirePackage{tikz}                  				% TikZ drawing
\RequirePackage{pstricks-add}          				% PSTricks extensions (may be incompatible with pdf engines)
\RequirePackage{tikz-cd}               				% Commutative diagrams with TikZ
\RequirePackage[all]{xy}              				% XY package for diagrams (alternative)
\RequirePackage{mathtools}            				% Extensions to amsmath


% Chinese and font support
\RequirePackage[scheme=plain]{ctex}    % ctex for Chinese typesetting (lightweight scheme)
\RequirePackage{fontspec}              % Font selection (XeLaTeX/LuaLaTeX)

% Unicode math (load after mathtools)
\RequirePackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math} % Unicode math support

% Math font setup (each line commented)
\setmathfont{STIX Two Math}            % Primary math font (STIX Two Math)
\IfFontExistsTF{Cambria Math}{%
  \setmathfont{Cambria Math}[range={\mathalpha}] % Use Cambria Math for alphabetic math glyphs on Windows
}{%
  \setmathfont{Latin Modern Math}[range={\mathalpha}] % Fallback alphabetic math font if Cambria not found
}
\setmathfont{Libertinus Math}[range=bb] % Blackboard-bold glyphs from Libertinus Math
\setmathfont{STIX Two Math}[range=cal] % Calligraphic alphabet from STIX Two Math
\setmathfont{Libertinus Math}[range=scr] % Script alphabet from Libertinus Math


% Bibliography system
\RequirePackage[backend=biber,style=alphabetic,backref]{biblatex} % biber backend, alphabetic style, and backrefs




% --------------------------------------------------------------------------
% Color definitions and beamer color tweaks
% --------------------------------------------------------------------------
\definecolor{ECNURed}{RGB}{164,31,53}  % ECNU primary red color

\setbeamercolor{alerted text}{fg = ECNURed}  % Color for alerted text
\setbeamercolor{frametitle}{fg = ECNURed}    % Frame title text color (no background)
\setbeamertemplate{frametitle}{%
  \vskip1ex%
  \nointerlineskip%
  {\usebeamerfont{frametitle}\usebeamercolor[fg]{frametitle}\insertframetitle\par}%
  \vskip-1.2ex%
}
\setbeamercolor{progress bar}{fg = ECNURed}  % Progress bar color




% --------------------------------------------------------------------------
% Define the marcos for image paths
% --------------------------------------------------------------------------
% Default image paths (can be overridden in document preamble)
\providecommand{\ECNUBackgroundImage}{img/bg.pdf}
\providecommand{\ECNUFrameLogoImage}{img/logo-white.pdf}
\providecommand{\ECNUFirstPageBG}{img/firstpagebg.jpg}
\providecommand{\ECNUMathLogo}{img/math-logo.pdf}
\providecommand{\ECNULibThanks}{img/lib.png}




% --------------------------------------------------------------------------
% Background and title page layout
% --------------------------------------------------------------------------
% Layout and utilities
\RequirePackage{textpos}               % Absolute positioning (used to place logos)
\RequirePackage{pgfplots}              % Plots with TikZ/PGF
\usepgfplotslibrary{dateplot}          % Date plots support for pgfplots

% tcolorbox for boxed theorem-like environments
\RequirePackage{tcolorbox}             % Highly configurable colored boxes
\tcbuselibrary{skins,breakable,theorems} % tcolorbox libraries used


% Background image filling the slide
\setbeamertemplate{background}{%
  \includegraphics[width=\paperwidth,height=\paperheight]{\ECNUBackgroundImage} % Background image
}

% Custom title page: vertical centering and conditional elements
\makeatletter
\setbeamertemplate{title page}{%
  \begin{minipage}[b][\paperheight]{\textwidth}
    \vfill
    \ifx\inserttitle\@empty\else\usebeamertemplate*{title}\fi
    \ifx\insertsubtitle\@empty\else\usebeamertemplate*{subtitle}\fi
    \usebeamertemplate*{title separator}
    \ifx\beamer@shortauthor\@empty\else\usebeamertemplate*{author}\fi
    \ifx\insertdate\@empty\else\usebeamertemplate*{date}\fi
    \ifx\insertinstitute\@empty\else\usebeamertemplate*{institute}\fi
    \vfill

    % Optional title graphic placement
    \vspace*{-2.5cm}
    \ifx\inserttitlegraphic\@empty\else\inserttitlegraphic\fi
    \vspace*{1cm}
  \end{minipage}
}
\makeatother

% Metropolis visual adjustments (tweak line widths)
\makeatletter
\setlength{\metropolis@titleseparator@linewidth}{0.6pt}         % Title separator thickness
\setlength{\metropolis@progressonsectionpage@linewidth}{1pt}    % Section page progress width
\setlength{\metropolis@progressinheadfoot@linewidth}{4pt}       % Head/foot progress bar thickness
\makeatother

% Add a small logo at the top-right of frame titles using absolute positioning
% \addtobeamertemplate{frametitle}{}{%
%   \begin{textblock*}{100mm}(.97\textwidth,-1.02cm) % Position block near top-right
%     \includegraphics[height=0.9cm]{\ECNUFrameLogoImage} % Logo file
%   \end{textblock*}%
% }




% --------------------------------------------------------------------------
% Theorem-like environments using tcolorbox (consistent boxed styling)
% --------------------------------------------------------------------------
% Helper: define a tcolorbox-based environment with a title and optional name
% #1 = environment name, #2 = displayed title
\newcommand{\newtcolorboxinmysetting}[2]{%
  \newtcolorbox{#1}[1][]{%
    enhanced,                                % Enable advanced features
    colback=ECNURed!5!white,                 % Light background tint
    colframe=ECNURed,                        % Frame color
    fonttitle=\bfseries,                     % Bold title font
    title={#2\if\relax\detokenize{##1}\relax\else: ##1\fi}, % Title with optional argument
    sharp corners,                           % Sharp corners
    boxrule=0.4mm,                           % Frame thickness
    left=1mm, right=1mm, top=-2mm, bottom=0mm,% Inner padding
    boxsep=1mm,                              % Separation between content and frame
    before skip=5pt, after skip=5pt,         % Vertical spacing before/after
    breakable,                               % Allow page/slide breaks
  }%
}

% Undefine existing theorem names (if any) then create boxed versions
\let\definition\relax
\let\enddefinition\relax
\newtcolorboxinmysetting{definition}{Definition}

\let\theorem\relax
\let\endtheorem\relax
\newtcolorboxinmysetting{theorem}{Theorem}

\let\lemma\relax
\let\endlemma\relax
\newtcolorboxinmysetting{lemma}{Lemma}

\let\proposition\relax
\let\endproposition\relax
\newtcolorboxinmysetting{proposition}{Proposition}

\let\corollary\relax
\let\endcorollary\relax
\newtcolorboxinmysetting{corollary}{Corollary}

\newtcolorboxinmysetting{conjecture}{Conjecture}
\newtcolorboxinmysetting{question}{Question}




% --------------------------------------------------------------------------
% Miscellaneous settings
% --------------------------------------------------------------------------
% Reduce vertical space around displayed equations for beamer slides.
% Applied at \AtBeginDocument so document classes/themes can't override it.
\AtBeginDocument{%
  \setlength{\abovedisplayskip}{0pt}%
  \setlength{\belowdisplayskip}{0pt}%
  \setlength{\abovedisplayshortskip}{0pt}%
  \setlength{\belowdisplayshortskip}{0pt}%
}
\renewcommand{\emph}[1]{\textbf{#1}} % Redefine \emph to use bold text instead of italics
