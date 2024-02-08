<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  xmlns:dbk="http://docbook.org/ns/docbook"
  version="1.0"
  name="parse-bibrefs">
    
  <p:input port="source" primary="true"/>
  <p:input port="stylesheet" primary="false"/>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true"/>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="debug-indent" select="'false'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/bib-parser/xpl/bib-parser.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  
  <p:variable name="out-dir" select="replace(/*/@xml:base, '^(.+/).+?$', '$1')"/>
  <p:variable name="basename" select="replace(/*/@xml:base, '^.+/(.+?)(\.[a-z]+)+$', '$1')"/>
  
  <p:parameters name="expose-parameters">
    <p:input port="parameters">
      <p:pipe port="parameters" step="parse-bibrefs"/>
    </p:input>
  </p:parameters>
    
  <tr:store-debug name="debug-params" pipeline-step="parse-bibrefs/00_params">
    <p:input port="source">
      <p:pipe port="result" step="expose-parameters"/>
    </p:input>
    <p:with-option name="active" select="'yes'"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:identity name="forward-input">
    <p:input port="source">
      <p:pipe port="source" step="parse-bibrefs"/>
    </p:input>
  </p:identity>
  
  <p:viewport match="dbk:bibliography[dbk:bibliomixed and not(dbk:biblioentry)]" name="bibliography-viewport">
    <p:variable name="bib-index" select="p:iteration-position()"/>
    <p:variable name="ref-txt-path" select="concat($out-dir, $basename, '.ref-', $bib-index, '.txt')"/>
    
    <p:xslt name="transform-xml-bibliography-to-plaintext">
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            
            <xsl:template match="/dbk:bibliography">
              <c:data content-type="text/plain">
                <xsl:for-each select="dbk:bibliomixed">
                  <xsl:value-of select="."/>
                  <xsl:text>&#xa;</xsl:text>
                </xsl:for-each>  
              </c:data>
            </xsl:template>
            
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    
    <tr:store-debug name="debug-bib-txt">
      <p:with-option name="pipeline-step" select="concat('parse-bibrefs/04_plain-ref-', $bib-index, '.txt')"/>
      <p:with-option name="active" select="'yes'"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
      <p:with-option name="indent" select="true()"/>
    </tr:store-debug>
    
    <p:store method="text" encoding="UTF-8" cx:depends-on="transform-xml-bibliography-to-plaintext" name="store-bibliography-as-plaintext">
      <p:with-option name="href" select="$ref-txt-path"/>
    </p:store>
    
    <tr:bib-parser name="bibliography-parser" cx:depends-on="store-bibliography-as-plaintext">
      <p:with-option name="href" select="$ref-txt-path"/>
      <p:with-option name="parser-path" select="/c:param-set/c:param[@name eq 'bib-parser-path']/@value">
        <p:pipe port="result" step="expose-parameters"/>
      </p:with-option>
    </tr:bib-parser>
    
    <tr:store-debug name="debug-bib-xml">
      <p:with-option name="pipeline-step" select="concat('parse-bibrefs/08_xml-ref-', $bib-index)"/>
      <p:with-option name="active" select="'yes'"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
      <p:with-option name="indent" select="true()"/>
    </tr:store-debug>
    
    <p:choose>
      <p:when test="c:errors">
        <p:add-attribute attribute-name="c:parse-bibrefs" attribute-value="failed" match="/*">
          <p:input port="source">
            <p:pipe port="current" step="bibliography-viewport"/>
          </p:input>
        </p:add-attribute>
      </p:when>
      <p:otherwise>
        <p:xslt name="transform-bibrefs">
          <p:input port="source">
            <p:pipe port="result" step="bibliography-parser"/>
            <p:pipe port="current" step="bibliography-viewport"/>
          </p:input>
          <p:input port="stylesheet">
            <p:pipe port="stylesheet" step="parse-bibrefs"/>
          </p:input>
          <p:input port="parameters">
            <p:pipe port="parameters" step="parse-bibrefs"/>
          </p:input>
          <p:with-param name="original-bibliography" select="/dbk:bibliography">
            <p:pipe port="current" step="bibliography-viewport"/>
          </p:with-param>
          <p:with-param name="bib-index" select="$bib-index"/>
        </p:xslt>
      </p:otherwise>
    </p:choose>
    
  </p:viewport>
  
  <tr:store-debug name="debug-hub" pipeline-step="parse-bibrefs/12_hub-doc">
    <p:with-option name="active" select="'yes'"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
</p:declare-step>
