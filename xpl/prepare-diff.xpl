<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:epub="http://www.idpf.org/2007/ops"
  version="1.0">
  <p:input port="source" sequence="true" primary="true"><p:empty/></p:input>
  <p:option name="out-prefix" required="false"/>
  <p:option name="keep-full-name" required="false" select="'false'"/>
  <p:for-each name="source-iteration">
    <p:xslt name="delete-atts">
      <p:input port="parameters"><p:empty/></p:input>
            <p:with-param name="out-prefix" select="$out-prefix"/>
            <p:with-param name="keep-full-name" select="$keep-full-name"/>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                  <xsl:param name="out-prefix"/>
                  <xsl:param name="keep-full-name"/>
            <xsl:template match="* | @*">
              <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="@*, node()"/>
              </xsl:copy>
            </xsl:template>
            <xsl:template match="/" priority="2">
            <xsl:next-match/>
            <xsl:message select="'target-diff-dir: ', 
                            if ($keep-full-name = 'true')
                            then concat($out-prefix, '_', replace(base-uri(), '^.+/', ''))
                            else if (matches(base-uri(), 'difftest/out-')) 
                              then concat($out-prefix, replace(base-uri(), '^.*(-.+)$', '$1')) 
                              else concat($out-prefix, replace(base-uri(), '^.*(\..+)$', '$1'))"/>
            </xsl:template>
            <xsl:template match=" @*[local-name() = ('id', 'about-idrefs', 'refid', 'rid')]
                                    [matches(., '^((calstable|i[ted]|IFig)_|csl-)?B?(d\d+e\d+\s*)+$')] 
                                | @href[starts-with(., '#')] 
                                | *:meta[@name eq 'source-dir-uri'] 
                                | *:meta[@property = 'dcterms:modified']/text() 
                                | *:term[@key = ('source-dir-uri', 'archive-dir-uri', 'archive-uri', 'archive-uri-local')] 
                                | @xml:base
                                | @srcpath
                                | @compressed-size
                                | @date
                                | @last-modified
                                | @size
                                | @tr-generated-id
                                | @tr-dont-split-at-genid
                                | @tr-split-for
                                | *:p[matches(., '^(Dump timestamp|transpect repo)')] 
                                | *:span[starts-with(@class, 'imp-')]
                                | *:date/node()" priority="3"/>
            <xsl:template match=" @*[local-name() = ('id', 'about-idrefs', 'refid', 'rid')]
                                    [matches(., 'd\d+e\d+|cls-')]">
              <xsl:attribute name="{name()}" select="replace(., '(^|_)d\d+e\d+', '$1generated')"/>
            </xsl:template>
            <xsl:template match=" @*[local-name() = ('id', 'about-idrefs', 'refid', 'rid', 'linkends', 'linkend')]
                                    [matches(., '^cls-')]">
              <xsl:attribute name="{name()}" select="'cls'"/>
            </xsl:template>  
            <xsl:template match="@*[starts-with(., 'file:/')]">
              <xsl:attribute name="{name()}" select="replace(., '^.+/', '')"/>
            </xsl:template>
            <xsl:template match="*:meta[matches(@name, 'date', 'i')]/@content"/>
            <xsl:template match="@*[name() = ('src', 'href')][contains(., '#')]">
              <!-- <a href="XYZ.xhtml#it_d48051e13194">-->
              <xsl:attribute name="{name()}" select="replace(., '^(.+?)#.+$', '$1')"/>
            </xsl:template>
            <xsl:template match="@src[not(contains(., '#'))]
              [starts-with(., 'file:') or not(contains(., ':'))]
              [matches(., '(_[a-f0-9]+)(\.[0-9a-z]+)$', 'i')]" priority="1">
              <!-- do src atts with # exist at all? In any case, remove hashes from src uris that start with file: 
                or that are relative -->
              <xsl:attribute name="{name()}" select="replace(., '^(.+/)?(.+?)(_[a-f0-9]+)(\.[0-9a-z]+)$', '$2$4', 'i')"/>
            </xsl:template>
            <xsl:template match="@epub:type | type/@name">
              <xsl:attribute name="{name()}" select="replace(., '^.+?:', '')"/>
            </xsl:template>
            <xsl:template match="@*[name() = ('src', 'href', 'url', 'rendition')][contains(., 'transpect.le-tex.de')]">
              <xsl:attribute name="{name()}" select="replace(., 'transpect\.le-tex\.de', 'transpect.io')"/>
            </xsl:template>
            <xsl:template match="c:data[@content-type = 'text/plain']">
              <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="@*" mode="#current"/>
                <xsl:analyze-string select="." regex="file:/\S+">
                  <xsl:matching-substring>
                    <xsl:value-of select="replace(., '^.+/', '')"/>
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </xsl:copy>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    <p:store>
	     <p:documentation>Input base URIs for ex.: …/difftest/out-epubtools.xml, …/difftest/out-tei.xml</p:documentation>
      <p:with-option name="href" 
        select="if ($keep-full-name = 'true')
                then concat($out-prefix, '_', replace(base-uri(), '^.+/', ''))
                else if (matches(base-uri(), 'difftest/out-')) 
                  then concat($out-prefix, replace(base-uri(), '^.*(-.+)$', '$1')) 
                  else concat($out-prefix, replace(base-uri(), '^.*(\..+)$', '$1'))"/>
    </p:store>
  </p:for-each>
</p:declare-step>
