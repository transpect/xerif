<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="adobe:ns:meta/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:xap="http://ns.adobe.com/xap/1.0/"
  xmlns:pdf="http://ns.adobe.com/pdf/1.3/"
  xmlns:pdfx="http://ns.adobe.com/pdfx/1.3/"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <x:xmpmeta>
      <rdf:RDF>
        <rdf:Description rdf:about="">
          <pdf:Keywords>
            <xsl:value-of select="string-join(ONIXmessage/product/subject[b067 eq '20']/b070, ', ')"/>
          </pdf:Keywords>
          <pdf:Copyright>
            <xsl:value-of select="format-date(current-date(), '[Y]')"/>
            <xsl:text> Copyright by </xsl:text>
            <xsl:value-of select="ONIXmessage/product/publisher/b081"/>
          </pdf:Copyright>
          <pdf:Marked>True</pdf:Marked>
          <pdf:Producer>le-tex xerif</pdf:Producer>
        </rdf:Description>
        <rdf:Description rdf:about="">
          <xap:ModifyDate><xsl:value-of select="current-dateTime()"/></xap:ModifyDate>
          <xap:CreatorTool>le-tex xerif</xap:CreatorTool>
          <xap:CreateDate><xsl:value-of select="current-dateTime()"/></xap:CreateDate>
          <xap:MetadataDate><xsl:value-of select="current-dateTime()"/></xap:MetadataDate>
        </rdf:Description>
        <rdf:Description rdf:about="">
          <dc:format>application/pdf</dc:format>
          <dc:title>
            <rdf:Alt>
              <rdf:li xml:lang="x-default">
                <xsl:value-of select="ONIXmessage/product/title/b203"/>
              </rdf:li>
              <xsl:for-each select="ONIXmessage/product/title/b029">
                <rdf:li xml:lang="x-default">
                  <xsl:value-of select="ONIXmessage/product/title/b203"/>
                </rdf:li>
              </xsl:for-each>
            </rdf:Alt>
          </dc:title>
          <dc:creator>
            <rdf:Seq>
              <xsl:for-each select="ONIXmessage/product/contributor[b035 eq 'A32']">
                <rdf:li>
                  <xsl:value-of select="b036"/>
                </rdf:li>  
              </xsl:for-each>
            </rdf:Seq>
          </dc:creator>
          <dc:description>
            <rdf:Alt>
              <rdf:li xml:lang="x-default">
                <xsl:value-of select="/ONIXmessage/product[1]/othertext[d102 eq '01']/d104"/>
              </rdf:li>
            </rdf:Alt>
          </dc:description>
        </rdf:Description>
        <rdf:Description rdf:about="">
          <pdfx:Copyright>Copyright 2008, Adobe Systems Incorporated, all rights reserved.</pdfx:Copyright>
          <pdfx:Marked>True</pdfx:Marked>
        </rdf:Description>
        <!--<rdf:Description rdf:about=""
          xmlns:xapMM="http://ns.adobe.com/xap/1.0/mm/">
          <xapMM:DocumentID>uuid:a2a0d182-7b1c-4801-a22c-d610115116bd</xapMM:DocumentID>
          <xapMM:InstanceID>uuid:1a365cee-e070-4b52-8278-db5e46b20a4c</xapMM:InstanceID>
        </rdf:Description>-->
      </rdf:RDF>
    </x:xmpmeta>
  </xsl:template>
  
</xsl:stylesheet>
