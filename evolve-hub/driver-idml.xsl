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

</xsl:stylesheet>
