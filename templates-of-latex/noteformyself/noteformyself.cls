% 自定义文档类：noteformyself
% by Tianle Yang
% !TeX program = xelatex
% !Bib program = biber
% !TEX encoding = UTF-8 Unicode
\ProvidesClass{noteformyself}[2026/09/09, v 1.2.0, for notes to myself]


% 加载条件判断包（在使用\ifdefstring之前）
\RequirePackage{etoolbox}

% 定义类选项
\RequirePackage{kvoptions}
\SetupKeyvalOptions{
  family=noteformyself,
  prefix=noteformyself@
}

% 定义sectionlevel选项
\DeclareStringOption[section]{sectionlevel}
% 当前编译范围的发布状态；可用 \notesetup 在文档中按 section 改写。
\DeclareStringOption[draft]{status}

% 处理未知选项，传递给基础文档类
\DeclareDefaultOption{%
  \edef\@sectionlevel{\noteformyself@sectionlevel}%
  \ifdefstring{\@sectionlevel}{book}{%
    \PassOptionsToClass{\CurrentOption}{book}%
  }{%
    \PassOptionsToClass{\CurrentOption}{article}%
  }%
}

% 处理选项
\ProcessKeyvalOptions*

% 根据sectionlevel选项加载相应的基础文档类
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\ifdefstring{\@sectionlevel}{book}{%
  \LoadClass[12pt]{book} % 基础文档类（book）
}{%
  \LoadClass[12pt]{article} % 基础文档类（article）
}%
\makeatother

%--------------------------------------------------------------------------
% 页面布局配置
%--------------------------------------------------------------------------
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\RequirePackage{geometry}
\ifdefstring{\@sectionlevel}{book}{%
  % book模式页面设置
  \geometry{
    a4paper,
    top=58pt,
    bottom=36pt,
    left=36pt,
    right=36pt,
    includefoot,
    footskip=0pt
  }
}{%
  % 其他模式页面设置
  \geometry{
    a4paper,
    top=63pt,
    bottom=36pt,
    left=36pt,
    right=36pt,
    includefoot,
    footskip=0pt
  }
}%
\makeatother

\renewcommand{\baselinestretch}{1.2} % 行距1.2倍




%--------------------------------------------------------------------------
% 警告过滤配置（抑制常见编译警告）
%--------------------------------------------------------------------------
\RequirePackage{silence}
\WarningFilter{fancyhdr}{\headheight is too small}  % 抑制页眉高度警告
\WarningFilter{fancyhdr}{\footheight is too small}  % 抑制页脚高度警告
\WarningFilter{fancyhdr}{\footskip is too small}    % 抑制页脚间距警告
\WarningFilter{hyperref}{Ignoring empty anchor}     % 抑制空锚点警告




%--------------------------------------------------------------------------
% 核心包加载
%--------------------------------------------------------------------------
% 基础功能包
\RequirePackage{graphicx}                             % 图形插入支持
\RequirePackage{longtable}                            % 长表格支持
\RequirePackage{amsmath,amsthm,amssymb,amsfonts}      % 数学符号和字体支持
\RequirePackage[dvipsnames]{xcolor}                   % 颜色支持
\RequirePackage{tikz}                                 % 矢量绘图
\RequirePackage{pstricks-add}                         % PSTricks扩展
\RequirePackage{tikz-cd}                              % 交换图绘制
\RequirePackage[all]{xy}                              % 交换图绘制
\RequirePackage{mathtools}                            % 数学工具包（提供多种数学环境和命令）

% 中文支持
\RequirePackage[scheme=plain]{ctex}   % 中文基础方案
\RequirePackage{fontspec}             % 字体配置

