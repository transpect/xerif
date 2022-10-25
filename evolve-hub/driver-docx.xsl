<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk" 
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  <xsl:import href="../xsl/shared-variables.xsl"/>
  
  <xsl:param name="s9y1-path"/>
  <xsl:param name="s9y2-path"/>
  <xsl:param name="s9y3-path"/>
  <xsl:param name="s9y4-path"/>
  <xsl:param name="s9y5-path"/>
  
  <xsl:variable name="doc" select="/*" as="element(hub)"/>
  <xsl:variable name="doc-lang" select="$doc/@xml:lang" as="attribute(xml:lang)?"/>
  
  <xsl:variable name="nbsp-regex" select="'(AD|BC|S\.|Bd\.|Abs\.|Jg\.|H\.|Vgl\.|ebd\.,?)\s(\d+[\.,;]?)'" as="xs:string"/>
  <xsl:variable name="abbrev-regex" select="'([a-z]\.)\s([a-z]\.)'" as="xs:string"/>
  <xsl:variable name="abbrev-without-space" select="'(d\.h\.)|(z\.B\.)|(u\.a\.)'" as="xs:string"/>
  <xsl:variable name="hub:figure-copyright-statement-role-regex"  as="xs:string" select="'ts_dummy_source'">
    <!-- normally creates a legalnotice. but doesn't work here so dummy style. is needed though for schematron checks, do not delete -->
  </xsl:variable>

  <!--  *
        * create hierarchy
        * -->
  
  
  <!-- https://redmine.le-tex.de/issues/12115 
       fix issue where list of tables was wrapped inside the section of list of figures -->
  
  <xsl:variable name="part-heading-role-regex" select=" '^[a-z]{1,3}headingpart$'"/>
  
  <xsl:template match="hub/section[matches(@role, $part-heading-role-regex)]" mode="hub:postprocess-hierarchy">
    <part>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </part>
  </xsl:template>
  
  <xsl:template match="hub/section[matches(@role, '^[a-z]{1,3}(heading(enumerated)?1|journalreviewheading)$')]
                      |hub/section[matches(@role,$part-heading-role-regex)]/section[matches(@role, '^[a-z]{1,3}heading(enumerated)?1$')]
                      |hub/section[not(matches(@role, $part-heading-role-regex))]" 
                mode="hub:postprocess-hierarchy">
    <chapter>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </chapter>
  </xsl:template>
  
  <xsl:template match="informaltable//chapter
                      |informaltable//section
                      |table//chapter
                      |table//section" mode="hub:clean-hub">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="informaltable//chapter/title
                      |informaltable//section/title
                      |table//chapter/title
                      |table//section/title" mode="hub:clean-hub">
    <para role="resolved-title">
      <xsl:apply-templates mode="#current"/>  
    </para>
  </xsl:template>
  
    
  <xsl:template match="*[not(self::blockquote)][para[matches(@role, $hub:blockquote-role-regex)]]" 
                name="build-blockquotes" 
                mode="hub:blockquotes" xmlns="http://docbook.org/ns/docbook">
    <xsl:param name="wrapper-element-name" select="name()" as="xs:string" tunnel="no"/>
    <xsl:element name="{$wrapper-element-name}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-adjacent="exists(self::para[matches(@role, $hub:blockquote-role-regex)])">
        <!-- all blockquote paras -->
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:for-each-group select="current-group()" group-starting-with="self::para[not(substring(@role, 1, 7) = substring(preceding-sibling::*[1][self::para]/@role, 1, 7))]">
              <!-- splitted in different blockquote-types: '^([a-z]{1,3}motto|[a-z]{1,3}dialogue|[a-z]{1,3}quotation)$' -->
              <xsl:element name="blockquote">
                <xsl:apply-templates select="current-group()[1]/@role" mode="#current"/>
                <xsl:if test="current-group()[1]/preceding-sibling::node()[1]/self::para[matches(@role, $hub:blockquote-heading-role-regex)]">
                  <title>
                    <xsl:apply-templates select="current-group()[1]/preceding-sibling::node()[1]/node()" mode="#current"/>
                  </title>
                </xsl:if>
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </xsl:element>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="blockquote[@role eq 'hub:lists']" mode="hub:blockquotes">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="chapter | part" mode="custom-1">
    <xsl:param name="remove-wrapper" as="xs:boolean" select="false()"/>
    <xsl:variable name="chapter-info" as="element()*" 
                  select="((author, 
                           para[matches(@role, $info-author-role)]
                            )[1],
                           para[matches(@role, $info-subtitle-role)],
                           title,
                           abbrev,
                           epigraph,
                           biblioset,
                           abstract,
                           keywordset) (: must be placed below title :)"/>
    <xsl:choose>
      <xsl:when test="$remove-wrapper">
        <xsl:if test="$chapter-info">
          <info>
            <xsl:apply-templates select="$chapter-info" mode="#current"/>
          </info>
        </xsl:if>
        <xsl:apply-templates select="node() except $chapter-info" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:variable name="first-lang" as="xs:string?" select="(descendant::*[@xml:lang])[1]/@xml:lang"/>
          <xsl:variable name="sec-is-completeley-in-other-lang" select="hub:sec-is-completeley-in-other-lang(., $first-lang)" as="xs:boolean"/>
          <xsl:if test="$sec-is-completeley-in-other-lang"><xsl:attribute name="xml:lang" select="$first-lang"/></xsl:if>
          <xsl:sequence select="hub:renderas-from-role-suffix(@renderas, title/@role)"/>
          <xsl:if test="$chapter-info">
            <info>
              <xsl:apply-templates select="$chapter-info" mode="#current">
                <xsl:with-param name="discard-child-lang" as="xs:boolean" select="if ($sec-is-completeley-in-other-lang) then true() else false()" tunnel="yes"/>
              </xsl:apply-templates>
            </info>
          </xsl:if>
          <xsl:apply-templates select="node() except $chapter-info" mode="#current">
            <xsl:with-param name="discard-child-lang" as="xs:boolean" select="if ($sec-is-completeley-in-other-lang) then true() else false()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@xml:lang" mode="custom-1">
    <xsl:param name="discard-child-lang" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="not($discard-child-lang)"><xsl:next-match/></xsl:if>    
  </xsl:template>
  
  <!-- expand xml:lang attributes from styles -->

  <xsl:template match="*[not(@xml:lang)]
                        [node()]/@srcpath" mode="hub:dissolve-sidebars-without-purpose" priority="10">
    <xsl:variable name="first-child-lang" as="attribute(xml:lang)?" select="*[1]/@xml:lang"/>
    <xsl:next-match/>
    <!-- expand lang fro styles or pull up lang from children -->
    <xsl:apply-templates select="key('hub:style-by-role', ../@role)/@xml:lang, 
                                  if (every $child in node() satisfies 
                                      $child[@xml:lang[. = $first-child-lang]
                                             or matches(.,'^[\p{Zs}\.,;!\?]+$')
                                            ]
                                      ) 
                                  then ../*[1]/@xml:lang 
                                  else ()" mode="#current"/>
  </xsl:template>

  <!-- remove redundant language tagging from ms word -->
  
  <xsl:template match="para[@xml:lang]
                           [*[(@xml:lang eq $doc-lang) or (@xml:lang ne ../@xml:lang)]]
                           [every $i in *[not(self::tab|self::footnote|self::anchor)]
                            satisfies $i[@xml:lang eq $doc-lang or (@xml:lang ne ../@xml:lang)]]
                           [  string-length(normalize-space(string-join(for $n in node()[not(self::tab|self::footnote|self::anchor)] return $n))) 
                            = string-length(normalize-space(string-join(*[not(self::tab|self::footnote|self::anchor)][@xml:lang eq $doc-lang or @xml:lang ne ../@xml:lang])))]" 
                mode="hub:preprocess-hierarchy" priority="3">
    <xsl:copy>
      <!-- discard lang on para if every child has another lang. -->
      <xsl:apply-templates select="@* except @xml:lang, node()" mode="#current">
        <xsl:with-param name="remove-lang" select="true()" as="xs:boolean?" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[self::phrase|self::footnote][@xml:lang eq $doc-lang]" mode="hub:preprocess-hierarchy" priority="3">
    <xsl:param name="remove-lang" as="xs:boolean?" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@* except @xml:lang,
                                  if($remove-lang or ..[not(@xml:lang)]) then () else @xml:lang,
                                  node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@xml:lang[. = ../../@xml:lang]" mode="hub:preprocess-hierarchy"/>

  <xsl:template match="para[@xml:lang ne $doc-lang][not(normalize-space())] | 
                       para[@xml:lang][(ancestor::*[@xml:lang])[1][@xml:lang = current()/@xml:lang]] " mode="hub:preprocess-hierarchy">
    <xsl:copy>
      <!-- discard lang on paras without text, discard lang on para whose ancestor has same lang -->
      <xsl:apply-templates select="@* except @xml:lang, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para[@xml:lang eq $doc-lang]
                           [not((ancestor::*[@xml:lang])[1][@xml:lang ne $doc-lang])]/@xml:lang" mode="hub:preprocess-hierarchy">
    <!-- discard lang on para if it is the same as doc lang. except if ancestor has another language. -->
  </xsl:template>
  
  <xsl:template match="section | sect1 | sect2 | sect3 | sect4 | sect5" mode="custom-1">
    <xsl:param name="remove-wrapper" as="xs:boolean" select="false()"/>
    <xsl:variable name="sec-info" as="element()*" 
                  select="((author, para[matches(@role, '^[a-z]{1,3}author$')])[1],
                           blockquote[para[matches(@role, '^[a-z]{1,3}motto$')]],
                           para[matches(@role, $info-subtitle-role)],
                           title,
                           abbrev,
                           epigraph,
                           biblioset,
                           abstract,
                           keywordset)"/>
    
    <xsl:choose>
      <xsl:when test="$remove-wrapper">
        <xsl:if test="$sec-info">
          <info>
            <xsl:apply-templates select="$sec-info" mode="#current"/>
          </info>
        </xsl:if>
        <xsl:apply-templates select="node() except $sec-info" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:variable name="first-lang" as="xs:string?" select="(descendant::*[@xml:lang])[1]/@xml:lang"/>
          <xsl:variable name="sec-is-completeley-in-other-lang" select="hub:sec-is-completeley-in-other-lang(., $first-lang)" as="xs:boolean"/>
          <xsl:if test="$sec-is-completeley-in-other-lang"><xsl:attribute name="xml:lang" select="$first-lang"/></xsl:if>
          <xsl:sequence select="hub:renderas-from-role-suffix(@renderas, title/@role)"/>
          <xsl:if test="$sec-info">
            <info>
              <xsl:apply-templates select="$sec-info" mode="#current">
                <xsl:with-param name="discard-child-lang" as="xs:boolean" select="if ($sec-is-completeley-in-other-lang) then true() else false()" tunnel="yes"/>
              </xsl:apply-templates>
            </info>
          </xsl:if>
          <xsl:apply-templates select="node() except $sec-info" mode="#current">
            <xsl:with-param name="discard-child-lang" as="xs:boolean" select="if ($sec-is-completeley-in-other-lang) then true() else false()" tunnel="yes"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="hub:sec-is-completeley-in-other-lang" as="xs:boolean">
    <!-- later in tex \selectlanguage{} will be generated -->
    <xsl:param name="sec" as="element()"/>
    <xsl:param name="first-lang" as="xs:string?"/>
    <xsl:sequence select="every $p 
                          in $sec/descendant::*[self::para[not(..[self::footnote])] | self::title] 
                          satisfies($p[descendant::text()[..[@xml:lang=$first-lang or self::phrase[starts-with(@role,'hub:')]]]
                                                         [hub:same-scope(., $p)]
                                       ]
                                    )"/>
  </xsl:function>
  
  <xsl:template match="para[matches(@role, '^[a-z]{1,3}headword$')]" mode="hub:hierarchy">
    <bridgehead>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bridgehead>
  </xsl:template>
  
  <!-- separate blockquotes by role after evolve-hub merged them
       https://redmine.le-tex.de/issues/13193 -->
  
  <xsl:template match="blockquote[not(   para[matches(@role, $info-blockquote-roles)]
                                      or para[matches(@role, $info-blockquote-source-roles)])]" mode="hub:clean-hub">
    <xsl:for-each-group select="*" group-adjacent="@role">
      <blockquote>
        <xsl:apply-templates select="current-group()[1]/@role, 
                                     current-group()" mode="#current"/>
      </blockquote>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="blockquote[para[matches(@role, $info-blockquote-roles)]]" mode="hub:clean-hub">
    <epigraph role="motto">
      <xsl:apply-templates select="node()"/>
      <xsl:copy-of select="following-sibling::*[1][self::para[matches(@role, $info-blockquote-source-roles)]]"/>
    </epigraph>
  </xsl:template>
    
  <xsl:template match="para[matches(@role, $info-blockquote-source-roles)]
                      |*[self::bibliomixed|self::para]/node()[1][self::br]
                      |*[self::bibliomixed|self::para]/br[every $p in preceding-sibling::node() 
                                                          satisfies $p[   not(matches(., '\P{Zs}')) 
                                                                       or empty(.)]]" 
                mode="hub:clean-hub"/>

  <xsl:template match="*[part]" mode="hub:clean-hub">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="self::part and (
        (count(*) eq 1 and title) and not(following-sibling::*[1][self::part]/title/node())
        or
        (not(title/node()))
        )
        ">
        <xsl:choose>
          <xsl:when test="current-grouping-key() eq true()">
            <xsl:copy>
              <xsl:apply-templates select="current-group()/node()" mode="#current"/>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!-- group boxes by start and end para style -->
  
  <xsl:template match="/hub[para[matches(@role, '^[a-z]{1,3}box')]]" mode="hub:dissolve-sidebars-without-purpose">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each-group select="*" group-starting-with="para[matches(@role, $box-start-regex)]">
        <xsl:variable name="start" select="current-group()[1][matches(@role, $box-start-regex)]" as="element()?"/>
        <xsl:choose>
          <xsl:when test="exists($start)">
            <xsl:for-each-group select="current-group()" group-ending-with="para[matches(@role, $box-end-regex)]">
              <xsl:variable name="end" select="current-group()[last()][matches(@role, $box-end-regex)]" as="element()?"/>
              <xsl:choose>
                <xsl:when test="exists($start) and exists($end)">
                  <div role="{replace($start/@role, 'start$', '')}">
                    <xsl:apply-templates select="current-group()" mode="#current"/>
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="current-group()" mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!-- abbrev for running headers -->
  
  <xsl:template match="title[following-sibling::para[matches(@role, $running-header-regex)]]" mode="hub:clean-hub">
    <xsl:apply-templates select="following-sibling::para[matches(@role, $running-header-regex)]" mode="running-header"/>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $running-header-regex)]" mode="running-header">
    <abbrev role="{@role}">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </abbrev>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $running-header-regex)]" mode="hub:clean-hub"/>
  
  <!--  *
        * special markup
        * -->
  
  <xsl:template match="para[matches(@role, $info-subtitle-role)][preceding-sibling::*[1]/self::title]
                      |info/para[matches(@role, $info-subtitle-role)]" mode="custom-1" priority="2">
    <subtitle>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </subtitle>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $info-author-role)]" mode="custom-1">
    <author>
      <personname>
        <othername>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </othername>
      </personname>
    </author>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $info-subtitle-role)]" mode="custom-1">
    <bridgehead>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bridgehead>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $literallayout-role-regex)]" mode="custom-1">
    <literallayout>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </literallayout>
  </xsl:template>
  
  <!--  *
        * figures and tables
        * -->
  
  <xsl:variable name="src-dir-uri" select="/hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-dir-uri']" as="xs:string"/>
  
  <xsl:template match="imagedata/@fileref[not(contains(., '192.168'))]" mode="hub:hierarchy">
    <xsl:attribute name="fileref" 
                   select="hub:container-path-to-uri(., /hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-dir-uri'])"/>
  </xsl:template>
  
  <!-- group multiple adjacent images in one figure environment -->
  
  <xsl:variable name="figure-roles-regex" as="xs:string"
                select="concat('(',
                               string-join(
                                           ($figure-image-role-regex, 
                                            $figure-caption-role-regex, 
                                            $figure-source-role-regex
                                           ),
                                           ')|('),
                               ')')" />
  
  <xsl:template match="*[para[.//mediaobject]]" mode="hub:split-at-tab">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" 
                          group-adjacent="    matches(@role, $figure-roles-regex, 'i')">
        <xsl:choose>
          <!-- suffix with number indicates relationship and position in an image group. 
               later we can use a syntax like "_1-3_2-4" to fit an image to layout grid (tbd).
          -->
          <xsl:when test="current-grouping-key()">
            <xsl:variable name="one-caption-for-multiple-images" as="xs:boolean" 
                         select="not(   count(current-group()[matches(@role, $figure-caption-role-regex, 'i')]) gt 1
                                     or count(current-group()[matches(@role, $figure-source-role-regex, 'i')])  gt 1)"/>
            <xsl:variable name="is-grid-group" as="xs:boolean"
                          select="    exists(current-group()[matches(@role, $figure-image-role-regex, 'i')][1][matches(@role, '\d+$')])
                                  and count(current-group()//dbk:mediaobject) gt 1"/>
            <xsl:element name="{if($one-caption-for-multiple-images) 
                                then 'figure' 
                                else 'informalfigure'}">
              <xsl:if test="$is-grid-group">
                <xsl:attribute name="css:display" select="'grid'"/>
                <xsl:attribute name="css:grid-template-columns" 
                               select="concat('repeat(',
                                              count(current-group()/mediaobject),
                                              ',1fr)')"/>
              </xsl:if>
              <xsl:apply-templates select="current-group()[matches(@role, $figure-image-role-regex, 'i')]/@role" mode="figure-role-type"/>
              <xsl:if test="some $p in current-group()[matches(@role, concat($figure-image-role-regex, '|', $figure-source-role-regex), 'i')] 
                            satisfies $p[node()[1][descendant-or-self::tab]]">
                <xsl:attribute name="remap" select="'list'"/>
              </xsl:if>
              <xsl:if test="$one-caption-for-multiple-images">
                <xsl:apply-templates select="current-group()[matches(@role, $figure-caption-role-regex, 'i')]" mode="figures"/>
              </xsl:if>
              <xsl:choose>
                <xsl:when test="$one-caption-for-multiple-images">
                  <xsl:apply-templates select="current-group()//mediaobject" mode="figures">
                    <xsl:with-param name="one-caption-for-multiple-images" as="xs:boolean" select="$one-caption-for-multiple-images"/>
                  </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each-group select="current-group()" 
                                        group-starting-with="self::para[matches(@role, $figure-image-role-regex, 'i')]">
                      <figure>
                        <xsl:apply-templates select="current-group()[matches(@role, $figure-image-role-regex, 'i')][1]/@role" mode="figure-role-type">
                          <xsl:with-param name="is-grid-group" select="$is-grid-group" as="xs:boolean"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="current-group()[matches(@role, $figure-caption-role-regex, 'i')],
                                                     current-group()//mediaobject,
                                                     current-group()[matches(@role, $figure-source-role-regex, 'i')]" mode="figures">
                        </xsl:apply-templates>
                      </figure>
                    </xsl:for-each-group>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$one-caption-for-multiple-images">
                <xsl:apply-templates select="current-group()[matches(@role, $figure-source-role-regex, 'i')]" mode="figures"/>
              </xsl:if>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $figure-caption-role-regex, 'i')]" mode="figures">
    <title>
      <xsl:apply-templates select="@srcpath, node()" mode="hub:split-at-tab"/>
    </title>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $figure-source-role-regex, 'i')]" mode="figures">
    <caption>
      <xsl:copy>
        <xsl:apply-templates select="@*, node()" mode="hub:split-at-tab"/>
      </xsl:copy>
    </caption>
  </xsl:template>
  
  <xsl:template match="mediaobject" mode="figures">
    <xsl:param name="one-caption-for-multiple-images" as="xs:boolean" select="false()"/>
    <xsl:copy>
      <xsl:if test="$one-caption-for-multiple-images">
        <xsl:attribute name="role" select="parent::para/@role"/>
      </xsl:if>
      <xsl:apply-templates select="@* except @role, node()" mode="hub:split-at-tab"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- figure role index letter represents cert -->
  
  <xsl:template match="@role" mode="figure-role-type">
    <xsl:param name="is-grid-group" select="false()" as="xs:boolean"/>
    <xsl:variable name="figure-type" as="xs:string" 
                  select="replace(., $figure-role-suffix-regex, '$1', 'i')"/>
    <xsl:choose>
      <xsl:when test="string-length($figure-type) gt 0">
        <xsl:attribute name="role" select="concat('figure-', lower-case(replace(., $figure-role-suffix-regex, '$1', 'i')))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="role" select="'figure'"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$is-grid-group">
      <xsl:attribute name="css:grid-column" select="replace(., $figure-role-suffix-regex, '$2', 'i')"/>
    </xsl:if>
  </xsl:template>
  
  <!-- dissolve informalfigures with no special role (we consider them as subsequent figures) -->
  
  <xsl:template match="informalfigure[@role eq 'figure']" mode="hub:dissolve-sidebars-without-purpose">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[self::figure | self::informalfigure]
                        [@remap = 'list']
                        [preceding-sibling::*[1][matches(@role, concat('[lL]ist|', $variable-list-role-regex))]]" mode="hub:dissolve-sidebars-without-purpose">
    <para>
      <xsl:copy-of select="preceding-sibling::*[1][matches(@role, concat('[lL]ist|', $variable-list-role-regex))]/@*[not(name() = 'srcpath')]"></xsl:copy-of>
      <xsl:next-match/>
    </para>
    <!-- https://redmine.le-tex.de/issues/13152 -->
  </xsl:template>

  <xsl:template match="*[self::figure | self::informalfigure]/@remap[. = 'list'] | 
                       *[self::figure | self::informalfigure][@remap = 'list']/*/node()[1][self::tab or self::phrase[every $n in node() satisfies $n[self::tab]]] | 
                       *[self::figure | self::informalfigure][@remap = 'list']/*/tab[every $p in preceding-sibling::node() satisfies $p[self::tab]]" mode="hub:dissolve-sidebars-without-purpose"/>

  <!-- remove paras and phrases that interfere with caption evaluation -->
  
  <xsl:template match="para[preceding-sibling::*[1][self::para][mediaobject]][not(normalize-space())]
                      |para[matches(@role, '[a-z]{2,3}figurecaption')][matches(., '^[\p{Zs}]+$')]" mode="hub:split-at-tab" priority="100000">
  </xsl:template>
  
  <xsl:template match="phrase[@css:color eq '#000000'][@srcpath][count(@*) eq 2]" mode="hub:split-at-tab">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:variable name="refs" select="tokenize(//link/(@linkend, @linkends), '\s')" as="xs:string*"/>
  
  <xsl:template match="anchor[@role = ('start', 'end')][not(@xml:id = $refs)]" mode="hub:split-at-tab"/>
  
  <!-- move anchors inside of footnote -->
  
  <!-- place footnote anchors inside of the footnote -->
  
  <xsl:template match="anchor[following-sibling::node()[1][self::footnote]]" mode="custom-1"/>
  
  <xsl:template match="footnote[preceding-sibling::node()[1][self::anchor]]" mode="custom-1">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:copy-of select="preceding-sibling::node()[1][self::anchor]"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- the two template below apply only to figures with multiple images, created in hub:split-at-tab -->
  
  <xsl:template match="figure[following-sibling::*[1]
                                                  [self::para[matches(@role, $hub:figure-title-role-regex-x)]]
                                                  ]" mode="hub:figure-captions">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <title>
        <xsl:copy-of select="following-sibling::*[1][not(matches(., '^[\p{Zs}]+$'))]
                                                 [self::para[matches(@role, $hub:figure-title-role-regex-x)]]/node()"/>
      </title>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="superscript[mediaobject]
                      |subscript[mediaobject]
                      |phrase[mediaobject]" mode="hub:clean-hub">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(., '^\s$')]" mode="hub:clean-hub">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $figure-caption-role-regex)]
                           [preceding-sibling::*[1][self::figure]]" mode="hub:figure-captions"/>
  
  <!-- move figure captions from top to bottom, otherwise subsequent modes don't treat them as figures -->
  
  <xsl:template match="para[matches(@role, $figure-caption-role-regex)][following-sibling::*[1][self::para[matches(@role, $figure-image-role-regex)]]]" 
                mode="hub:split-at-tab">
    <xsl:copy-of select="following-sibling::*[1][self::para[matches(@role, $figure-image-role-regex)]], ." copy-namespaces="no"/>
  </xsl:template>

  <xsl:variable name="hub:book-title-role" as="xs:string" select="'^[a-z]{1,3}metabooktitle$'"/>

  <xsl:template match="para[matches(@role, $figure-image-role-regex)]
                           [preceding-sibling::*[1][self::para[matches(@role, $figure-caption-role-regex)]]]" 
                mode="hub:split-at-tab"/>
  

  <xsl:template match="para[matches(@role, $hub:book-title-role)]" mode="hub:dissolve-sidebars-without-purpose">
    <xsl:param name="turn-to-meta" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$turn-to-meta">
      <title><xsl:apply-templates select="node()" mode="#current"/></title>
    </xsl:if>
  </xsl:template>

  <xsl:template match="hub/info" mode="hub:dissolve-sidebars-without-purpose">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="..//para[matches(@role, $hub:book-title-role)]" mode="#current">
        <xsl:with-param name="turn-to-meta" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- insert rotate role -->
  
  <xsl:template match="informaltable[preceding-sibling::*[position() = (1,2)][self::para[matches(@role, $hub:table-rotated-role-regex)]]]" mode="hub:hierarchy">
    <xsl:copy>
      <xsl:attribute name="role" select="string-join(('tablerotated', @role), ' ')"/>
      <xsl:apply-templates select="@* except @role, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $hub:table-rotated-role-regex)]
                           [following-sibling::*[position() = (1,2)][self::informaltable]]" mode="hub:hierarchy"/>
  
  <!-- insert table source into table -->
  
  <xsl:template match="table[following-sibling::*[1][self::para][matches(@role, $table-source-role-regex)]]
                      |figure[following-sibling::*[1][self::para][matches(@role, $figure-source-role-regex)]]" mode="custom-1">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <caption>
        <para>
          <xsl:apply-templates select="following-sibling::*[1][matches(@role, $table-source-role-regex)]/node()
                                      |following-sibling::*[1][matches(@role, $figure-source-role-regex)]/node()" mode="#current"/>  
        </para>
      </caption>
    </xsl:copy>
  </xsl:template>
  
  <!-- assign thead. currently very basic stuff, needs to be refinded 
       when more test data is available.-->
  
  <xsl:template match="tbody" mode="custom-1">
    <xsl:for-each-group select="row" group-adjacent="exists(.//para[matches(@role, $table-header-style-regex)])">
      <xsl:choose>
        <xsl:when test="current-grouping-key() eq true()">
          <thead>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </thead>
        </xsl:when>
        <xsl:otherwise>
          <tbody>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </tbody>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $table-source-role-regex)][preceding-sibling::*[1][self::table]]
                      |para[matches(@role, $figure-source-role-regex)][preceding-sibling::*[1][self::figure]]" mode="custom-1"/>
  
  <!-- tabs cause compilation issues -->
  
  <xsl:template match="caption//text()[contains(., '&#x9;')]
                      |title//text()[contains(., '&#x9;')]" mode="custom-1">
    <xsl:value-of select="replace(., '&#x9;', '&#x20;')"/>
  </xsl:template>
  
  <!--  *
        * dedication
        * -->
  
  <xsl:template match="blockquote[para[matches(@role, $dedication-role-regex)]]
                      |para[matches(@role, $dedication-role-regex)][not(parent::blockquote)]" mode="custom-1">
    <dedication>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </dedication>
  </xsl:template>
  
  <!--  * 
        * programm listing 
        * -->
  
  <xsl:template match="para[matches(@role, $codelisting-role-regex)]" mode="custom-1">
    <programlisting role="{@role}">
      <line>
        <xsl:apply-templates mode="#current"/>
      </line>
    </programlisting>
  </xsl:template>
  
  <!--  *
        * dialogue
        * -->
  
  <xsl:template match="blockquote[para[matches(@role, $dialogue-role-regex)]]" mode="custom-1">
    <xsl:copy>
      <xsl:attribute name="role" select="'dialogue'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $dialogue-role-regex)][not(phrase[@role eq 'hub:identifier'])]/text()[following-sibling::tab]
                      |para[matches(@role, $dialogue-role-regex)]/phrase[@role eq 'hub:identifier']" mode="custom-1">
    <personname role="speaker">
      <xsl:value-of select="."/>
    </personname>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $dialogue-role-regex)]
                           [not(tab or phrase[@role eq 'hub:identifier'])]" mode="custom-1">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:analyze-string select="." regex="^(\p{{L}}+)(\s\p{{L}}+)*:">
        <xsl:matching-substring>        
          <personname role="speaker">
            <xsl:value-of select="."/>
          </personname>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:copy>
  </xsl:template>
  
  <!-- gather speaker dialog parts, verses -->
  
  <xsl:template match="*[not(self::blockquote)]
                        [para[matches(@role, $dialogue-role-regex)][personname]
                        |para[matches(@role, $poem-role-regex)]]" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="(self::para[matches(@role, $dialogue-role-regex)][personname]/@role
                                                          ,self::para[matches(@role, $poem-role-regex)]/@role,
                                                          'false')[1]">
        <xsl:choose>
          <xsl:when test="current-grouping-key() ne 'false'">
            <xsl:element name="blockquote">
              <xsl:attribute name="role" select="current-grouping-key()"/>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <!--  *
        * bibliographies
        * -->
  
  <xsl:template match="para[matches(@role, $bibliography-role-regex)][string-length() gt 0]" mode="hub:hierarchy">
    <bibliomixed>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </bibliomixed>
  </xsl:template>
  
  <!-- bib sections which contain only bib entries -->
  
  <xsl:template match="*[local-name() = ('chapter', 'section')]
                        [title]
                        [bibliomixed]
                        [every $i in *[not(self::title|self::bridgehead|self::abbrev)]
                         satisfies $i/local-name() eq 'bibliomixed']" 
                mode="custom-1" priority="5">
    <bibliography>
      <xsl:next-match>
        <xsl:with-param name="remove-wrapper" as="xs:boolean" select="true()"/>
      </xsl:next-match>
    </bibliography>
  </xsl:template>
  
  <!-- mixed bibliographies -->
  
  <xsl:template match="*[not(self::bibliography 
                            |self::bibliodiv
                            |self::bibliolist)]
                        [not(title[matches(@role, $index-heading-regex)])]
                        [not(info/title[matches(@role, $index-heading-regex)])]
                        [bibliomixed]
                        [count(distinct-values(*[not(self::title
                                                    |self::bridgehead
                                                    |self::abbrev
                                                    |self::info)]/local-name())) gt 1]" 
                mode="custom-1" priority="3">
    <xsl:variable name="chapter-info" as="element()*" 
                  select="((author, 
                            para[matches(@role, $info-author-role)]
                            )[1],
                           para[matches(@role, $info-subtitle-role)],
                           title,
                           abbrev,
                           epigraph,
                           biblioset,
                           abstract,
                           keywordset) (: must be placed below title :)"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="exists($chapter-info)">
        <info>
          <xsl:apply-templates select="$chapter-info" mode="#current"/>
        </info>
      </xsl:if>
      <xsl:for-each-group select="*" group-adjacent="local-name() eq 'bibliomixed'">
        <xsl:choose>
          <xsl:when test="current-grouping-key() eq true()">
            <bibliography>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </bibliography>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group() except $chapter-info" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="bridgehead[following-sibling::*[1][self::bibliography]]" mode="custom-2"/>
  
  <xsl:template match="bibliography[preceding-sibling::*[1][self::bridgehead]]" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <info>
        <title>
          <xsl:copy-of select="preceding-sibling::*[1][self::bridgehead]/@*,
                               preceding-sibling::*[1][self::bridgehead]/node()"/>
        </title>
      </info>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- fix hyphens for tex -->
  
<!--  <xsl:variable name="hyphen-regex" select="'([a-z]+)-([a-z]+)'" as="xs:string"/>-->
  
 <!-- this also replaces text in links better use handling done in mode preprocess-hyphens--> 
 <!-- <xsl:template match="text()[matches(., $hyphen-regex)]" mode="custom-2">
    <xsl:value-of select="replace(., $hyphen-regex, '$1&#x2010;$2')"/>
  </xsl:template>-->

  
  <!-- clean-up the mess -->

  <xsl:template match="para[not(node())][not(matches(@role, $empty-line-style))]
                      |part/title[not(node())]
                      |blockquote[every $i in * 
                                  satisfies $i[not(node())]]" mode="hub:clean-hub" priority="5"/>
  
  <!-- remove width attributes from table cells for htmltabs -->
  
  <xsl:template match="entry/@css:width" mode="hub:clean-hub"/>
  
  <!-- move mediaobject below title -->
  
  <xsl:template match="title[mediaobject]" mode="hub:clean-hub" priority="100">
    <xsl:copy>
      <xsl:apply-templates select="* except mediaobject" mode="#current"/>
    </xsl:copy>
    <xsl:apply-templates select="mediaobject" mode="#current"/>
  </xsl:template>
  
  <!-- drop phrases without any text -->
  
  <xsl:template match="phrase[*][not(normalize-space())]" mode="custom-2">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- markup links -->
  
  <xsl:variable name="regex-for-url-to-link-recognition" as="xs:string" 
                select="'https?://[-a-z0-9\.:;#%_/\?=&amp;@]+[-a-z0-9:;#%_/=&amp;]'"/>

  <xsl:template match="text()[not(ancestor::link)][matches(., 'https?://')]" mode="hub:clean-hub">
    <xsl:analyze-string select="." regex="{$regex-for-url-to-link-recognition}" flags="i">
      <xsl:matching-substring>
        <link xlink:href="{.}">
          <xsl:value-of select="."/>
        </link>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- blind table for tab-like structures -->
  
  <xsl:template match="informaltable[matches(@role, '^[a-z]{1,3}tabulator$')]/tgroup" mode="custom-2">
    <xsl:processing-instruction name="latex" 
                                select="string-join(('&#xa;\begin{tabularx}{\textwidth}{', 
                                                     for $i in colspec return 'l', 
                                                     '}&#xa;'
                                                     ), '')"/>
    <xsl:for-each select="*/row">
      <xsl:for-each select="entry">
        <xsl:apply-templates select="*/node()" mode="#current"/>
        <xsl:if test="position() ne last()">
          <xsl:processing-instruction name="latex" select="'&#x20;&amp;&#x20;'"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:processing-instruction name="latex" select="' \\&#xa;'"/>
    </xsl:for-each>
    <xsl:processing-instruction name="latex" select="'&#xa;\end{tabularx}&#xa;'"/>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{1,3}listofendnotes$')]" mode="hub:split-at-tab" priority="15">
    <xsl:processing-instruction name="latex" select="'\printnotes'"/>
  </xsl:template>

  <xsl:template match="phrase[@css:background-color eq '#FFFFFF']/@css:background-color" mode="custom-2"/>
  <xsl:template match="phrase[@css:background-color eq '#FFFFFF'][count(@*) eq 2] " mode="custom-2" priority="4">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!-- *
       * group some lists earlier by format, see https://redmine.le-tex.de/issues/9844
       * -->
  
  <xsl:template match="*[para[matches(@role, $variable-list-role-regex)]]" mode="hub:identifiers">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="(@role, local-name())[1]">
        <xsl:choose>
          <xsl:when test="matches(current-grouping-key(), $variable-list-role-regex)">
            <variablelist role="{current-grouping-key()}">
              <xsl:for-each select="current-group()">
                <varlistentry>
                  <term>
                    <xsl:apply-templates select="node()[following-sibling::*[self::tab]]" mode="#current"/>
                  </term>
                  <listitem>
                    <xsl:apply-templates select="." mode="varlistentry"/>
                  </listitem>
                </varlistentry>                
              </xsl:for-each>
            </variablelist>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="variablelist[matches(@role, $variable-list-role-regex)]" mode="hub:postprocess-lists">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tab
                      |node()[following-sibling::*[self::tab]]" mode="varlistentry"/>
  
  <xsl:template match="@*|node()" mode="varlistentry">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- *  
       * dissolve paras that contain only equations 
       * -->
  
  <xsl:template match="para[equation]
                           [count(*) eq 1]
                           [not(text())]" mode="hub:clean-hub">
    <xsl:apply-templates select="equation"/>
  </xsl:template>
  
  <!-- * 
       * index creation
       *
       * there are several ways supported to create an index:
       * 
       * (1) word index function, support of /f switch for different index types
       * (2) markup index with a specific character style
       * (3) a list of index terms for which the text is searched and index entries are created
       * (4) static list of index entries
       * 
       * -->
  
  <!-- remove generated word indices first -->
  
  <xsl:template match="div[@role eq 'hub:index']" mode="hub:clean-hub"/>
  
  <!-- (1) create index container and include index headlines -->
  
  <xsl:variable name="index-types" as="xs:string*"
                select="distinct-values((//indexterm[not(@type)]/($index-type-default-name), //indexterm/@type))"/>
  
  <xsl:template match="/*[.//indexterm]" mode="custom-2">
    <xsl:variable name="doc" select="." as="element()"/>
    <xsl:variable name="existing-anchors-for-index-type" as="xs:string*" 
                  select="//index[not(indexentry)]/(@type, $index-type-default-name)[1]"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each select="$index-types[not(. = $existing-anchors-for-index-type)]">
        <xsl:variable name="index-index" as="xs:integer" 
                      select="count($static-index-sections) + index-of($index-types, .)"/>
        <xsl:variable name="index-type" select="." as="xs:string"/>
        <xsl:variable name="index-heading" as="xs:string"
                      select="($doc//*[self::para|self::title]
                                      [matches(@role, string-join(($index-heading-regex, $index-type, '$'), ''), 'i')][string-length() gt 0]
                                      [not(following-sibling::*[1][self::indexentry])]/node(),
                               'Index')[1]"/>
        <index type="{$index-type}" remap="{hub:index-letter($index-index)}">
          <info>
            <title>
              <xsl:value-of select="$index-heading"/>
            </title>
          </info>
        </index>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[self::part
                        |self::chapter
                        |self::section
                        |self::appendix]
                        [info/title[matches(@role, $index-heading-regex)]
                        |title[matches(@role, $index-heading-regex)]]" mode="custom-1" priority="3">
    <xsl:variable name="index-type" as="xs:string" 
                  select="(replace((info/title/@role, title/@role)[1], $index-heading-regex, ''), $index-type-default-name)[. ne ''][1]"/>
    <index>
      <!-- check if there are static index entries present (static index) or if the type 
           matches any real indexterm elements (dynamic index with index headline). sometimes
           users assign a index type to a headline but not to the index terms -->
      <xsl:if test="para or ($index-type = $index-types)">
        <xsl:attribute name="type" select="$index-type"/>
      </xsl:if>
      <xsl:if test="info/title or title">
        <info>
          <xsl:apply-templates select="info/title, title" mode="#current"/>
        </info>
      </xsl:if>
      <xsl:apply-templates select="* except (info, title)" mode="#current"/>
    </index>
  </xsl:template>
  
  <xsl:template match="indexterm" mode="custom-2">
    <xsl:variable name="index-type" as="xs:string"
                  select="(@type, $index-type-default-name)[1]"/>
    <xsl:variable name="index-index" as="xs:integer" 
                  select="count($static-index-sections) + index-of($index-types, $index-type)"/>
    <xsl:copy>
      <xsl:attribute name="remap" select="hub:index-letter($index-index)"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="indexterm[empty(*)]" priority="3" mode="custom-2"/>

  <!-- (2) create index entries from phrases with specific character style -->
  
  <xsl:template match="phrase[matches(@role, $index-mark-regex)]
                             [not(parent::indexterm)]
                             [not(.//indexterm)]" mode="hub:clean-hub">
    <xsl:apply-templates mode="#current"/>
    <indexterm>
      <xsl:attribute name="type" 
                     select="if(matches(@role, concat($index-mark-regex, '.+$')))
                             then replace(@role, $index-mark-regex, '')
                             else $index-type-default-name"/>
      <primary>
        <xsl:value-of select="."/>
      </primary>
    </indexterm>
  </xsl:template>
  
  <!-- (3) find index terms which match a list of index entries -->
  
  <xsl:variable name="index-list-entries" as="element(para)*" 
                select="//para[matches(@role, $index-list-regex)]"/>
  
  <xsl:variable name="index-list-search-terms" as="element()*" 
                select="$index-list-entries/(phrase[matches(@role, $index-name-regex)], .)[1]"/>
  
  <xsl:variable name="index-list-search-terms-available" as="xs:boolean"
                select="count($index-list-search-terms) gt 0"/>
  
  <xsl:variable name="index-list-search-terms-as-regex" as="xs:string" 
                select="concat('[\p{Zs}\p{P}](', 
                               translate(functx:escape-for-regex(string-join($index-list-search-terms, '▒')), 
                                         '▒', 
                                         '|'),
                               ')[\p{Zs}\p{P}]')"/>
  
  <xsl:template match="para[matches(@role, $index-list-regex)]" mode="custom-1"/>
  
  <xsl:template match="*[local-name() = ('para', 'title')]//text()[$index-list-search-terms-available]
                        [not(ancestor::*[matches(@role, $index-list-regex)])]
                        [not(ancestor::*/local-name() = ('indexterm', 'link', 'caption', 'bibliomixed'))]
                        [matches(., $index-list-search-terms-as-regex, 'i')]" mode="custom-1">
    <xsl:analyze-string select="." regex="{$index-list-search-terms-as-regex}" flags="i">
      <xsl:matching-substring>
        <xsl:variable name="index-term" as="node()"
                      select="$index-list-entries[lower-case((phrase[matches(@role, $index-name-regex)], .)[1]) = lower-case(regex-group(1))][1]"/>
        <xsl:value-of select="."/>
        <indexterm>
          <!-- check if @role suffix contains index type -->
          <xsl:attribute name="type" 
                         select="if(matches($index-term/@role, concat($index-list-regex, '.+$')))
                                 then replace($index-term/@role, concat('^', $index-list-regex), '')
                                 else $index-type-default-name"/>
          <primary>
            <xsl:apply-templates select="$index-term/node()" mode="#current"/>
          </primary>
        </indexterm>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <!-- (4) static index -->
  
  <xsl:template match="para[matches(@role, $index-static-regex)]" mode="custom-1">
    <xsl:variable name="see-exists" as="xs:boolean"
                  select="matches(., $index-see-regex)"/>
    <indexentry>
      <primaryie>
        <xsl:choose>
          <xsl:when test="$see-exists">
            <xsl:analyze-string select="." regex="{$index-see-regex}">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text>&#x20;</xsl:text>
                <seeie xreflabel="{regex-group(2)}">
                  <xsl:value-of select="regex-group(3)"/>
                </seeie>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </primaryie>
    </indexentry>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, $index-static-regex)]//text()" mode="custom-1">
    <xsl:analyze-string select="." regex="(,?\s)([\d]+)+">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)"/>
        <xref xlink:href="page-{regex-group(2)}"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="replace(., $index-see-regex, '$1')"/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:variable name="static-index-sections" as="element(index)*"
                select="//index[indexentry]"/>
  
  <xsl:template match="index[indexentry]" mode="custom-2">
    <xsl:variable name="index-type" select="@type" as="attribute(type)?"/>
    <xsl:variable name="index-title" as="element(info)?" 
                  select="info[title[matches(@role, $index-heading-regex, 'i')]]"/>
    <xsl:variable name="index-index" select="index-of($static-index-sections, .)" as="xs:integer"/>
    <xsl:for-each-group select="* except info" group-adjacent="local-name() eq 'indexentry'">
      <xsl:choose>
        <xsl:when test="current-grouping-key() eq true()">
          <!-- remap attribute is a letter and later needed to separate multiple indices -->
          <index remap="{hub:index-letter($index-index)}">
            <xsl:apply-templates select="$index-type, $index-title" mode="#current"/>
            <!-- indexdiv headline with starting letter -->
            <xsl:for-each-group select="current-group()" 
                                group-adjacent="translate(upper-case(substring(normalize-space(primaryie), 1, 1)), 
                                                          'ÄÅÃÀÁÂÆÖÒÓÔÕØÜÛÚÙÈÉÊËŽÇÌÍÎÏÐÑÝŸ', 
                                                          'AAAAAAAOOOOOOUUUUEEEEZCIIIIDNYY')">
              <indexdiv>
                <title><xsl:value-of select="current-grouping-key()"/></title>
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </indexdiv>
            </xsl:for-each-group>
          </index>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()[not(matches(@role, $index-heading-regex, 'i'))]" 
                               mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <!-- pre-existing index containers -->
  
  <xsl:template match="index[not(indexentry)]" mode="custom-2">
    <xsl:variable name="index-type" as="xs:string" 
                  select="(@type, $index-type-default-name)[1]"/>
    <xsl:variable name="index-index" as="xs:integer" 
                  select="count($static-index-sections) + index-of($index-types, $index-type)"/>
    <xsl:copy>
      <xsl:attribute name="remap" select="hub:index-letter($index-index)"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="hub:index-letter" as="xs:string">
    <xsl:param name="index" as="xs:integer"/>
    <xsl:value-of select="translate(xs:string($index), '123456789', 'abcdefghi')"/>
  </xsl:function>
  
  <!-- remove empty index terms early -->
  
  <xsl:template match="indexterm[not(normalize-space())][not(@class)]" mode="hub:split-at-tab"/>
  
  <!-- repair structure -->
  
  <xsl:template match="bibliodiv[matches(@role, $index-heading-regex)]" mode="custom-1">
    <index>
      <xsl:if test="matches(@role, concat($index-heading-regex, '.+$'))">
        <xsl:attribute name="type" select="replace(@role, $index-heading-regex, '')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </index>
  </xsl:template>
  
  <xsl:template match="para[not(parent::div[@role eq 'hub:index'])][matches(@role, $index-heading-regex, 'i')]" mode="custom-2"/>
  
  <xsl:template match="indexentry//@xml:lang
                      |indexterm//@xml:lang" mode="custom-2"/>
  
  <xsl:template match="css:rule[matches(@name, $index-heading-regex)]/@css:margin-left
                      |css:rule[matches(@name, $index-heading-regex)]/@css:text-indent" mode="hub:split-at-tab"/>
  
  <xsl:template match="para[matches(@role, concat('(', string-join($hub:hierarchy-role-regexes-x, ')|('), ')'), 'i')]
                           [not(normalize-space())]" mode="hub:preprocess-hierarchy"/>

  <xsl:template match="term/phrase[@role = 'Ausz_-_Glossarbegriff'][text()[last()]]" mode="hub:clean-hub">
    <xsl:value-of select="replace(., '\p{Zs}+$', '')"/>
  </xsl:template>
  
  <xsl:template match="bibliography[@role = ('Citavi', 'CSL', 'CSL-formatted')]" mode="hub:clean-hub"/>

