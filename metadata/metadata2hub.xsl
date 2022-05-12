<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xlink="http://www.w3.org/1999/xlink" 
  xmlns="http://docbook.org/ns/docbook"
  version="2.0">
  
  <xsl:output indent="yes"/>

  <xsl:template match="/">
    <info>
      <xsl:apply-templates/>
    </info>
  </xsl:template>
  
  <xsl:template match="product/title/b203">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  <xsl:template match="title/b029">
    <subtitle>
      <xsl:apply-templates/>
    </subtitle>
  </xsl:template>
  
  <xsl:template match="contributor">
    <author>
      <personname>
        <xsl:apply-templates select="node() except b044"/>
      </personname>
      <xsl:apply-templates select="b044"/>
    </author>
  </xsl:template>
  
  <xsl:template match="contributor/b036">
    <othername>
      <xsl:apply-templates/>
    </othername>
  </xsl:template>
  
  <xsl:template match="contributor/b044">
    <personblurb>
      <para>
        <xsl:apply-templates/>
      </para>
    </personblurb>
  </xsl:template>
  
  <xsl:template match="othertext[d102 eq '46']">
    <legalnotice role="license" xlink:href="{d104}">
      <para role="legaltext">
        <xsl:apply-templates select="../othertext[d102 eq '47']/d104/text()"/>
      </para>
    </legalnotice>
  </xsl:template>
  
  <xsl:variable name="othertext-codes" select="'01', '08', '13'" as="xs:string+"/>
  <xsl:variable name="othertext-names" select="'about-book', 'review', 'about-author'" as="xs:string+"/>
  
  <xsl:template match="othertext[d102 = $othertext-codes]">
    <xsl:variable name="id" select="d102" as="element(d102)"/>
    <abstract role="{$othertext-names[index-of($othertext-codes, $id)]}">
      <xsl:for-each select="tokenize(d104, '\n')">
        <para>
          <xsl:value-of select="."/>
        </para>
      </xsl:for-each>
    </abstract>
  </xsl:template>
  
  <xsl:template match="relatedproduct[b012 eq 'DG']/productidentifier/b244">
    <biblioid role="eisbn">
      <xsl:apply-templates/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="product/productidentifier/b244">
    <biblioid role="isbn">
      <xsl:apply-templates/>
    </biblioid>
  </xsl:template>
  
  <xsl:template match="publisher/b081">
    <publisher>
      <publishername>
        <xsl:apply-templates/>  
      </publishername>
    </publisher>
    <copyright>
      <year>
        <xsl:value-of select="format-date(current-date(), '[Y]')"/>
      </year>
      <holder>
        <xsl:apply-templates/>
      </holder>
    </copyright>
  </xsl:template>
  
  <xsl:template match="seriesidentifier/b018">
    <edition>
      <xsl:apply-templates/>
    </edition>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  
</xsl:stylesheet>