% Unicode数学字体支持 - 必须在mathtools之后加载
\RequirePackage[warnings-off={mathtools-colon,mathtools-overbracket}]{unicode-math}  
% 设置数学字体：先建立一个 TeX Live 自带的主字体，再按可用性覆盖。
% 使用文件名可避免不同系统的 Fontconfig 字体族名称不一致。
\setmathfont{latinmodern-math.otf}
\IfFontExistsTF{STIXTwoMath-Regular.otf}{
  \setmathfont{STIXTwoMath-Regular.otf}
}{}
\IfFontExistsTF{Cambria Math}{
  \setmathfont{Cambria Math}[range={\mathalpha}] % Cambria Math is only available on Windows.
}{
  \setmathfont{latinmodern-math.otf}[range={\mathalpha}] % fallback for non-Windows systems
}
\IfFontExistsTF{LibertinusMath-Regular.otf}{
  \setmathfont{LibertinusMath-Regular.otf}[range=bb]
  \setmathfont{LibertinusMath-Regular.otf}[range=scr]
}{}
\IfFontExistsTF{STIXTwoMath-Regular.otf}{
  \setmathfont{STIXTwoMath-Regular.otf}[range=cal] % supports lowercase calligraphic letters
}{}
% \setmathfont{XITS Math}[range=scr] % like scr, support lowercase
% \setmathfont{TeX Gyre Termes Math}[range=scr] % like scr, support lowercase 
% \setmathfont{Latin Modern Math}  % like cal, do not support lowercase
% \setmathfont{Asana Math}[range=scr] % like scr, support lowercase
% \setmathfont{Fira Math} % like sf, lack many fonts
% \setmathfont{Euler Math} % like 

% 引用系统
\RequirePackage[backend=biber,style=alphabetic,backref]{biblatex} % 参考文献管理
\ExecuteBibliographyOptions{maxbibnames=99}                       % 显示所有作者

% 交互功能
\RequirePackage{xr-hyper}      % 跨文档标签和超链接支持
\RequirePackage{hyperref}       % 超链接支持
\hypersetup{
  colorlinks = true,            % 链接颜色
  linkcolor = blue,             % 跳转到文档内部
  urlcolor = magenta,           % 跳转到外部链接
  citecolor=cyan,               % 参考文献引用
  hypertexnames=false,          % 禁止重复的锚点名称
}
\RequirePackage[nameinlink]{cleveref} % 智能引用（自动添加前缀）

% 列表环境标号配置
\RequirePackage{enumitem}       % Required for custom labels
\setlist[enumerate,1]{label=(\alph*)} % 第一层级：小写字母加括号 (a), (b), ...)
\setlist[enumerate,2]{label=(\roman*)} % 第二层级：小写罗马数字加括号 (i), (ii), ...)

% allow display as equations breaks across pages
\allowdisplaybreaks





%--------------------------------------------------------------------------
% 定理环境可视化配置
%--------------------------------------------------------------------------
\RequirePackage[most]{tcolorbox} % 彩色盒子环境

% 定理标签由包装环境在定理标题生成前设置。
\newcommand{\noteformyselfstatementtag}{}

