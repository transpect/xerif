<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="c xs dbk"
  version="2.0">
  
  <xsl:variable name="original-bibliography" as="document-node(element(dbk:bibliography))?" 
                select="collection()[2]"/>
  
  <xsl:template match="c:result">
    <bibliography>
      <xsl:apply-templates select="$original-bibliography/dbk:bibliography/@*,
                                   $original-bibliography/dbk:bibliography/*[not(self::dbk:bibliomixed)], 
                                   *"/>
    </bibliography>
  </xsl:template>
  
  <xsl:template match="dataset">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="sequence">
    <biblioentry>
      <xsl:apply-templates/>
    </biblioentry>
  </xsl:template>
  
  <xsl:template match="author
                      |editor
                      |director">
    <xsl:element name="{if(local-name() = ('author', 'editor'))
                        then local-name()
                        else 'othercredit'}">
      <xsl:if test="not(local-name() = ('author', 'editor'))">
        <xsl:attribute name="role" select="local-name()"/>
      </xsl:if>
      <personname>
        <othername>
          <xsl:apply-templates/>
        </othername>
      </personname>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  <xsl:template match="collection-title
                      |container-title
                      |edition">
    <edition role="{local-name()}">
      <xsl:apply-templates/>
    </edition>
  </xsl:template>
  
  <xsl:template match="note
                      |genre">
    <bibliomisc role="{local-name()}">
      <xsl:apply-templates/>
    </bibliomisc>
  </xsl:template>
  
  <xsl:template match="journal">
    <bibliosource role="journal">
      <xsl:apply-templates/>
    </bibliosource>
  </xsl:template>
  
  <xsl:template match="volume">
    <volumenum>
      <xsl:apply-templates/>
    </volumenum>
  </xsl:template>
  
  <xsl:template match="pages">
    <pagenums>
      <xsl:apply-templates/>
    </pagenums>
  </xsl:template>
  
  <xsl:template match="date">
    <date>
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <xsl:template match="location">
    <date>
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <xsl:template match="publisher">
    <publishername>
      <xsl:apply-templates/>
    </publishername>
  </xsl:template>
  
  
  <xsl:template match="@* | *">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>