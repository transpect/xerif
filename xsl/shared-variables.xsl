<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:hub="http://transpect.io/hub"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  xmlns:idml2xml="http://transpect.io/idml2xml"
  xmlns:schematron="http://purl.oclc.org/dsdl/schematron"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  exclude-result-prefixes="xs tei"
  version="2.0">
  
  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+" 
                select="('^(berschrift1|[Hh]eading\s?1|[a-z]{1,3}headingpart)|[a-z]{1,3}(front|back)matter1$',
                         concat('^(berschrift2|[Hh]eading\s?2|[a-z]{1,3}heading1|[a-z]{1,3}(front|back)matter2|[a-z]{1,3}(journalreviewheading|heading1review)|[a-z]{1,3}headingenumerated1|toctitle',
                                '|', replace($appendix-heading-role-regex, '^\^', ''),
                                '|', concat(replace($index-heading-regex, '^\^', ''), '(\p{L}+)?'(:allow different index types declared in heading:)),
                                '|', replace($list-of-figures-regex, '^\^(.+)\$$', '$1'),
                                '|', replace($list-of-tables-regex, '^\^(.+)\$$', '$1'),
                                '|', replace($acknowledgements-role-regex, '^\^(.+)\$$', '$1'),
                                ')(', $suffixes-regex, ')?$'
                                ),
                         concat('^(berschrift3|[Hh]eading\s?3|[a-z]{1,3}heading2|[a-z]{1,3}headingenumerated2|[a-z]{1,3}(front|back)matter3)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift4|[Hh]eading\s?4|[a-z]{1,3}heading3|[a-z]{1,3}headingenumerated3|[a-z]{1,3}(front|back)matter4)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift5|[Hh]eading\s?5|[a-z]{1,3}heading4|[a-z]{1,3}headingenumerated4|[a-z]{1,3}(front|back)matter5)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift6|[Hh]eading\s?6|[a-z]{1,3}heading5|[a-z]{1,3}headingenumerated5|[a-z]{1,3}(front|back)matter6)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift7|[Hh]eading\s?7|[a-z]{1,3}heading6|[a-z]{1,3}headingenumerated6|[a-z]{1,3}(front|back)matter7)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift8|[Hh]eading\s?8|[a-z]{1,3}heading7|[a-z]{1,3}headingenumerated7|[a-z]{1,3}(front|back)matter8)(', $suffixes-regex, ')?$'),
                         concat('^(berschrift9|[Hh]eading\s?9|[a-z]{1,3}heading8|[a-z]{1,3}headingenumerated8|[a-z]{1,3}(front|back)matter9)(', $suffixes-regex, ')?$')
                         )"/>
  
  <xsl:variable name="hub:toc-heading" as="xs:string" 
                select="'^toctitle$'"/>

  <xsl:variable name="hub:blockquote-role-regex" as="xs:string" 
    select="'^[a-z]{1,3}_?(motto|dedication|epigraph|dialogue|quotation|verse|transcription|codeblock[a-z0-9]+)(_-_.+)?$'"/>
  
  <xsl:variable name="hub:blockquote-source-role-regex" as="xs:string" 
                select="'^[a-z]{1,3}_?(motto|dedication|epigraph|dialogue|quotation|verse)-?source$'"/>
  
  <xsl:variable name="hub:list-by-indent-exception-role-regex" as="xs:string" 
                select="'^[a-z]{1,3}_?(literature|body|dedication|motto|dialogue|quotation|figurecaption|figuresource|tablecaption|tablesource|formula|indexstatic|indexlist|codeblock[a-z0-9]+)'"/>  

  <xsl:variable name="tei:floatingTexts-role" as="xs:string" select="'^[a-z]{1,3}_?box(grey|border)$|^transcription$'"/>
  
  <xsl:variable name="hub:transcription-role-regex-x" as="xs:string" 
                select="'^[a-z]{1,3}_?transcription(_-_.+|$)'"/>
  
  <xsl:variable name="hub:figure-title-role-regex-x" as="xs:string"
                select="'^([a-z]{1,3}figurecaption)$'"/>
  
  <xsl:variable name="hub:table-title-role-regex-x" as="xs:string" 
                select="'^[a-z]{1,3}tablecaption$'"/>
  
  <xsl:variable name="hub:table-note-style-regex-x" as="xs:string" 
                select="'^[a-z]{1,3}tablelegend$'"/>
  
  <xsl:variable name="hub:table-copyright-style-regex-x" as="xs:string" 
                select="'^[a-z]{1,3}tablesource$'"/>
  
  <xsl:variable name="hub:figure-caption-start-regex" as="xs:string" 
                select="'[^\p{Zs}]+'"/>
  
  <xsl:variable name="hub:caption-sep-regex" as="xs:string" 
                select="'[&#x20;&#x2002;&#xa0;&#x202F; \p{Zs}]+'"/>
  
  <xsl:variable name="hub:dissolve-empty-phrase-att-name" as="xs:string+" select="('srcpath', 'css:letter-spacing')"/>
  
  <xsl:variable name="pi-style-regex" as="xs:string" 
                select="'^[a-z]{1,3}pi$'"/>
  
  <xsl:variable name="pi-mark" as="xs:string" 
                select="'~'"/>
  
  <xsl:variable name="pi-xml-name" as="xs:string" 
                select="'latex'"/>
  
  <xsl:variable name="float-options" as="xs:string+" 
                select="'float', 'top', 'bottom', 'fixed'"/>
  
  <xsl:variable name="float-options-regex" as="xs:string" 
                select="concat('(', string-join($float-options, '|'), ')')"/>
  
  <xsl:variable name="orientation-options" as="xs:string+" 
                select="'landscape'"/>
  
  <xsl:variable name="suffixes-regex" as="xs:string" 
                select="concat($no-toc-suffix, '|', $no-pdf-bookmarks-suffix)"/>
  
  <xsl:variable name="no-toc-suffix" as="xs:string" 
                select="'notoc'"/><!-- do not include in toc -->
  
  <xsl:variable name="no-pdf-bookmarks-suffix" as="xs:string" 
                select="'nobm'"/>
  
  <xsl:variable name="list-of-figures-regex" as="xs:string"
                select="'^[a-z]{1,3}listoffigures$'"/>
  
  <xsl:variable name="list-of-tables-regex" as="xs:string"
                select="'^[a-z]{1,3}listoftables$'"/>
  
  <xsl:variable name="part-heading-role-regex" as="xs:string" 
                select=" '^[a-z]{1,3}headingpart$'"/>
  
  <xsl:variable name="appendix-heading-role-regex" as="xs:string" 
                select=" '^[a-z]{1,3}appendix$'"/>
  
  <xsl:variable name="frontmatter-heading-role-regex" as="xs:string"
                select="'^[a-z]{1,3}frontmatter\d$'"/>
  
  <xsl:variable name="backmatter-heading-role-regex" as="xs:string"
                select="'^[a-z]{1,3}backmatter\d$'"/>
  
  <xsl:variable name="dedication-role-regex" as="xs:string"
                select="'^[a-z]{1,3}dedication$'"/>
  
  <xsl:variable name="acknowledgements-role-regex" as="xs:string"
                select="'^[a-z]{1,3}acknowledgements$'"/>
  
  <xsl:variable name="literallayout-role-regex" as="xs:string" 
                select="'^[a-z]{1,3}transliteration$'"/>
  
  <xsl:variable name="codelisting-role-regex" as="xs:string"
                select="'^[a-z]{1,3}codeblock[a-z0-9]+$'"/>
  
  <xsl:variable name="dialogue-role-regex" as="xs:string"
                select="'^[a-z]{1,3}dialogue(-action)?$'"/>
  
  <xsl:variable name="dialogue-action-role-regex" as="xs:string"
                select="'^[a-z]+dialogue-action$'"/>
  
  <xsl:variable name="dialogue-speaker-delimiter-regex" as="xs:string" 
                select="':'"/>
  
  <xsl:variable name="poem-role-regex" as="xs:string"
                select="'^[a-z]{1,3}(verse|poem).*$'"/>
  
  <xsl:variable name="verse-style" as="xs:string"
                select="'^[a-z]+_?verse(-?source)?$'"/>
  
  <xsl:variable name="verse-heading-style" as="xs:string"
                select="'^[a-z]+_?verse-heading$'"/>
  
  <xsl:variable name="verse-centered-style" as="xs:string"
                select="'^[a-z]+_?verse_\-_centered$'"/>

  <xsl:variable name="verse-misc-style" as="xs:string"
                select="'^[a-z]+_?verse.*$'" />
  
  <xsl:variable name="letter-para-style" as="xs:string" 
                select="'[a-z]{1,3}_letter$'"/>
  
  <xsl:variable name="no-hyphen-style" as="xs:string"
                select="'^[a-z]{1,3}nohyphen$'"/>
  
  <xsl:variable name="letter-spacing-para-style" as="xs:string" 
                select="'[a-z]{1,3}_letter_spacing$'"/>
  
  <!-- role for para that contains image or file reference, first 
       regex group identifies class, second group represents position -->
  <xsl:variable name="figure-image-role-regex" as="xs:string"
                select="'^[a-z]{1,3}figure([a-z])?(\d+)?$'" />
  
  <xsl:variable name="fig-legend-para-style-regex" as="xs:string" 
                select="'^[a-z]{1,3}figurelegend$'"/>
  
  <xsl:variable name="figure-alt-role-regex" as="xs:string"
                select="'^[a-z]{1,3}figurealt$'" />
  
  <xsl:variable name="figure-caption-role-regex" as="xs:string"
                select="'^[a-z]{1,3}figurecaption$'" />
  
  <xsl:variable name="figure-source-role-regex" as="xs:string"
                select="'^[a-z]{1,3}figuresource$'"/>
  
  <xsl:variable name="figure-link-role-regex" as="xs:string"
                select="'^[a-z]{1,3}figurelink$'"/>
  
  <xsl:variable name="figure-group-suffix-regex" as="xs:string"
                select="'\d+$'"/>
  
  <xsl:variable name="table-caption-role-regex" as="xs:string"
                select="'^[a-z]{1,3}tablecaption$'" />
  
  <xsl:variable name="table-source-role-regex" as="xs:string"
                select="'^[a-z]{1,3}tablesource$'"/>
  
  <xsl:variable name="tab-legend-para-style-regex" as="xs:string" 
                select="'^[a-z]{1,3}tablelegend$'"/>
  
  <xsl:variable name="box-start-regex" as="xs:string" 
                select="'^[a-z]{1,3}box[a-z]+start$'"/>
  
  <xsl:variable name="box-end-regex" as="xs:string" 
                select="'^[a-z]{1,3}box[a-z]+end$'"/>
  
   <xsl:variable name="box-heading-style" as="xs:string"
                select="'^[a-z]{1,3}boxheading'"/>
  
  <xsl:variable name="author-desc-style" as="xs:string"
                select="'^[a-z]{1,3}authordescription'" />
  
  <!-- chapter/section metadata -->
  
  <xsl:variable name="hub:preserve-abstract-as-text" as="xs:boolean" select="false()">
    <!-- if set to true() abstract, keywords and alternatve-title section are preserved additionally to meta tags in info-->
  </xsl:variable>

  <xsl:variable name="running-header-regex" as="xs:string" 
                select="'^[a-z]{1,3}(headingshort|headline(right|left|author|short)?)$'"/>
  
  <xsl:variable name="toc-header-regex" as="xs:string" 
                select="'^[a-z]{1,3}headlinetoc$'"/>

  <xsl:variable name="info-meta-styles" as="xs:string"
                select="concat('(',
                          string-join(
                            ($hub:keywords-role-regex,
                             $info-author-role,
                             $info-author-bio-role,
                             $info-author-email-role,
                             $info-author-affiliation-role,
                             $info-doi,
                             $info-orcid-style,
                             $info-copyright-holder-role,
                             $info-copyright-year-role,
                             $info-licence-style,
                             $info-year
                            ), 
                          ')|('
                          ), ')'
                        )" >
    <!-- all meta style names that go into a bibloset, if they do not all begin with meta in your a9s, 
      concat the important ones (info-licence-style, info-doi, etc.)-->
  </xsl:variable>
  
  <xsl:variable name="info-author-role" as="xs:string"
                select="'^[a-z]{1,3}(author)(notoc)?$'"/>
  
  <xsl:variable name="info-author-bio-role" as="xs:string"
                select="'^[a-z]{1,3}author-bio'" />

  <xsl:variable name="info-copyright-holder-role" as="xs:string"
                select="'^[a-z]{1,3}copyright-holder'" />
  
  <xsl:variable name="info-copyright-year-role" as="xs:string"
                select="'^[a-z]{1,3}copyright-year'" />

  <xsl:variable name="info-licence-style" as="xs:string"
                select="'^[a-z]{2,3}metacontributionlicence'" />

  <xsl:variable name="info-doi" as="xs:string"
                select="'[a-z]{1,3}metadoi$'" />

  <xsl:variable name="info-orcid-style" as="xs:string"
                select="'^[a-z]{2,3}metacontributionorcid'" />
  
  <xsl:variable name="info-author-email-role" as="xs:string"
                select="'^[a-z]{1,3}author-email'" />

  <xsl:variable name="info-year" as="xs:string"
                select="'^[a-z]{1,3}metacontributionyear'" />
  
  <xsl:variable name="info-author-affiliation-role" as="xs:string"
                select="'^[a-z]{1,3}author-affiliation'"/> 
  
  <xsl:variable name="info-subtitle-role" as="xs:string"
                select="'^[a-z]{1,3}(subheading\d|journalreviewsubheading)$'"/>
  
  <!-- motto-style and info-blockquote-roles as well 
       as motto-source-style and info-blockquote-source-roles 
       share the same semantic. Perhaps we should stick to 
       'info-blockquote' or 'epigraph' as 'motto' is German. 
       Perhaps we need two different environemnts for headings? -->
  <xsl:variable name="motto-style" as="xs:string" 
                select="'^[a-z]{1,3}motto$'"/>
  
  <xsl:variable name="motto-source-style" as="xs:string"
                select="'^[a-z]{1,3}mottosource$'"/>
  
  <xsl:variable name="info-blockquote-roles" as="xs:string"
                select="'^[a-z]{1,3}(motto-zitat|motto|epigraph)$'"/>
  
  <xsl:variable name="info-blockquote-source-roles" as="xs:string"
                select="'^[a-z]{1,3}(motto-zitat|mottosource|epigraphsource)$'"/>
  
  <xsl:variable name="variable-list-role-regex" as="xs:string" 
                select="'^[a-z]{1,3}abbreviations$'"/>
  
  <xsl:variable name="create-index-at-general-headings" 
                select="true()"/>
  
  <xsl:variable name="index-text-regex" as="xs:string" 
                select="'^[a-z]{1,3}index\s?text'"/>
  
  <xsl:variable name="index-heading-regex" as="xs:string" 
                select="'^[a-z]{1,3}index\s?heading'"/>
  
  <xsl:variable name="index-mark-regex" as="xs:string" 
                select="'^[a-z]{1,3}indexmark'"/> 
  
  <xsl:variable name="index-name-regex" as="xs:string" 
                select="'^[a-z]{1,3}indexname'"/>
  
  <xsl:variable name="index-list-regex" as="xs:string" 
                select="'^[a-z]{1,3}indexlist'"/>
  
  <xsl:variable name="index-static-regex" as="xs:string" 
                select="'^[a-z]{1,3}indexstatic1?'"/>
  
  <xsl:variable name="index-static-level" as="xs:string+" 
                select="'1', '2', '3', '4'"/>
  
  <xsl:variable name="index-static-level-regex" as="xs:string" 
                select="concat('(', string-join($index-static-level, '|'), ')?')"/>
  
  <!-- please do not remove the tailing and leading regex group -->
  <xsl:variable name="index-see-regex" as="xs:string" 
                select="'(see|siehe)'"/>
  <xsl:variable name="index-see-also-regex" as="xs:string" 
                select="concat($index-see-regex, '(\p{Zs}(also|auch))')"/>
  
  <xsl:variable name="index-see-pi-name" as="xs:string" 
                select="'see'"/>
  <xsl:variable name="index-see-also-pi-name" as="xs:string" 
                select="'seealso'"/>
  
  <xsl:variable name="bibliography-role-regex" as="xs:string" 
                select="'^[a-z]{1,3}literature$'"/>
  
  <xsl:variable name="index-type-default-name" select="'default'" as="xs:string"/>

  <xsl:variable name="table-header-style-regex" select="'^[a-z]{1,3}tableheader$'" as="xs:string"/>
  
  <xsl:variable name="endnotes-heading-style" select="'^[a-z]{1,3}listofendnotes$'" as="xs:string"/>

  <xsl:variable name="hub:headword-role-regex" as="xs:string" select="'^[a-z]{1,3}(meta)?headword'"/>
  <xsl:variable name="hub:keywords-role-regex" as="xs:string" select="'^[a-z]{1,3}(meta)?keywords'"/>
  <xsl:variable name="hub:abstract-role-regex" as="xs:string" select="'^[a-z]{1,3}(meta)?abstract'"/>
  <xsl:variable name="hub:trans-title-role-regex" as="xs:string" select="'^[a-z]{1,3}(meta)?transtitle'"/>
  <xsl:variable name="hub:keyword-abstract-transtitle-combined" as="xs:string" 
                select="concat($hub:abstract-role-regex, '|', $hub:keywords-role-regex, '|', $hub:trans-title-role-regex)"/>

  <xsl:variable name="empty-line-style" select="'^[a-z]{1,3}(lineskip(\d)?|codeblock[a-z0-9]+)$'" as="xs:string"/>

  <!-- the following variables are mainly for the idml conversion and checking pipelines -->

  <xsl:key name="tr:rule-definition-in-document" match="css:rule" use="@name"/>
  <xsl:template name="tr:role-for-schematron" as="xs:string*">
    <xsl:param name="role"/>
    <xsl:value-of select="replace(replace(key('tr:rule-definition-in-document', current()/$role)[1]/@native-name, '(_-_|[~&#x2dc;]).+$', ''), ':', '/')"/>
  </xsl:template>


  <xsl:function name="schematron:general-documentation" as="element(*)*">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="link-target" as="xs:string?"/>
  </xsl:function>
  
  <xsl:function name="schematron:style-documentation" as="element(*)">
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="link-target" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$lang eq 'de'">
        <span class="documentation" xmlns="http://www.w3.org/1999/xhtml">→ Für Details zu den erlaubten Formatvorlagennamen, schauen Sie bitte in der <a href="https://redmine.le-tex.de/projects/transpect-typesetter/wiki/Formatvorlagen" xmlns="http://www.w3.org/1999/xhtml">Liste der erlaubtern Formatvorlagen</a> 
          nach.</span>
      </xsl:when>
      <xsl:otherwise>
        <span class="documentation" xmlns="http://www.w3.org/1999/xhtml">→ For further information please read the <a href="https://redmine.le-tex.de/projects/transpect-typesetter/wiki/Formatvorlagen" xmlns="http://www.w3.org/1999/xhtml">style documentation</a>.</span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:variable name="idml2xml:discard-para-regex" as="xs:string" select="'tsheadline'"/>

  <xsl:variable name="hub:discard-para-regex" select="'tsheadline'" as="xs:string"/>
 
  <xsl:variable name="hub:table-rotated-role-regex" as="xs:string" select="'^[a-z]{1,3}tablerotated$'"/>
  
  <xsl:variable name="hub:table-caption-start-regex" as="xs:string"
                select="'Tab\.|Tabellen?|Table|[tT]ables?'"/>
 
  <xsl:variable name="hub:figure-number-role-regex-x" as="xs:string" select="'Abbildung_BU_Num'"/>
  <xsl:variable name="hub:figure-note-role-regex" as="xs:string" select="'Abbildung_BU_Note'"/>
  <xsl:variable name="hub:figure-copyright-statement-role-regex"  as="xs:string" select="'tsfiguresource'" />
  

  <xsl:variable name="hub:subtitle-role-regex" as="xs:string" select="'tssubheading[1-5]'" /> 
  <xsl:variable name="hub:tabs-are-allowed-in-this-para" select="'tslist|tsheading|tsfigurecaption|tstablecaption|tsfootnote'" as="xs:string"/>
  <xsl:variable name="hub:list-role-regex" as="xs:string" select="'tslist$'" >
    <!-- for schematron purposes mainly, but also to determine that ohub:tabs-are-allowed-in-this-paranly these paras are handled by list handler via function  -->
  </xsl:variable>
  <xsl:variable name="hub:table-para-style-role-regex" as="xs:string" select="'tstabletext'">
    <!-- For schematron checking purposes, style for normal table content paras -->
  </xsl:variable>
  <xsl:variable name="hub:container-styles" as="xs:string" select="'(tstable|tsfigure)$'"/>

  <xsl:variable name="hub:regex-for-url-to-link-recognition" as="xs:string" 
                select="concat('(https?://|www\.)[-a-z0-9\.:;#~*%_/\?=&amp;@&#x200b;-&#x200d;',
                               $xml2tex:tactical-break-character-for-urls,
                               ']+[-a-z0-9:;#~\*%_/=&amp;&#x200b;-&#x200d;',
                               $xml2tex:tactical-break-character-for-urls,
                               ']')"/>

  <xsl:variable name="tei:box-type-role" select="'box'" as="xs:string"/>

  <xsl:variable name="tei2html:no-toc-style-regex" as="xs:string" select="'notoc'"/>

  <!-- &#x200b; or &#x21a9; add chars after possible break points. only char on real break is displayed . -->
  <xsl:variable name="xml2tex:tactical-break-character-for-urls" as="xs:string?" select="'&#x21a9;'"/>
  
  <!-- character limit of url parts until tactical line breaks are inserted -->
  <xsl:variable name="xml2tex:url-part-character-limit" as="xs:integer" select="40"/>
  
  <!-- if you want to override the variables below in your client-specific cascade,
       please keep in mind that you must also add the configuration (xml2tex/helpers.xsl) 
       to your cascade and import your client-specific shared variables there. -->
  
  <!-- processing instruction that provokes a table split -->
  <xsl:variable name="xml2tex:split-table-pi" as="xs:string" select="'\doTableBreak'"/>
  
  <!-- As long as tables with PI orientation=landscape cannot be split automatically via 
       the framework, they may be split via converter. how the splitting is done exactly, 
       should in most cases be adapted in customer code to make sure that the position 
       of titles, sources etc. is according to styles -->
  <xsl:variable name="xml2tex:split-landscape-tables" select="false()" as="xs:boolean"/>
  
  <!-- Whether the title should be repeated in subsequent table parts -->
  <xsl:variable name="xml2tex:repeat-split-table-title" select="false()" as="xs:boolean"/>
  
  <!-- Should the table head be repeated in subsequent table parts -->
  <xsl:variable name="xml2tex:repeat-split-table-head" select="false()" as="xs:boolean"/>
  
  <!-- Should the table caption always shown -->
  <xsl:variable name="xml2tex:repeat-split-table-caption" select="false()" as="xs:boolean"/>
  
  <!-- always render table copyright -->
  <xsl:variable name="xml2tex:repeat-split-table-info" select="false()" as="xs:boolean"/>
  
  <!-- handle table caption position. 'top' or 'bottom'-->
  <xsl:variable name="xml2tex:table-caption-pos" as="xs:string?" select="'top'"/>
  
  <!-- add babel languages here that require their own font in customer styles -->
  <xsl:variable name="xml2tex:lang-for-additional-fonts" select="'amharic'" as="xs:string*"/>
  
  <!-- add pagecounter if not title pages are included. -->
  <xsl:variable name="xml2tex:set-pagecounter-without-titlepage" select="'\setcounter{page}{5}&#xa;'"/>
  
</xsl:stylesheet>