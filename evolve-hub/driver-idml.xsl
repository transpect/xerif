<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:dbk="http://docbook.org/ns/docbook" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:functx="http://www.functx.com"
  xmlns:tx="http://transpect.io/xerif"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub dbk tx" 
  version="2.0">
  
  <xsl:import href="driver-docx.xsl"/>

  <xsl:template match="@role[. = 'tsbody'] | *[contains(@role, '_-_DISCARD')]" mode="hub:split-at-tab" priority="3"/>

  <xsl:template match="@role[contains(., '_-_SPLIT')] | css:rule/@name[contains(., '_-_SPLIT')]" mode="hub:clean-hub">
    <xsl:attribute name="{name()}" select="replace(., '_-_SPLIT', '')"/>
  </xsl:template>

  <xsl:template match="sidebar[@remap][matches(@role, '^[a-z]{2,3}box(grey|border)(_-_SPLIT)?')]" mode="hub:postprocess-hierarchy">
    <xsl:element name="div">
      <xsl:apply-templates select="@* except @linkend, node()" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="title[phrase[matches(@role, 'berschrift1')]]" mode="hub:postprocess-hierarchy">
    <xsl:next-match/>
    <xsl:element name="titleabbrev">
      <xsl:attribute name="role" select="'tsheadlineright'"/>
      <xsl:apply-templates select="phrase[matches(@role, 'berschrift1')]/node()[not(self::br[. is ../node()[last()]])]" mode="#current"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="title/phrase[matches(@role, 'berschrift1')]" mode="hub:postprocess-hierarchy">
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>

  <xsl:template match="phrase[matches(@role, 'Alegreya|Barlow')]/@role" mode="hub:clean-hub"/>

  <xsl:template match="*:sidebar[*:para[starts-with(@role, 'tsmeta')]]" mode="hub:split-at-tab" priority="5">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'chunk-metadata'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[   para[.//mediaobject]
                        or para[matches(@role, $figure-image-role-regex, 'i')]]
                        [normalize-space(replace(., concat($pi-mark, '[a-z]+'), '', 'i'))]" mode="hub:split-at-tab">
    <xsl:copy>
      <!-- do not create figures like in docx -->
      <xsl:apply-templates select="@*,node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="hub:figure-title-role-regex-x" as="xs:string"
    select="$figure-caption-role-regex" />
    
  <xsl:variable name="hub:figure-caption-role-regex-x" as="xs:string"
    select="$fig-legend-para-style-regex" />

  <xsl:variable name="hub:figure-copyright-statement-role-regex"  as="xs:string" select="$figure-source-role-regex" />

    <xsl:function name="hub:is-figure-title" as="xs:boolean">
     <xsl:param name="node" as="node()?"/>
    <!-- overwritten to allow figures without titles-->
    <xsl:choose>
      <xsl:when test="$node/self::para[
                                       matches(@role, $hub:figure-title-role-regex-x, 'x')
                                       and descendant::text()
                                       and 
                                       ( 
                                       matches( hub:same-scope-text(.), concat('^(', $hub:figure-caption-start-regex, ')'))
                                       or not( $hub:figure-caption-must-begin-with-figure-caption-start-regex )
                                       )
                                       ]">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$node/self::*[hub:is-figure(.)] 
                      and 
                      $node/(following-sibling::*)[1][self::para[node()]][not(hub:is-figure-title(.))]
                                    [matches(@role, concat($hub:figure-caption-role-regex-x, '|', $hub:figure-copyright-statement-role-regex))]
                      and 
                      not($node/(preceding-sibling::*)[1][self::para[node()]][hub:is-figure-title(.)])">
        <xsl:sequence select="true()"/>
        <!-- image without title but note or copyright-statement -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