% 定义定理样式模板
\newtheoremstyle{mystyle}{}{}{}{}{\bfseries}{.}{ }{%
  \thmname{#1}\thmnumber{ #2}\thmnote{ (#3)}\noteformyselfstatementtag}
\theoremstyle{mystyle}

% 定义具体定理环境（共享计数器）
\makeatletter
\ifdefstring{\@sectionlevel}{book}{%
  % 书籍级别：book模式
  \newtheorem{definition}{Definition}[section] % 定义环境按章节编号
}{%
  \ifdefstring{\@sectionlevel}{chapter}{%
    % 章节级别：chapter模式
    \newtheorem{definition}{Definition}[section] % 定义环境按章节编号
  }{%
    % 章节级别：section模式（默认）
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
\newtheorem{mainthm}{Theorem} % main theorem with global numbering
\renewcommand{\themainthm}{\Alph{mainthm}} % Display as A, B, C, ...

% 定义step子环境（在proof环境中使用，每个proof重置计数器）
\newcounter{step}
\newcounter{globalstep} % Global unique step counter for anchors
% 使用全局唯一计数器globalstep进行引用，但显示本地计数器step的值
\newenvironment{step}[1][]{%
  \refstepcounter{step}%
  \refstepcounter{globalstep}% This creates unique anchors
  \par\smallskip%
  \noindent\textbf{Step \thestep\if\relax\detokenize{#1}\relax\else\ (#1)\fi.}\ %
}{%
  \par\smallskip%
}
% 重新定义globalstep的显示格式，让它显示为local step number
\renewcommand{\theglobalstep}{\arabic{step}}

% 定义case子环境（在proof环境中使用，每个proof重置计数器）
\newcounter{case}
\newcounter{globalcase} % Global unique case counter for anchors
% 使用全局唯一计数器globalcase进行引用，但显示本地计数器case的值
\newenvironment{case}[1][]{%
  \refstepcounter{case}%
  \refstepcounter{globalcase}% This creates unique anchors
  \par\smallskip%
  \noindent\textbf{Case \thecase\if\relax\detokenize{#1}\relax\else\ (#1)\fi.}\ %
}{%
  \par\smallskip%
}
% 重新定义globalcase的显示格式，让它显示为local case number
\renewcommand{\theglobalcase}{\arabic{case}}

% 在proof环境开始时重置step和case计数器
\AtBeginEnvironment{proof}{%
  \setcounter{case}{0}%
  \setcounter{step}{0}%
}

% 设置cleveref引用格式
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
\crefname{globalstep}{Step}{Steps} % Global unique step counter
\crefname{globalcase}{Case}{Cases} % Global unique case counter
\crefname{section}{Section}{Sections}
\crefname{subsection}{Subsection}{Subsections}
\crefname{mainthm}{Theorem}{Theorems}


% 定义有背景色的定理环境样式，应用于definition, proposition, theorem, lemma, corollary, conjecture, question
\newcommand{\mybackgroundtcbsetup}[3]{%
  \tcolorboxenvironment{#1}{
    boxrule=0pt,
    boxsep=0pt,
    colback={#2!10},
    left=8pt,
    right=8pt,
    enhanced jigsaw,
    borderline west={2pt}{0pt}{#2},
    sharp corners,
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

% 定义背景色的remark, example, claim, step, exercise环境样式
\newcommand{\myemptybgtcdsetup}[3]{%
  \tcolorboxenvironment{#1}{
    boxrule=0pt,
    boxsep=0pt,
    blanker,             % 清除所有默认样式
    borderline west={2pt}{0pt}{#2}, % 左侧线
    left=8pt,
    right=8pt,
    sharp corners,
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


% 定义slogan环境
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


%--------------------------------------------------------------------------
% 永久标签、发布状态与跨文档引用
%--------------------------------------------------------------------------
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

% 当前编译范围的元数据。book/chapter/section 标签是稳定 ID，而不是编号。
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
          { \nfm_validate_prefix:NNnn \g_nfm_section_tag_tl \g_nfm_chapter_tag_tl { chapter } { 3 } }
      }
  }

\NewDocumentCommand \notesetup { m }
  {
    \keys_set:nn { nfm/setup } {#1}
    \nfm_validate_context:
  }

% External global tag registry.
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

% Per-entry metadata.
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
            \exp_not:V \l_nfm_statement_tag_tl)
          }
        \tl_set:Nx \l_nfm_statement_external_reference_tl
          {
            [\exp_not:V \l_tmpa_tl,\c_space_tl
            #2\c_space_tl \exp_not:V \l_nfm_statement_number_tl,
            \c_space_tl Tag\c_space_tl \exp_not:V \l_nfm_statement_tag_tl]
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

% Publication-aware chapter, section, and subsection metadata.  Subsections
% are tagged referenceable items, not a new allocation or status scope; their
% seven-character tags share the section-level pool with theorem-like entries.
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
            \exp_not:V \l_nfm_division_tag_tl)
          }
        \tl_set:Nx \l_nfm_division_external_reference_tl
          {
            [\exp_not:V \l_tmpa_tl,\c_space_tl
            #2\c_space_tl \exp_not:V \l_nfm_division_number_tl,
            \c_space_tl Tag\c_space_tl \exp_not:V \l_nfm_division_tag_tl]
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
      { \nfm_division_command:Nnnnnn \nfm_base_subsection { subsection } { Subsection } { 7 } {#2} {#3} }
  }

\tl_new:N \l_nfm_external_prefix_tl

\cs_new_protected:Npn \nfm_external_reference:nn #1#2
  {
    \cs_gset:cpn
      { r@\tl_use:N \l_nfm_external_prefix_tl #1@cref }
      {#2}
  }

\NewDocumentCommand \NoteExternalReference { m m }
  { \nfm_external_reference:nn {#1} {#2} }

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




%--------------------------------------------------------------------------
% 代码块配置
%--------------------------------------------------------------------------
\RequirePackage{listings}     % 代码高亮支持
% 定义颜色
\definecolor{codegreen}{rgb}{0,0.6,0}
\definecolor{codegray}{rgb}{0.5,0.5,0.5}
\definecolor{codepurple}{rgb}{0.58,0,0.82}
\definecolor{backcolour}{rgb}{0.95,0.95,0.92}

% 定义 listings 风格，可以定义多个
\lstdefinestyle{mystyle}{
    backgroundcolor=\color{backcolour},  % 背景色
    commentstyle= \color{red!50!green!50!blue!50},  % 注释的颜色
    keywordstyle= \color{blue!70},  % 关键字/程序语言中的保留字颜色
    numberstyle=\tiny\color{codegray},  % 左侧行号显示的颜色
    stringstyle=\color{codepurple},
    basicstyle=\ttfamily\footnotesize,
    breakatwhitespace=false,
    breaklines=true,  % 对过长的代码自动换行
    captionpos=b,
    keepspaces=true,
    numbers=left,  % 在左侧显示行号
    numbersep=5pt,
    showspaces=false,
    showstringspaces=false,  % 不显示字符串中的空格
    showtabs=false,
    tabsize=2,
    frame=single  % [none | single | shadowbox] 显示边框
}
\lstset{style=mystyle}  % 使用 listings 风格

\crefname{lstlisting}{Code}{Codes} % 设置cleveref引用格式




%--------------------------------------------------------------------------
% 文档元数据定义
%--------------------------------------------------------------------------
\makeatletter
% 作者信息处理
\let\oldauthor\author
\renewcommand{\author}[1]{%
  \oldauthor{#1}%
  \gdef\@author{#1}%
}
\gdef\@author{} % 初始化作者变量
% 标题信息处理
\let\oldtitle\title
\renewcommand{\title}[1]{%
  \oldtitle{#1}%
  \gdef\@title{#1}%
}
\gdef\@title{} % 初始化标题变量
% 日期信息处理
\let\olddate\date
\renewcommand{\date}[1]{%
  \olddate{#1}%
  \gdef\@date{#1}%
}
\gdef\@date{} % 初始化日期变量
% 自定义封面元素
\gdef\@authoremail{}     % 作者邮箱
\newcommand{\authoremail}[1]{\gdef\@authoremail{#1}}
\gdef\@authorpage{}     % 作者主页
\newcommand{\authorpage}[1]{\gdef\@authorpage{#1}} 
\gdef\@coversentence{}  % 封面标语
\newcommand{\coversentence}[1]{\gdef\@coversentence{#1}}
\gdef\@coverimage{}     % 封面图片路径
\newcommand{\coverimage}[1]{\gdef\@coverimage{#1}}
\gdef\@coverlinecolor{orange!80!yellow} % 封面装饰线颜色
\newcommand{\coverlinecolor}[1]{\gdef\@coverlinecolor{#1}}
\gdef\@covertitlefont{Arial}  % 封面标题字体
\newcommand{\covertitlefont}[1]{\gdef\@covertitlefont{#1}}
\gdef\@covertextcolor{purple!70!blue}   % 封面文字颜色
\newcommand{\covertextcolor}[1]{\gdef\@covertextcolor{#1}}
\gdef\@texsource{} % TeX源代码路径
\newcommand{\texsource}[1]{\gdef\@texsource{#1}}
\gdef\@version{1.0.0} % 文档版本
\newcommand{\version}[1]{\gdef\@version{#1}}
\gdef\@copyrightyear{\number\year} % 版权声明
\newcommand{\copyrightyear}[1]{\gdef\@copyrightyear{#1}}
\makeatother




%--------------------------------------------------------------------------
% 页眉页脚样式配置
%--------------------------------------------------------------------------
% 页面装饰
\RequirePackage{fancyhdr}       % 页眉页脚定制
\RequirePackage[bottom,multiple]{footmisc} % 脚注增强

% 统一灰色页眉线命令
\newcommand{\grayheadrule}{
  \vbox to 2pt{%
      \color{gray}%
      \hrule width \headwidth height \headrulewidth%
      \vss%
    }%
}
% 统一灰色页脚线命令
\newcommand{\grayfootrule}{
  \vbox to -10pt{%
      \color{gray}%
      \hrule width \headwidth height \headrulewidth%
      \vss%
    }%
}
% section/chapter模式
\makeatletter
\fancypagestyle{sectionmainmatter}{
  \pagestyle{fancy}
  % 页眉样式
    \fancyhead[R]{%
      	\tikz[baseline=(char.base)]{
        \node[shape=rectangle,fill=gray,text=white,inner sep=2pt] (char) {\thepage};
      }%
    }
  \fancyhead[L]{\nouppercase{\@title}}
  \renewcommand{\headrulewidth}{4pt}
  \renewcommand{\headrule}{\grayheadrule}
  % 页脚样式（留空）
  \renewcommand{\footrule}{\grayfootrule}
  \fancyfoot{}
}
\makeatother
% book模式
\fancypagestyle{bookmainmatter}{
  \fancyhead[LO]{\leftmark}
  \fancyhead[RO]{\tikz[baseline=(char.base)]{\node[rectangle,fill=gray,text=white,inner sep=2pt] (char) {\thepage};}}
  \fancyhead[LE]{\tikz[baseline=(char.base)]{\node[rectangle,fill=gray,text=white,inner sep=2pt] (char) {\thepage};}}
  \fancyhead[RE]{\rightmark}
  \renewcommand{\headrulewidth}{4pt}
  \renewcommand{\headrule}{\grayheadrule}
  \renewcommand{\footrule}{\grayfootrule}
  \fancyfoot{}
}
\makeatletter
% Redefine \leftmark and \rightmark for non-uppercase chapter/section names
\ifdefstring{\@sectionlevel}{book}{%
  \renewcommand{\chaptermark}[1]{%
    \markboth{\thechapter.\ #1}{}
  }
  \renewcommand{\sectionmark}[1]{%
    \markright{\thesection.\ #1}
  }
}{%
}%
% apply the mainmatter pagestyle
\ifdefstring{\@sectionlevel}{book}{%
  \pagestyle{bookmainmatter}
}{%
  \pagestyle{sectionmainmatter}
}%
\makeatother




%--------------------------------------------------------------------------
% 封面页重定义
%--------------------------------------------------------------------------
% Prevent redefinition errors when trimclip/adjustbox defines these macros
\let\trimbox\relax
\let\clipbox\relax
\let\marginbox\relax
\RequirePackage{adjustbox}      % 高级图片调整（支持max width/height）
\makeatletter
\renewcommand{\maketitle}{%
  \ifdefstring{\@sectionlevel}{book}{%
    % --- Book模式: 全页封面 ---
    \newgeometry{top=45pt, bottom=51pt, left=36pt, right=36pt, includefoot, footskip=0pt}
    \begin{titlepage}
      \thispagestyle{fancy}
      % 装饰线参数
      \gdef\biglineheight{10pt}
      \gdef\smalllineheight{4pt}
      \gdef\spaceheight{11pt}
      % 页眉装饰线
      \renewcommand{\headrule}{%
        \vbox to 0pt{%
          \color{\@coverlinecolor}%
          \hrule width \headwidth height \biglineheight%
          \vspace{\spaceheight}%
          \hrule width \headwidth height \smalllineheight%
          \vss%
        }%
      }
      \renewcommand{\headrulewidth}{2mm}
      \fancyhead{}
      % 页脚装饰线
      \renewcommand{\footrule}{%
        \vbox to 0pt{%
          \color{\@coverlinecolor}%
          \hrule width \headwidth height \smalllineheight%
          \vspace{\spaceheight}%
          \hrule width \headwidth height \biglineheight%
          \vss%
        }%
      }
      \fancyfoot{}
      % 标题
      \vspace*{1mm}
      \begin{flushleft}
        \begin{minipage}{0.8\textwidth}
          \fontspec{\@covertitlefont}
          \fontsize{40pt}{48pt}\selectfont
          \textcolor{\@covertextcolor}{\@title}
        \end{minipage}
      \end{flushleft}
      % 封面图片
      \vfill
      \ifx\@coverimage\@empty
        \PackageWarning{noteformyself}{No cover image specified. Use \string\coverimage{filename} to add a cover image}%
        \begin{center}
          \fbox{\parbox{0.48\textwidth}{%
            \centering
            \vspace{2cm}
            \textcolor{gray}{\Large No Cover Image}\\[0.5cm]
            \textcolor{gray}{\footnotesize Use \texttt{\textbackslash coverimage\{filename\}} to add an image}
            \vspace{2cm}
          }}
        \end{center}
      \else
        \IfFileExists{\@coverimage}{%
          \begin{figure}[ht]
            \centering
            \adjustimage{max width=0.6\textwidth, max height=0.4\textheight, keepaspectratio}{\@coverimage}
          \end{figure}
        }{%
          \PackageError{noteformyself}{Cover image file '\@coverimage' not found}{%
            Please check that the file '\@coverimage' exists in your project directory.%
          }%
          \begin{center}
            \fbox{\parbox{0.48\textwidth}{%
              \centering
              \vspace{2cm}
              \textcolor{red}{\Large Image Not Found}\\[0.5cm]
              \textcolor{red}{\footnotesize File '\@coverimage' does not exist}
              \vspace{2cm}
            }}
          \end{center}
        }
      \fi
      % 标语
      \vspace{0.8cm}
      \begin{flushright}
        \begin{minipage}{0.8\textwidth}
          \begin{flushright}
            \large \textcolor{\@covertextcolor}{\@coversentence}
          \end{flushright}
        \end{minipage}
      \end{flushright}
      \vspace{0.8cm}
    \end{titlepage}
    \restoregeometry
    \clearpage
    % 信息页
    \thispagestyle{empty}
    \noindent {\Huge \textbf{\@title}}\\[0.5cm]
    {\large \textbf{Author:} \@author}\\[0.5cm]
    {\large \textbf{Email:} \@authoremail}\\[0.5cm]
    {\large \textbf{Homepage:} \@authorpage}\\[0.5cm]
    \vfill
    \noindent {\large \textit{Source code: \@texsource}}\\[0.5cm]
    {\large \textit{Version: \@version}}\\[0.5cm]
    {\large \textit{Last updated: \@date}}\\[0.5cm]
    {\large \textit{Copyright © \@copyrightyear\ \@author}}
    \clearpage
    \pagestyle{bookmainmatter}
  }{%
    \ifdefstring{\@sectionlevel}{chapter}{%
      % --- Chapter模式: 全页封面 ---
      \newgeometry{top=50pt, bottom=51pt, left=36pt, right=36pt, includefoot, footskip=0pt}
      \begin{titlepage}
        \thispagestyle{fancy}
        % 装饰线参数
        \gdef\biglineheight{10pt}
        \gdef\smalllineheight{4pt}
        \gdef\spaceheight{11pt}
        % 页眉装饰线
        \renewcommand{\headrule}{%
          \vbox to 0pt{%
            \color{\@coverlinecolor}%
            \hrule width \headwidth height \biglineheight%
            \vspace{\spaceheight}%
            \hrule width \headwidth height \smalllineheight%
            \vss%
          }%
        }
        \renewcommand{\headrulewidth}{2mm}
        \fancyhead{}
        % 页脚装饰线
        \renewcommand{\footrule}{%
          \vbox to 0pt{%
            \color{\@coverlinecolor}%
            \hrule width \headwidth height \smalllineheight%
            \vspace{\spaceheight}%
            \hrule width \headwidth height \biglineheight%
            \vss%
          }%
        }
        \fancyfoot{}
        % 标题
        \vspace*{1mm}
        \begin{flushleft}
          \begin{minipage}{0.8\textwidth}
            \fontspec{\@covertitlefont}
            \fontsize{40pt}{48pt}\selectfont
            \textcolor{\@covertextcolor}{\@title}
          \end{minipage}
        \end{flushleft}
        % 封面图片
        \vfill
        \ifx\@coverimage\@empty
          \PackageWarning{noteformyself}{No cover image specified. Use \string\coverimage{filename} to add a cover image}%
          \begin{center}
            \fbox{\parbox{0.48\textwidth}{%
              \centering
              \vspace{2cm}
              \textcolor{gray}{\Large No Cover Image}\\[0.5cm]
              \textcolor{gray}{\footnotesize Use \texttt{\textbackslash coverimage\{filename\}} to add an image}
              \vspace{2cm}
            }}
          \end{center}
        \else
          \IfFileExists{\@coverimage}{%
            \begin{figure}[ht]
              \centering
              \adjustimage{max width=0.6\textwidth, max height=0.4\textheight, keepaspectratio}{\@coverimage}
            \end{figure}
          }{%
            \PackageError{noteformyself}{Cover image file '\@coverimage' not found}{%
              Please check that the file '\@coverimage' exists in your project directory.%
            }%
            \begin{center}
              \fbox{\parbox{0.48\textwidth}{%
                \centering
                \vspace{2cm}
                \textcolor{red}{\Large Image Not Found}\\[0.5cm]
                \textcolor{red}{\footnotesize File '\@coverimage' does not exist}
                \vspace{2cm}
              }}
            \end{center}
          }
        \fi
        % 标语
        \vspace{0.8cm}
        \begin{flushright}
          \begin{minipage}{0.8\textwidth}
            \begin{flushright}
              \large \textcolor{\@covertextcolor}{\@coversentence}
            \end{flushright}
          \end{minipage}
        \end{flushright}
        \vspace{0.8cm}
      \end{titlepage}
      \restoregeometry
      \clearpage
      % 设置正文样式
      \pagestyle{sectionmainmatter}
      % 信息脚注
      \renewcommand{\thefootnote}{}
      \noteformyself@footnotetext
      \renewcommand{\thefootnote}{\fnsymbol{footnote}}
    }{%
      % --- Section模式: 简化封面 ---
      \pagestyle{sectionmainmatter}
      \renewcommand{\thefootnote}{}
      \noteformyself@footnotetext
      \renewcommand{\thefootnote}{\fnsymbol{footnote}}
    }%
  }%
}
% 封面脚注文本
\newcommand{\noteformyself@footnotetext}{%
  \footnotetext{\textbf{Date}: \@date,\ \textbf{Author}: \@author,\ \@authorpage}%
}
\makeatother




%--------------------------------------------------------------------------
% 章节标题格式配置
%--------------------------------------------------------------------------
\RequirePackage{titlesec}
% 定义sectionlevel命令来控制章节级别
\makeatletter
\edef\@sectionlevel{\noteformyself@sectionlevel}
\ifdefstring{\@sectionlevel}{book}{%
  % 书籍级别：book模式 
  \titleformat{\chapter}[display]
    {\thispagestyle{bookmainmatter}\normalfont\Huge\bfseries} % 标题样式
    {\chaptertitlename\ \thechapter} % 章节编号格式
    {10pt} % 标题与编号间距
    {} % 标题前命令
    [\vspace{1em}] % 标题后命令
  \titleformat{\section}
    {\normalfont\LARGE\bfseries} % 小节标题样式
    {\thesection} % 小节编号格式
    {1em} % 标题与编号间距
    {} % 小节标题前命令
    [] % 小节标题后命令
  \titlespacing{\section}{0pt}{3em}{1em} % 小节标题前后间距
}{%
  \ifdefstring{\@sectionlevel}{chapter}{%
    % 章节级别：chapter模式
    \renewcommand{\thesection}{\arabic{section}}  % 章节编号：1, 2, 3...
    \renewcommand{\thesubsection}{\thesection.\arabic{subsection}}  % 小节编号：1.1, 1.2...
    \titleformat{\section}[block]{\normalfont\LARGE\bfseries}{\thesection}{1em}{}
    \titleformat{\subsection}[block]{\normalfont\Large\bfseries}{\thesubsection}{1em}{}
  }{%
    % 章节级别：section模式（默认）
    \renewcommand{\thesubsection}{\arabic{subsection}}  % 小节编号格式
    \titleformat{\section}[block]{\normalfont\LARGE\bfseries}{}{0em}{}
    \titleformat{\subsection}[block]{\normalfont\Large\bfseries}{\thesubsection}{1em}{}
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
