%%
%% This is file `transpect.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% transpect.dtx  (with options: `class')
%% 
%% IMPORTANT NOTICE:
%% 
%% For the copyright see the source file.
%% 
%% Any modified versions of this file must be renamed
%% with new filenames distinct from transpect.cls.
%% 
%% For distribution of the original source see the terms
%% for copying and modification in the file transpect.dtx.
%% 
%% This generated file may be distributed as long as the
%% original source files, as listed above, are part of the
%% same distribution. (The sources need not necessarily be
%% in the same archive or directory.)
\def\fileversion{0.1.8}%
\def\filedate{2021-05-18}%
%%
%% Common document class for le-tex Transpect projects.
%%
%% Maintainer: p.schulz@le-tex.de
%%
%% lualatex  -  texlive > 2019
%%
\NeedsTeXFormat{LaTeX2e}[2018/12/01]
\ProvidesClass{transpect}
    [\filedate \fileversion le-tex transpect]
\RequirePackage{kvoptions-patch}
\RequirePackage{xkeyval}
\PassOptionsToPackage{cmyk}{xcolor}
\RequirePackage{transpect-common}
\DeclareOptionX{main}{\PassOptionsToPackage{\CurrentOption}{babel}}
\DeclareOption{es-noindentfirst}{\PassOptionsToPackage{es-noindentfirst}{babel}}
\PassOptionsToPackage{shorthands=off}{babel}
\DeclareOptionX{ennotoc}{\PassOptionsToPackage{\CurrentOption}{transpect-endnotes}}
\DeclareOptionX{endnotes}{\PassOptionsToPackage{\CurrentOption}{transpect-endnotes}}
\DeclareOptionX{resetnotesperchapter}{\PassOptionsToPackage{\CurrentOption}{transpect-endnotes}}
\DeclareOptionX{endnotesperchapter}{\PassOptionsToPackage{\CurrentOption}{transpect-endnotes}}
\newif\ifcollection \collectionfalse
\newif\ifarticle   \articlefalse
\define@choicekey{transpect.cls}{pubtype}[\tp@pubtype\nr]{collection,article,mono}{%
  \ifcase\nr\relax% collection
    \global\collectiontrue
  \or%
    \global\articletrue
  \else% mono
  \fi
}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{article}}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{book}}
\DeclareOptionX{usescript}{\PassOptionsToPackage{\CurrentOption}{transpect-script}}
\DeclareOptionX{nofigs}{\PassOptionsToPackage{\CurrentOption}{transpect-floats}}
\ProcessOptionsX
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
\RequirePackage{transpect-script}
\else
\RequirePackage{babel}
\fi
\PassOptionsToPackage{breaklinks,linktoc=none,pdfborder={0 0 0},pdfencoding=auto,bookmarksnumbered=true}{hyperref}
\RequirePackage{transpect-headings}
\RequirePackage{transpect-floats}
\RequirePackage{transpect-title}
\RequirePackage{transpect-endnotes}
\RequirePackage{index}
\makeindex
\RequirePackage{hyperref}
\endinput
%%
%% End of file `transpect.cls'.