<!-- group meta infos for same structure as in IDML-->
 <xsl:template match="*[*[matches(@role, '^[a-z]{2,3}meta') and not(matches(@role, '[a-z]{2,3}meta((chunk)?keyword|alternativeheadline)'))]]" mode="hub:meta-infos-to-sidebar">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="node()" group-adjacent="exists(self::para[matches(@role, '^[a-z]{2,3}meta') and not(matches(@role, '^[a-z]{2,3}meta((chunk)?keyword|alternativeheadline)'))])">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <sidebar role="chunk-metadata">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </sidebar>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para[matches(@role, '^(tsheading1|toctitle)$')][not(node())]" mode="hub:split-at-tab"/>

 <!-- pull meta infos after headings -->
  <xsl:template match="para[matches(@role, '^(tsheading|toctitle)')][preceding-sibling::*[1][@role = 'chunk-metadata']]" mode="hub:reorder-marginal-notes">
    <xsl:next-match/>
    <xsl:apply-templates select="preceding-sibling::*[1][@role = 'chunk-metadata']" mode="#current">
      <xsl:with-param name="process-meta-section" tunnel="yes" as="xs:boolean" select="true()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'chunk-metadata']" mode="hub:reorder-marginal-notes">
    <xsl:param name="process-meta-section" tunnel="yes" as="xs:boolean?"/>
    <xsl:if test="$process-meta-section or preceding-sibling::*[1][@role = ('tsheadlineleft', 'tsheadlineright', 'tsheading1', 'tsheading2', 'tsauthor')]">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

 <!-- meta infos to biblioset -->
  <xsl:template match="sidebar[@role = 'chunk-metadata']" mode="hub:process-meta-sidebar">
    <biblioset role="{@role}">
      <xsl:variable name="meta-elts" as="element(tmp-metadata)">
        <xsl:element name="tmp-metadata" exclude-result-prefixes="#all">
          <xsl:apply-templates select="*" mode="#current"/>
        </xsl:element>
      </xsl:variable>
      <xsl:for-each-group select="$meta-elts/node()" group-starting-with="*[self::*:personname]">
        <xsl:choose>
          <xsl:when test="current-group()[1][self::*:personname]">
            <xsl:for-each-group select="current-group()" group-adjacent="exists(.[local-name() = ('personname', 'email', 'orgname', 'affiliation', 'uri') 
                                                                    or 
                                                                    self::text()[matches(., '^\p{Zs}+$', 'm')]
                                                                                [preceding-sibling::node()[1]
                                                                                                          [local-name() = ('personname', 'email', 'orgname', 'affiliation', 'uri')]
                                                                                ]
                                                                    ])">
              <xsl:choose>
                <xsl:when test="current-grouping-key()">
                  <person>
                    <xsl:sequence select="current-group()"/>
                  </person>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="current-group()"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </biblioset>
  </xsl:template>

 <!-- sort metadata in chapter  -->
  <xsl:template match="*[sidebar[@role = 'chunk-metadata']]" mode="hub:process-meta-sidebar" priority="5">
    <xsl:copy>
      <xsl:apply-templates select="@*, (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]])" mode="#current"/>
      <xsl:apply-templates select="sidebar[@role = 'chunk-metadata']" mode="#current"/>
      <xsl:apply-templates select="node() except (title | abbrev | subtitle | author | para[@role[matches(.,'^(tsauthor|tssubheading)')]] | sidebar[@role = 'chunk-metadata'])" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
 <xsl:template match="para[matches(@role, '^[a-z]{1,3}meta')][not(matches(., '\S'))]" mode="hub:repair-hierarchy"/>

  <xsl:template match="para[@role = ('[a-z]{2,3}metadoi', '[a-z]{2,3}metachunkdoi')]" mode="hub:process-meta-sidebar">
    <biblioid otherclass="{if(@role eq '[a-z]{2,3}metadoi') then 'book-doi' else 'chunk-doi'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{2,3}metacontributionorcid')]" mode="hub:process-meta-sidebar">
    <uri otherclass="orcid">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </uri>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{2,3}metacontributionauthorname')]" mode="hub:process-meta-sidebar">
    <personname>
      <othername>  
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:value-of select="normalize-space(.)"/>
      </othername>
    </personname>
  </xsl:template>

  <xsl:template match="para[matches(@role, '^[a-z]{2,3}metacontributionlicence')]" mode="hub:process-meta-sidebar">
    <legalnotice otherclass="{if(matches(., '&#xa9;')) then 'copyright' else 'license'}">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:copy>
        <xsl:value-of select="normalize-space(.)"/>        
      </xsl:copy>
    </legalnotice>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{2,3}metacontributionauthoraffiliation')]" mode="hub:process-meta-sidebar">
    <!-- if an author exists, affiliation will be grouped into it as affiliation. otherwise it is orgname -->
    <xsl:choose>
      <xsl:when test="exists(..[para[matches(@role, '^[a-z]{2,3}metacontributionauthorname')]])">
        <affiliation>
          <orgname><xsl:apply-templates select="@*, node()" mode="#current"/></orgname>
        </affiliation>
      </xsl:when>
      <xsl:otherwise>
        <orgname otherclass="affiliation">
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </orgname>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, '^[a-z]{2,3}metacontributionauthorcontact')]" mode="hub:process-meta-sidebar">
    <email>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </email>
  </xsl:template>

  <xsl:template match="section[@role = 'abstract']" mode="hub:process-meta-sidebar">
    <abstract>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(title)">
        <xsl:apply-templates select="para[matches(@role, '^[a-z]{1,3}(metachunk)?abstract')][1]/node()[1][self::phrase]" mode="#current">
          <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="false()"/>
      </xsl:apply-templates>
    </abstract>
  </xsl:template>

  <xsl:template match="section[@role = ('abstract', 'keywords', 'alternative-title')][not(title)]/para[matches(@role, '^[a-z]{1,3}((meta(chunk))?(abstracts?|keywords?)|alternativeheadline)')][1]/node()[1][self::phrase]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="phrase-to-title" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$phrase-to-title" >
      <title>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:value-of select="normalize-space(replace(., ':\p{Zs}?$', ''))"/>
      </title>
    </xsl:if>
  </xsl:template>

  <xsl:template match="section[@role = ('abstract', 'keywords', 'alternative-title')][not(title)]/para[matches(@role, '^[a-z]{1,3}((meta(chunk))?(abstracts?|keywords?)|alternativeheadline)')][1][node()[1][self::phrase]]/node()[2][self::text()]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:value-of select="replace(., '^[\p{Zs}]+', '')"/>
  </xsl:template>

  <xsl:template match="para[@role[matches(., '^[a-z]{1,3}metacontributionyear')]]" mode="hub:process-meta-sidebar">
    <pubdate>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:value-of select="normalize-space(.)"/>
    </pubdate>
  </xsl:template>

  <xsl:template match="section[@role = 'keywords']" mode="hub:process-meta-sidebar">
  <xsl:variable name="keyword-role" as="xs:string?" select="if (title) 
                                                         then replace(normalize-space(title), ':\s?$', '') 
                                                         else replace(descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)][1], '^(.+):.+$', '$1')"/>
      <keywordset role="{if ($keyword-role[normalize-space()]) then $keyword-role else 'Keywords'}">
        <xsl:apply-templates select="descendant-or-self::para[matches(@role, $hub:article-keywords-role-regex)]" mode="#current">
          <xsl:with-param name="process-meta" tunnel="yes" as="xs:boolean?" select="true()"/>
        </xsl:apply-templates>
      </keywordset>
      <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(title)">
        <xsl:apply-templates select="para[matches(@role, '^[a-z]{1,3}meta(chunk)?keywords?')][1]/node()[1][self::phrase]" mode="#current">
          <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="phrase-to-title" as="xs:boolean" tunnel="yes" select="false()"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="biblioset//@role" mode="hub:twipsify-lengths hub:expand-css-properties" priority="3">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="sidebar[@role = 'chunk-metadata']/para[not(node())]" mode="hub:process-meta-sidebar" priority="3"/>

  <xsl:template match="para[matches(@role, $hub:article-keywords-role-regex)]" mode="hub:process-meta-sidebar" priority="2">
    <xsl:param name="process-meta" tunnel="yes" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$process-meta">
        <xsl:variable name="lang" select="key('natives', @role)" as="element(css:rule)?"/>
        <xsl:variable name="text" select="string-join(descendant::text(), '')" as="xs:string?"/>
        <xsl:variable name="without-heading" select="replace($text, '^(Schlüssel(wörter|begriffe)|Key\s?words|Mots[ -]clés):[\p{Zs}*]?', '', 'i')" as="xs:string?"/>
        <xsl:variable name="single-keywords" select="tokenize($without-heading, ',')" as="xs:string*"/>
        <xsl:for-each select="$single-keywords">
          <xsl:element name="keyword">
            <xsl:if test="$lang[@xml:lang]">
              <xsl:attribute name="xml:lang" select="$lang/@xml:lang"/>
            </xsl:if>
            <xsl:value-of select="if (. eq $single-keywords[last()]) then replace(normalize-space(.), '\.$', '') else normalize-space(.)"/>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="section[para[@role[matches(., '^[a-z]{1,3}(metachunk)?abstracts?$')]]]
                              [every $i in * 
                               satisfies (   $i/self::title 
                                          or $i/self::para[@role[matches(., '[a-z]{1,3}(metachunk)?abstracts?$')]])
                                          or not($i/node())]" mode="hub:repair-hierarchy" priority="5">
    <section role="abstract">
      <xsl:apply-templates mode="#current"/>
    </section>
  </xsl:template>

  <xsl:template match="*[para[matches(@role, '^[a-z]{1,3}(meta(chunk)?)?(abstracts?|keywords?|alternativeheadline)')]
                             [not(parent::abstract)]]" mode="hub:repair-hierarchy" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="exists(.[self::para][@role[matches(., '^[a-z]{1,3}(meta(chunk)?)?(abstracts?|keywords?|alternativeheadline)(heading)?')]])">
        <xsl:variable name="all-abstract-and-keyword-para" as="element(*)*" select="current-group()"/>
        <xsl:for-each-group select="current-group()" group-starting-with="(para[@role[matches(., '^[a-z]{1,3}(meta(chunk)?)?(abstracts?|keywords?|alternativeheadline)heading')] 
                                                                            or 
                                                                            (@role[matches(., '^[a-z]{1,3}(meta(chunk)?)?(abstracts?|keywords?|alternativeheadline)($|_-_)')] 
                                                                              and (. is $all-abstract-and-keyword-para[@role = current()/@role][1])
                                                                                (:and empty($all-abstract-and-keyword-para[@role[matches(., '[a-z]{1,3}(abstracts?|meta(chunk)?keywords?|alternativeheadline)heading')]]):)
                                                                             and empty($all-abstract-and-keyword-para[@role = concat(current()/@role, 'heading')]) 
                                                                            )]|*[not(self::para)])">
          <xsl:choose>
            <xsl:when test="current-group()[self::para[@role[matches(., '[a-z]{1,3}meta(chunk)?keywords?')]]]">
              <section role="keywords">
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </section>
            </xsl:when>
            <xsl:when test="current-group()[self::para[@role[matches(., '[a-z]{1,3}(metachunk)?abstracts?$')]]]">
              <section role="abstract">
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </section>
            </xsl:when>
            <xsl:when test="current-group()[self::para[@role[matches(., '[a-z]{1,3}metaalternativeheadline')]]]">
              <section role="alternative-title">
                <xsl:apply-templates select="current-group()" mode="#current"/>
              </section>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para[matches(@role, '^[a-z]{1,3}(meta(chunk)?)?(abstracts?|keywords?|alternativeheadline)heading')]" mode="hub:repair-hierarchy" priority="2">
    <title>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="/hub/info" mode="custom-2" priority="2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:for-each select="/hub/descendant::biblioset[1]/(issuenum | volumenum | biblioid[matches(@role, '[a-z]{1,3}metadoi$')] | productname | pubdate)">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="current()/@* except @srcpath" mode="#current"/>
          <xsl:value-of select="normalize-space(current())"/>
        </xsl:copy>
      </xsl:for-each>
      <xsl:apply-templates select="../abstract" mode="#current">
        <xsl:with-param name="moved-to-info" select="true()" as="xs:boolean" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="hub/abstract" mode="custom-2">
    <xsl:param name="moved-to-info" as="xs:boolean?" tunnel="yes"/>
    <xsl:if test="$moved-to-info">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="info[not(author) and biblioset[person]]/node()[1]" mode="custom-2" priority="15">
    <!-- only author metadata in biblioset will not be overridden -->
    <xsl:choose>
      <xsl:when test="count(biblioset/person) gt 1">
        <xsl:element name="authorgroup" exclude-result-prefixes="#all">
          <xsl:for-each select="biblioset/person">
            <xsl:element name="author" exclude-result-prefixes="#all">
              <xsl:copy-of select="biblioset/person/node()"/>
            </xsl:element>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="author" exclude-result-prefixes="#all">
          <xsl:copy-of select="biblioset/person/node()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="info/author" mode="custom-2">
    <xsl:choose>
      <xsl:when test="parent::info/biblioset[person]"> 
        <!-- metadata for each author is listed here. 
          information is processed with higher priority and chapter author is used as fallback -->
        <xsl:element name="authorgroup" exclude-result-prefixes="#all">
          <xsl:for-each select="parent::info/biblioset/person">
            <xsl:element name="author" exclude-result-prefixes="#all">
              <xsl:copy-of select="./node()"/>
            </xsl:element>
          </xsl:for-each>
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="role" select="'override'"/>
            <xsl:copy-of select="node()"/>
          </xsl:copy>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- no author specific metadata-->
        <xsl:copy>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
          <xsl:if test="parent::info/biblioset/orgname">
            <affiliation>
              <xsl:copy-of select="parent::info/biblioset/orgname"/>
            </affiliation>
          </xsl:if>
          <xsl:copy-of select="parent::info/biblioset/email,
            parent::info/biblioset/uri"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="info/biblioset/email
                      |info/biblioset/orgname
                      |info/biblioset/uri
                      |info/biblioset/person" mode="custom-2"/>

  <xsl:template match="hub/section[matches(@role, $hub:toc-heading)]" 
                mode="hub:postprocess-hierarchy">
    <toc xml:id="toc">
      <xsl:apply-templates select="@*, title, sidebar[@role = 'chunk-metadata']" mode="#current"/>
    </toc>
  </xsl:template>

  <!-- optional mode preprocesses whitespaces. based on mode docx2tex-preprocess in docx2tex/xsl/docx2tex-preprocess.xsl -->

  <xsl:template match="text()[parent::phrase]
                             [(matches(., '^(\s+).+') and ../node()[1][not(self::anchor | self::index-term)][self::text()]) or (matches(., '.+(\s+)$') and ../node()[not(self::anchor | self::index-term)][last()][self::text()])] (: leading or trailing whitespace :)
                             [string-length(normalize-space(.)) gt 0]
                             [not(following-sibling::node()[1][not(matches(., '^\s'))]) and 
                              not(preceding-sibling::node()[1][not(matches(., '\s$'))])]
                             [not(parent::phrase/@xml:space eq 'preserve')]
			     [not(following-sibling::*[1][self::*:inlineequation])]" mode="preprocess-whitespaces" priority="4">
    <xsl:param name="spaced" as="xs:boolean?" tunnel="no"/>
    <xsl:value-of select="if ($spaced) then normalize-space(.) else hub:gentle-normalize(.)"/>
  </xsl:template>

  <xsl:template match="phrase[matches(., '^(\s+).+|.+(\s+)$')][string-length(normalize-space(.)) gt 0]" mode="preprocess-whitespaces" priority="5">
    <xsl:if test="matches(., '^\s+') and node()[1][self::text()] and not(. is ../node()[not(self::anchor | self::index-term)][1])">
      <xsl:value-of select="hub:gentle-normalize(replace(., '^(\s+).+', '$1'))"/>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current">
        <xsl:with-param name="spaced" select="true()" tunnel="no" as="xs:boolean"/>
      </xsl:apply-templates>
    </xsl:copy>
    <xsl:if test="matches(., '\s+$') and node()[last()][self::text()] and not(. is ../node()[not(self::anchor | self::index-term)][last()])">
      <xsl:value-of select="hub:gentle-normalize(replace(., '.+(\s+)$', '$1'))"/>
    </xsl:if>
  </xsl:template>
  
    <xsl:template match="phrase[string-length(normalize-space(.)) eq 0][not(@role eq 'cr')]" 
                mode="preprocess-whitespaces" priority="1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(., '^\s+$')]" mode="preprocess-whitespaces">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="text()[normalize-space()][parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle][not(@xml:space = 'preserve')]][matches(., '^\s+\S+\s$')][count(../node()) eq 1] | 
                       text()[normalize-space()][parent::*[self::phrase[parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle]]
                                                                       [not(@xml:space = 'preserve')]
                                                          ]
                                                ]
                             [matches(., '^\s+\S+\s$')]
                             [count(../node()) eq 1][count(../../node()) eq 1]" mode="preprocess-whitespaces" priority="3">
  <!--   <para> test text </para>, <para><phrase> test text </phrase></para>-->
    <xsl:value-of select="hub:gentle-normalize(replace(., '^\s+(.+)\s+$', '$1'))"/>
  </xsl:template>

  <xsl:template match="text()[normalize-space()][parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle][not(@xml:space = 'preserve')]][matches(., '\s$')][. is ../node()[not(self::anchor | self::index-term)][last()]] | 
                       text()[normalize-space()][parent::*[self::phrase[parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle]]
                                                                       [not(@xml:space = 'preserve')]
                                                            ]
                                                 ]                       [matches(., '\s$')]
                       [. is ../node()[not(self::anchor | self::index-term)][last()] and .. is ../../node()[not(self::anchor | self::index-term)][last()]]" mode="preprocess-whitespaces"  priority="2">
      <!--   <para>test<br/>text  </para>, <para>test  text </para>, <para>test  <phrase>text </phrase></para> -->
    <xsl:value-of select="hub:gentle-normalize(replace(., '\s+$', ''))"/>
  </xsl:template>

  <xsl:template match="text()[normalize-space()][parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle][not(@xml:space = 'preserve')]][matches(., '^\s')][. is ../node()[not(self::anchor | self::index-term)][1]] | 
                       text()[normalize-space()][parent::*[self::phrase[parent::*[self::para | self::list-item | self::bibliomixed | self::title | self::subtitle]]
                                                                       [not(@xml:space = 'preserve')]
                                                          ]
                                                 ]
                             [matches(., '^\s')][. is ../node()[not(self::anchor | self::index-term)][1] and .. is ../../node()[not(self::anchor | self::index-term)][1]]" mode="preprocess-whitespaces" priority="2">
    <!--   <para> test text</para>, <para> test<br/>text</para>-->
    <xsl:value-of select="hub:gentle-normalize(replace(., '^\s+', ''))"/>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space()][matches(., '\s\s')]" mode="preprocess-whitespaces">
    <xsl:value-of select="hub:gentle-normalize(.)"/>
  </xsl:template>
  
  <xsl:template match="phrase[matches(@role, '^[a-z]{1,3}pi$')]" mode="custom-2">
    <xsl:copy>
      <xsl:apply-templates select="@role, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="hub:gentle-normalize" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:sequence select="replace($text, '(\s)(\s)+', '$1')"/>
  </xsl:function>

  <!-- optional mode to handle hyphens-->
  
