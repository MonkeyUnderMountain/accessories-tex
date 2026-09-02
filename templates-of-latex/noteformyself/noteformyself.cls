% 自定义文档类：noteformyself
% by Tianle Yang
% !TeX program = xelatex
% !Bib program = biber
% !TEX encoding = UTF-8 Unicode
\ProvidesClass{noteformyself}[2026/05/20, v 1.1.6, for notes to myself]


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
\RequirePackage{thmtools}                             % 高级定理工具包（提供declaretheorem）
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
% 设置数学字体
\setmathfont{STIX Two Math} %
\IfFontExistsTF{Cambria Math}{
  \setmathfont{Cambria Math}[range={\mathalpha}] % Cambria Math is only available on Windows.
}{
  \setmathfont{Latin Modern Math}[range={\mathalpha}] % fallback for non-Windows systems
}
\setmathfont{Libertinus Math}[range=bb] % 
\setmathfont{STIX Two Math}[range=cal] % like cal, support lowercase
\setmathfont{Libertinus Math}[range=scr] % like scr, support lowercase
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

% 定义定理样式模板
\newtheoremstyle{mystyle}{}{}{}{}{\bfseries}{.}{ }{}
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
% Use \declaretheorem instead of \newtheorem for better cleveref support
\declaretheorem[sibling=definition,name=Proposition]{proposition}
\declaretheorem[sibling=definition,name=Theorem]{theorem}
\declaretheorem[sibling=definition,name=Lemma]{lemma}
\declaretheorem[sibling=definition,name=Corollary]{corollary}
\declaretheorem[sibling=definition,name=Conjecture]{conjecture}
\declaretheorem[sibling=definition,name=Question]{question}
\declaretheorem[sibling=definition,name=Remark]{remark}
\declaretheorem[sibling=definition,name=Claim]{claim}
\declaretheorem[sibling=definition,name=Example]{example}
\declaretheorem[sibling=definition,name=Exercise]{exercise}
\declaretheorem[sibling=definition,name=Construction]{construction}
\declaretheorem[sibling=definition,name=Notation]{notation}
\declaretheorem[numbered=yes, name=Theorem]{mainthm} % main theorem with global numbering
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
\declaretheorem[name=Slogan,numbered=no]{slogan}
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