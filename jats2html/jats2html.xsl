<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub2htm="http://transpect.io/hub2htm" 
  xmlns:jats2html="http://transpect.io/jats2html"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://transpect.io/jats2html/xsl/jats2html.xsl"/>
  
  <xsl:param name="file"/>
  
  <xsl:param name="srcpaths" select="'yes'" as="xs:string"/>
  <xsl:param name="xhtml-version" select="'5.0'" as="xs:string"/>
  <xsl:param name="css-location" select="''"/>
  <xsl:param name="toc" select="'yes'" as="xs:string"/>
  <xsl:param name="toc-max-level" select="3" as="xs:integer?"/>
  <xsl:param name="generate-footnote-title" select="'yes'" as="xs:string"/>
  <xsl:param name="lang" select="/book/@xml:lang" as="xs:string?"/>  

</xsl:stylesheet>