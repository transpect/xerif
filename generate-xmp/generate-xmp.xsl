<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="adobe:ns:meta/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:xap="http://ns.adobe.com/xap/1.0/"
  xmlns:pdf="http://ns.adobe.com/pdf/1.3/"
  xmlns:pdfuaid="http://www.aiim.org/pdfua/ns/id/"
  xmlns:pdfaid="http://www.aiim.org/pdfa/ns/id/"
  xmlns:pdfx="http://ns.adobe.com/pdfx/1.3/"
  xmlns:pdfaExtension="http://www.aiim.org/pdfa/ns/extension/"
  xmlns:pdfaSchema="http://www.aiim.org/pdfa/ns/schema#"
  xmlns:pdfaProperty="http://www.aiim.org/pdfa/ns/property#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:xmp="http://ns.adobe.com/xap/1.0/"
  xmlns:xmpMM="http://ns.adobe.com/xap/1.0/mm/"
  xmlns:xmpRights="http://ns.adobe.com/xap/1.0/rights/"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:template match="/">
    <x:xmpmeta>
      <rdf:RDF>
        <rdf:Description rdf:about="">
          <!-- necessary metadata -->
          <pdfaid:part>3</pdfaid:part>
          <pdfaid:conformance>U</pdfaid:conformance>
          <pdfuaid:part>1</pdfuaid:part>
          <dc:format>application/pdf</dc:format>
          <!-- author -->
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
          <dc:rights>
            <rdf:Alt>
              <rdf:li xml:lang="x-default"><xsl:value-of select="ONIXmessage/product/publisher/b081"/></rdf:li>
            </rdf:Alt>
          </dc:rights>
          <!--<dc:rights>
            <rdf:Alt>
              <rdf:li xml:lang="x-default">TBD</rdf:li>
            </rdf:Alt>
          </dc:rights>
          <dc:subject>
            <rdf:Bag>
              <rdf:li>TBD</rdf:li>
              <rdf:li>...</rdf:li>
            </rdf:Bag>
          </dc:subject>-->
          <xmp:CreateDate><xsl:value-of select="current-dateTime()"/></xmp:CreateDate>
          <xmp:CreatorTool>LaTeX with hyperref</xmp:CreatorTool>
          <xmp:ModifyDate><xsl:value-of select="current-dateTime()"/></xmp:ModifyDate>
          <xmp:MetadataDate><xsl:value-of select="current-dateTime()"/></xmp:MetadataDate>
          <pdf:Keywords>anthropometry; Indian growth charts; growth references; growth standards; synthetic growth charts</pdf:Keywords>
          <pdf:Producer>le-tex xerif</pdf:Producer>
          <pdf:Keywords>
            <xsl:value-of select="string-join(ONIXmessage/product/subject[b067 eq '20']/b070, ', ')"/>
          </pdf:Keywords>
          <pdf:Copyright>
            <xsl:value-of select="format-date(current-date(), '[Y]')"/>
            <xsl:text> Copyright by </xsl:text>
            <xsl:value-of select="ONIXmessage/product/publisher/b081"/>
          </pdf:Copyright>
          <xmpMM:DocumentID>uuid:0a260816-6fd8-456e-bdcc-1f7db1176b0e</xmpMM:DocumentID>
          <xmpMM:InstanceID>uuid:d689337d-78a1-4a0d-a88f-39319e1396c6</xmpMM:InstanceID>
          <xmpRights:Marked>True</xmpRights:Marked>
          <xmpRights:WebStatement>https://creativecommons.org/licenses/by/4.0</xmpRights:WebStatement>
          <pdfaExtension:schemas>
            <rdf:Bag>
              <rdf:li rdf:parseType="Resource">
                <pdfaSchema:namespaceURI>http://ns.adobe.com/pdf/1.3/</pdfaSchema:namespaceURI>
                <pdfaSchema:prefix>pdf</pdfaSchema:prefix>
                <pdfaSchema:schema>Adobe PDF Schema</pdfaSchema:schema>
                <pdfaSchema:property>
                  <rdf:Seq>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>A name object indicating whether the document has been modified to include trapping information</pdfaProperty:description>
                      <pdfaProperty:name>Trapped</pdfaProperty:name>
                      <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                    </rdf:li>
                  </rdf:Seq>
                </pdfaSchema:property>
              </rdf:li>
              <rdf:li rdf:parseType="Resource">
                <pdfaSchema:namespaceURI>http://ns.adobe.com/xap/1.0/mm/</pdfaSchema:namespaceURI>
                <pdfaSchema:prefix>xmpMM</pdfaSchema:prefix>
                <pdfaSchema:schema>XMP Media Management Schema</pdfaSchema:schema>
                <pdfaSchema:property>
                  <rdf:Seq>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>UUID based identifier for specific incarnation of a document</pdfaProperty:description>
                      <pdfaProperty:name>InstanceID</pdfaProperty:name>
                      <pdfaProperty:valueType>URI</pdfaProperty:valueType>
                    </rdf:li>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>The common identifier for all versions and renditions of a document.</pdfaProperty:description>
                      <pdfaProperty:name>OriginalDocumentID</pdfaProperty:name>
                      <pdfaProperty:valueType>URI</pdfaProperty:valueType>
                    </rdf:li>
                  </rdf:Seq>
                </pdfaSchema:property>
              </rdf:li>
              <rdf:li rdf:parseType="Resource">
                <pdfaSchema:namespaceURI>http://www.aiim.org/pdfa/ns/id/</pdfaSchema:namespaceURI>
                <pdfaSchema:prefix>pdfaid</pdfaSchema:prefix>
                <pdfaSchema:schema>PDF/A ID Schema</pdfaSchema:schema>
                <pdfaSchema:property>
                  <rdf:Seq>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>Part of PDF/A standard</pdfaProperty:description>
                      <pdfaProperty:name>part</pdfaProperty:name>
                      <pdfaProperty:valueType>Integer</pdfaProperty:valueType>
                    </rdf:li>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>Amendment of PDF/A standard</pdfaProperty:description>
                      <pdfaProperty:name>amd</pdfaProperty:name>
                      <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                    </rdf:li>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>Conformance level of PDF/A standard</pdfaProperty:description>
                      <pdfaProperty:name>conformance</pdfaProperty:name>
                      <pdfaProperty:valueType>Text</pdfaProperty:valueType>
                    </rdf:li>
                  </rdf:Seq>
                </pdfaSchema:property>
              </rdf:li>
              <rdf:li rdf:parseType="Resource">
                <pdfaSchema:namespaceURI>http://www.aiim.org/pdfua/ns/id/</pdfaSchema:namespaceURI>
                <pdfaSchema:prefix>pdfuaid</pdfaSchema:prefix>
                <pdfaSchema:schema>PDF/UA ID Schema</pdfaSchema:schema>
                <pdfaSchema:property>
                  <rdf:Seq>
                    <rdf:li rdf:parseType="Resource">
                      <pdfaProperty:category>internal</pdfaProperty:category>
                      <pdfaProperty:description>Part of PDF/UA standard</pdfaProperty:description>
                      <pdfaProperty:name>part</pdfaProperty:name>
                      <pdfaProperty:valueType>Open Choice of Integer</pdfaProperty:valueType>
                    </rdf:li>
                  </rdf:Seq>
                </pdfaSchema:property>
              </rdf:li>
            </rdf:Bag>
          </pdfaExtension:schemas>
        </rdf:Description>
      </rdf:RDF>
    </x:xmpmeta>
  </xsl:template>
  
</xsl:stylesheet>
