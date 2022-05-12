<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="http://transpect.io/xslt-util/iso-lang/xsl/iso-lang.xsl"/>
  
  <xsl:variable name="onix" select="collection()[2]" as="document-node(element(ONIXmessage))"/>
  
  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/epub-config/metadata">
    <xsl:copy>
      <dc:identifier format="EPUB3">
        <xsl:value-of select="$onix/ONIXmessage/product/productidentifier/b244"/>
      </dc:identifier>
      <dc:title>
        <xsl:value-of select="$onix/ONIXmessage/product/title/b203"/>
      </dc:title>
      <dc:description>
        <xsl:value-of select="$onix/ONIXmessage/product/othertext[d102 eq '01']/d104"/>
      </dc:description>
      <dc:creator>
        <xsl:value-of select="$onix/ONIXmessage/product/contributor/b036"/>
      </dc:creator>
      <dc:publisher>
        <xsl:value-of select="$onix/ONIXmessage/product/publisher/b081"/>
      </dc:publisher>
      <dc:language>
        <xsl:value-of select="tr:iso639-2-lang-to-iso639-1-lang($onix/ONIXmessage/product/language/b252)"/>
      </dc:language>
      <dc:rights>
        <xsl:value-of select="$onix/ONIXmessage/product/othertext[d102 eq '47']/d104"/>
      </dc:rights>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>