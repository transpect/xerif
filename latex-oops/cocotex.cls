%%
%% This is file `cocotex.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% cocotex.dtx  (with options: `class')
%% 
%% IMPORTANT NOTICE:
%% 
%% For the copyright see the source file.
%% 
%% Any modified versions of this file must be renamed
%% with new filenames distinct from cocotex.cls.
%% 
%% For distribution of the original source see the terms
%% for copying and modification in the file cocotex.dtx.
%% 
%% This generated file may be distributed as long as the
%% original source files, as listed above, are part of the
%% same distribution. (The sources need not necessarily be
%% in the same archive or directory.)
%%
%% Common document class for \textit{xerif} projects.
%%
%% Maintainer: p.schulz@le-tex.de
%%
%% lualatex  -  texlive > 2019
%%
\NeedsTeXFormat{LaTeX2e}[2018/12/01]
\ProvidesClass{cocotex}
    [2024/01/29 0.4.0 cocotex]
\RequirePackage{kvoptions-patch}
\RequirePackage{xkeyval}
\DeclareOptionX{main}{\PassOptionsToPackage{\CurrentOption}{babel}}
\DeclareOption{es-noindentfirst}{\PassOptionsToPackage{es-noindentfirst}{babel}}
\DeclareOption{es-noshorthands}{\PassOptionsToPackage{es-noshorthands}{babel}}
\PassOptionsToPackage{shorthands=off}{babel}
\newif\ifcollection \collectionfalse
\newif\ifarticle    \articlefalse
\newif\ifmonograph  \monographfalse
\newif\ifjournal    \journalfalse
\define@choicekey{cocotex.cls}{pubtype}[\tp@pubtype\nr]{collection,article,journal,mono}{%
  \ifcase\nr\relax% collection
    \global\collectiontrue
  \or% article
    \global\articletrue
  \or% journal
    \global\journaltrue
  \else% monograph
    \global\monographtrue
  \fi
}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{article}}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{book}}
\DeclareOptionX{debug}{\PassOptionsToPackage{\CurrentOption}{coco-kernel}}
\DeclareOptionX{a11y}{\PassOptionsToPackage{\CurrentOption}{coco-common}}
\DeclareOptionX{no-compress}{\let\tp@no@pdf@compression\relax}
\DeclareOptionX{color-enc}{\PassOptionsToPackage{\CurrentOption}{coco-common}}
\DeclareOptionX{usescript}{\PassOptionsToPackage{\CurrentOption}{coco-script}}
\DeclareOptionX{nofigs}{\PassOptionsToPackage{\CurrentOption}{coco-floats}}
\DeclareOptionX{ennotoc}{\PassOptionsToPackage{\CurrentOption}{coco-notes}}
\DeclareOptionX{endnotes}{\PassOptionsToPackage{\CurrentOption}{coco-notes}}
\DeclareOptionX{resetnotesperchapter}{\PassOptionsToPackage{\CurrentOption}{coco-notes}}
\DeclareOptionX{endnotesperchapter}{\PassOptionsToPackage{\CurrentOption}{coco-notes}}
\ProcessOptionsX
\ifx\tp@no@pdf@compression\relax
  \AtBeginDocument{%
    \ifx\pdfobjcompresslevel\@undefined
      \edef\pdfobjcompresslevel{\pdfvariable objcompresslevel}%
    \fi
    \pdfcompresslevel=0
    \pdfobjcompresslevel=0
  }%
\fi
\RequirePackage{coco-common}
\ifarticle
  \LoadClass[10pt,a4paper]{article}
\else
  \LoadClass[10pt,a4paper]{book}
\fi
\voffset-1in\relax
\hoffset-1in\relax
\emergencystretch=2em
\frenchspacing
\clubpenalty10000
\widowpenalty10000
\def\ps@empty{%
  \let\@oddhead\@empty
  \let\@evenhead\@empty
  \let\@oddfoot\@empty
  \let\@evenfoot\@empty
}
\def\cleardoublepage{\clearpage\if@twoside \ifodd\c@page\else
    \hbox{}\thispagestyle{empty}\newpage\if@twocolumn\hbox{}\newpage\fi\fi\fi}
\ifarticle\else
  \newif\if@frontmatter  \@frontmatterfalse
  \renewcommand\frontmatter{%
    \cleardoublepage
    \@mainmatterfalse
    \@frontmattertrue
    \pagenumbering{arabic}}
  \renewcommand\mainmatter{%
    \cleardoublepage
    \@frontmatterfalse
    \@mainmattertrue}
  \renewcommand\backmatter{%
    \cleardoublepage
    \@mainmatterfalse
    \@frontmatterfalse}
\fi
\usepackage{soul}
\ifLuaTeX
\RequirePackage{coco-script}
\else
\RequirePackage{babel}
\fi
\RequirePackage{coco-headings}
\RequirePackage{coco-floats}
\RequirePackage{coco-title}
\RequirePackage{coco-notes}
\RequirePackage{index}
\makeindex
\RequirePackage{hyperref}
  \hypersetup{%
    breaklinks%
   ,linktoc=none%
   ,pdfborder={0 0 0}%
   ,pdfencoding=auto%
   ,bookmarksnumbered=true%
}
\ifx\tp@do@ally\relax
  \RequirePackage{coco-accessibility}
\fi
\endinput
%%
%% End of file `cocotex.cls'.
