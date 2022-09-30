\def\fileversion{a01}%
\def\filedate{2022-09-30}%

\NeedsTeXFormat{LaTeX2e}[2018/12/01]
\ProvidesClass{cocotex}
    [\filedate \fileversion CoCoTeX Wrapper for transpect.cls]
\RequirePackage{kvoptions-patch}
\RequirePackage{xkeyval}
\DeclareOptionX*{\PassOptionsToClass{\CurrentOption}{transpect}}
\ProcessOptionsX
\LoadClass{transpect}

