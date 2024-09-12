<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="css dbk jats xs"
  version="3.0">
  
  <xsl:import href="http://transpect.io/hub2bits/xsl/hub2bits.xsl"/>
  
  <!-- https://redmine.le-tex.de/issues/17480 -->
  
  <xsl:template match="annotation" mode="default"/>
  
</xsl:stylesheet>