<!-- 
  - normaler hyphen (-) → wird nicht getrennt
  - u8208/2010 (‐) → Wort links und rechts vom Trennstrich trennbar; Umbruch nach Trennstrich möglich
  - u8209/2011 (‑) → Wort links und rechts vom Trennstrich trennbar; verhindert, dass nach dem Trennstrich umbrochen wird-->
  

  <xsl:variable name="hub:prevent-normalization-style-regex" as="xs:string" select="'c_prevent_normalization'"/>
    
  <xsl:template match="text()[normalize-space()]
                             [matches(., '-')]
                             [not(ancestor::*[self::*:link|self::keywordset|self::biblioset[@role = 'chunk-metadata']])]
                             [not(exists(ancestor::*[matches(@role, $hub:prevent-normalization-style-regex)]))]" mode="preprocess-hyphens">
    <xsl:value-of select="hub:replace-hyphens(.)"/>
  </xsl:template>
  
  <cases>
   <case id="1" char="‑">(inhaltlich-)thematischen</case> 
   <case id="2" char="‑">Privatisierungsbefürwortern und -befürworterinnen </case> 
   <case id="3" char="‑">Kranken-, Kinder- und …</case> 
   <case id="4" char="‑">ÖPP-Beschleunigungsgesetz</case> 
   <case id="5" char="‑">α-Strahlung</case> 
   <case id="6" char="‐">bitter-süß</case> 
   <case id="7" char="‐">SPD-Führung</case>
   <case id="8" char="‐">EU-Bürger- und Bürgerinnen</case>
   <case id="9" char="‐"><phrase role="citalic">Apax</phrase>-Vorstand</case>
   <case id="10" char="‑">Covid-19-Infizierte ICE-3</case>
   <case id="10b" char="">450-Euro-Jobs</case>
   <case id="11" char="‐"><phrase role="citalic" srcpath="tei_d334e496">Zeit-</phrase>Verlagsgruppe</case>
   <case id="12" char="‐">»Schoolwork«-Gefüge ›Code your Life‹-Initiative</case>
   <case id="13" char="‐">Foto-Sharing-<link>…</link></case>
   <case id="14" char="‑">DFB-&amp;-McDonald’s</case>
   <case id="15" char="‐">Bertelsmann-»Studien«</case>
   <case id="16" char="">CDU-/CSU-Bundestagsfraktion</case>
   <case id="17" char="‐">401(k)-Fondsmodell</case>
   <case id="18" char="–">S. 1-7 (200-203)</case>
   <case id="19" char="–">Die Bahn baut die Rheintalstrecke aus - und ist wohl 2041 fertig</case>
  </cases>
  
  <xsl:function name="hub:replace-hyphens" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:variable name="regex" as="xs:string" select="'([\p{L}](-)[\),/\]\d])|((-).(-))|(\s(-)\p{L})|((^|\s)[\p{L}&#120576;-&#120777;]{1,2}(-)\p{L})|((^|[\p{L}‹«\d\)])(-)([\p{L}\s»›]|$))|((\p{Zs}|^)[\(\[]?\d+(-)\d+([^-]|$))|((\s-)\s)'"/>
    <xsl:variable name="tokens" as="text()+">
      <xsl:analyze-string select="$text" regex="{$regex}">
        <xsl:matching-substring>
          <!--case 1, 3, 14, 16: ([\p{L}|\.](-)[\),\]&amp;]) -->
          <xsl:if test="regex-group(1)"><xsl:value-of select="replace(regex-group(1), regex-group(2), '‑')"/></xsl:if>
          <!--case 14: ((-).(-)) -->
          <xsl:if test="regex-group(3)"><xsl:value-of select="concat('‑', translate(regex-group(3), '-', ''), '‐')"/></xsl:if>
          <!--case 2: (\s(-)\p{L}) -->
          <xsl:if test="regex-group(6)"><xsl:value-of select="replace(regex-group(6), regex-group(7), '‑')"/></xsl:if>
          <!--case 4, 5: ((^|\s)[\p{L}&#120576;-&#120777;]{1,2}(-)\p{L}) -->
          <xsl:if test="regex-group(8)"><xsl:value-of select="replace(regex-group(8), regex-group(10), '‑')"/></xsl:if>
          <!--case 6, 7, 8, 9, 11, 13, 12, 15, 17: ((^|[\p{L})(-)[\p{L}\s]) -->
          <xsl:if test="regex-group(11)"><xsl:value-of select="replace(regex-group(11), regex-group(13), '‐')"/></xsl:if>
           <!--case 18: (\s[\(\[]?\d+(-)\d+) -->
          <xsl:if test="regex-group(15)"><xsl:value-of select="replace(regex-group(15), regex-group(17), '–')"/></xsl:if>
          <!--case 19: ((\s-)\s) -->
          <xsl:if test="regex-group(19)"><xsl:value-of select="replace(regex-group(19), regex-group(20), '&#160;–')"/></xsl:if>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="string-join($tokens)"/>
  </xsl:function>
  
  <xsl:function name="hub:renderas-from-role-suffix" as="attribute(renderas)?">
    <xsl:param name="renderas" as="xs:string?"/>
    <xsl:param name="role" as="xs:string?"/>
    <xsl:if test="$role">
      <xsl:variable name="role-suffix" as="xs:string" 
                    select="replace($role, concat('^.+?(', $suffixes-regex, ')?$'), '$1')"/>
      <xsl:if test="string-length($role-suffix) gt 0">
        <xsl:attribute name="renderas" 
                       select="string-join(($renderas,
                                           'hub:no-toc'[matches($role-suffix, $no-toc-suffix)],
                                           'hub:no-pdf-bm'[matches($role-suffix, $no-pdf-bookmarks-suffix)]
                                           ), ' ')"/>
      </xsl:if>  
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>
