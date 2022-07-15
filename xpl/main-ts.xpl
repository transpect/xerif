<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="main" 
  type="tx:main">
  
  <p:documentation>
    Converts docx to hub and generates LaTeX and an HTML report
  </p:documentation>
  
  <p:input port="params" primary="true"/>
  
  <p:input port="schema" primary="false">
    <p:document href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"/>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="remove-srcpaths"/>
  </p:output>
  
  <p:output port="tex" primary="false">
    <p:pipe port="result" step="hub2tex"/>
  </p:output>
  
  <p:output port="html" primary="false">
    <p:pipe port="html" step="tei2epub"/>
  </p:output>
  
  <p:output port="htmlreport" primary="false">
    <p:pipe port="result" step="htmlreport"/>
  </p:output>

  <p:output port="hub-flat" primary="false">
    <p:pipe port="result" step="docx2hub"/>
  </p:output>

  <p:output port="hub-rich" primary="false">
    <p:pipe port="result" step="evolve-hub-dyn"/>
  </p:output>

  <p:output port="epub-path" primary="false">
    <p:pipe port="result" step="tei2epub"/>
  </p:output>

  <p:serialization port="tex" method="text" media-type="text/plain" encoding="utf8"/>
  <p:serialization port="hub-flat" indent="true"/>
  <p:serialization port="hub-rich" indent="true"/>
  <p:serialization port="result" indent="true"/>
  <p:serialization port="html" method="xhtml"/>
  <p:serialization port="htmlreport" method="xhtml"/>
  
  <p:option name="file" required="true"/>
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:option name="layout" select="'c'">
    <p:documentation>
      letter represents specific layout: a, b, c, e
    </p:documentation>
  </p:option>
  
  <p:option name="toc-depth" select="3">
    <p:documentation>
      Depth of Table of Contents
    </p:documentation>
  </p:option>

  <p:option name="numbering-depth" select="3">
    <p:documentation>
      Depth of Headline Numbering, 3 is "1.1.1"
    </p:documentation>
  </p:option>
  
  <p:option name="title-pages" select="'yes'">
    <p:documentation>
      Render half-title, full-title and imprint. Possible values are 'yes' or 'no'
    </p:documentation>
  </p:option>

  <p:option name="notes-type" select="'footnotes'">
    <p:documentation>
      Whether notes should be placed as 'footnotes' or 'endnotes'
    </p:documentation>
  </p:option>

  <p:option name="notes-per-chapter" select="'no'">
    <p:documentation>
      Should notes be rendered and renumbered per chapter? Valid values are 'yes' and 'no'
    </p:documentation>
  </p:option>

  <p:option name="endnotes-with-chapter" select="'no'">
    <p:documentation>
      Show chapter headlines in endnote listing. Values: 'yes'/'no'.
    </p:documentation>
  </p:option>
  
  <p:option name="notes-per-chapter-notoc" select="'yes'">
    <p:documentation>
      Suppress endnote headings of chapter endnotes in table of contents. Values: 'yes'/'no'. 
    </p:documentation>
  </p:option>

  <p:option name="pubtype" select="'mono'">
    <p:documentation>
      Publication type. Can be represented by an arbitrary string.
    </p:documentation>
  </p:option>

  <p:option name="running-header" select="'no'">
    <p:documentation>
      Whether to render running headers. Permitted values: 'yes' or 'no'.
    </p:documentation>
  </p:option>

  <p:option name="run-local" select="'no'">
    <p:documentation>
      Fix image paths to match local output directory.
    </p:documentation>
  </p:option>
  
  <p:option name="file-ext" select="'docx'"/>

  <p:option name="create-idml" required="false" select="'no'"/>
  <p:option name="idml-target-uri"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/hub2tei/xpl/hub2tei.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/check-styles.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <p:import href="get-paths.xpl"/>
  <p:import href="copy-images.xpl"/>
  <p:import href="evolve-hub.xpl"/>
  <p:import href="htmlreport.xpl"/>
  <p:import href="insert-meta.xpl"/>
  <p:import href="load-meta.xpl"/>
  <p:import href="tei2epub.xpl"/>
  <p:import href="xml2tex.xpl"/>
  <p:import href="validate.xpl"/>
  <p:import href="hub2idml.xpl"/>
  <p:import href="export-chunks.xpl"/>
  <p:import href="customer-outputs.xpl"/>

  <tr:resolve-params name="resolve-params"/>
  
  <p:in-scope-names name="expand-options-as-params"/>
  
  <p:insert match="/c:param-set" position="last-child" name="consolidate-params">
    <p:input port="source">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:input port="insertion" select="//c:param">
      <p:pipe port="result" step="expand-options-as-params"/>
    </p:input>
  </p:insert>
  
  <p:sink/>
  
  <tr:file-uri name="normalize-filename">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <tx:get-paths name="get-paths">
    <p:input port="params">
      <p:pipe port="result" step="consolidate-params"/>
    </p:input>
    <p:with-option name="file" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:get-paths>
  
  <tx:load-meta name="load-meta-wrapper">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:load-meta>
  
  <!--<p:sink/>-->
  
  <docx2hub:convert name="docx2hub" mml-space-handling="xml-space" srcpaths="yes" cx:depends-on="load-meta-wrapper">
    <p:with-option name="docx" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="mathtype2mml" select="'yes'"/>
    <p:with-option name="remove-biblioentry-paragraphs" select="'no'"/>
  </docx2hub:convert>
  
  <tr:check-styles name="check-styles">
    <p:input port="parameters">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="cssa" select="'styles/cssa.xml'"/>
    <p:with-option name="differentiate-by-style" select="'true'"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:check-styles>     
  
  <tx:insert-meta name="insert-meta">
    <p:input port="meta">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:insert-meta>

  <tx:evolve-hub name="evolve-hub-dyn">
    <p:input port="parameters">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:evolve-hub>
  
  <tx:copy-images name="copy-images-and-patch-filerefs">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:copy-images>
  
  <tx:xml2tex name="hub2tex">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:xml2tex>
  
  <p:sink/>
  
  <p:choose name="hub2tei">
    <p:when test="$file-ext = 'docx'">
      <p:output port="result" primary="true">
        <p:pipe port="result" step="gen-tei"/>
      </p:output>
      <hub2tei:hub2tei name="gen-tei">
        <p:input port="source">
          <p:pipe port="result" step="copy-images-and-patch-filerefs"/> 
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </hub2tei:hub2tei>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true"/>   
      <p:xslt name="added-sourcepath">
        <p:input port="source">
          <p:pipe port="result" step="copy-images-and-patch-filerefs"/> 
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet version="2.0">
              <xsl:template match="*:p | *:td | *:seg | *:head | *:label | *:gloss | *:bibl | *:biblFull | *:biblStruct
                | *:listBibl//*" priority="2">
                <xsl:copy copy-namespaces="no">
                  <xsl:apply-templates select="@*"/>
                  <xsl:if test="not(@srcpath)">
                    <xsl:attribute name="srcpath" select="concat('tei_', generate-id(.))"/>
                  </xsl:if>
                  <xsl:apply-templates select="node()"/>
                </xsl:copy>
              </xsl:template>
              <xsl:template match="@* | node()">
                <xsl:copy copy-namespaces="no">
                  <xsl:apply-templates select="@*, node()"/>
                </xsl:copy>
              </xsl:template>
            </xsl:stylesheet>
          </p:inline>
        </p:input>
      </p:xslt>      
    </p:otherwise>
  </p:choose>
  
  <p:delete match="@srcpath" name="remove-srcpaths"/>
  
  <p:sink/>
  
  <tx:tei2epub name="tei2epub">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:with-option name="out-dir-uri" select="$out-dir-uri"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:tei2epub>
  
  <p:sink/>

  <tr:store-debug name="store-tei" pipeline-step="difftest/out-tei">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>
  
  <p:sink/>

  <tr:store-debug pipeline-step="difftest/out-html" extension="xhtml">
    <p:input port="source">
      <p:pipe step="tei2epub" port="html"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <tx:validate name="validate">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="hub">
      <p:pipe port="result" step="copy-images-and-patch-filerefs"/>
    </p:input>
    <p:input port="schema">
      <p:pipe port="schema" step="main"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="epub-file-uri">
      <p:pipe port="result" step="tei2epub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:validate>
  
  <p:sink/>
  
  <tx:htmlreport name="htmlreport">
    <p:input port="source">
      <p:pipe port="html" step="tei2epub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="reports">
      <p:pipe port="report" step="docx2hub"/>
      <p:pipe port="report" step="check-styles"/>
      <p:pipe port="report" step="evolve-hub-dyn"/>
      <p:pipe port="reports" step="validate"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:htmlreport>
  
  <p:sink/>

  <p:choose name="idml-synth">
    <p:when test="/*/c:param[@name = 'create-idml']/@value = 'yes'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:hub2idml name="hub2idml" >
        <p:input port="source">
          <p:pipe port="result" step="evolve-hub-dyn"/>
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug" />
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:hub2idml>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>Option create-idml: no</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink/>
    </p:otherwise>  
  </p:choose>

  <p:choose name="customer-outputs" cx:depends-on="hub2tei">
    <p:when test="/*/c:param[@name = 'customer-outputs']/@value[. = ('bits', 'jats')]">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:customer-outputs name="custom-output" >
        <p:input port="source">
          <p:pipe port="result" step="hub2tei"/>
        </p:input>
        <p:input port="params">
          <p:pipe port="result" step="get-paths"/>
        </p:input>
        <p:with-option name="debug" select="$debug" />
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:customer-outputs>
      <p:sink/>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>Option create-customer-outputx: no</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink/>
    </p:otherwise>  
  </p:choose>

<!--  <tr:store-debug pipeline-step="additional-outputs/customer-output">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>-->

  <p:choose name="split-html">
    <p:when test="/*/c:param[@name = 'export-chunks']/@value = 'yes'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:export-chunks>
        <p:input port="source">
          <p:pipe port="html" step="tei2epub"/>
        </p:input>
        <p:input port="tei">
          <p:pipe port="result" step="hub2tei"/>
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:export-chunks>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>do not chunk html</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink  name="s4"/>
    </p:otherwise>  
  </p:choose>

</p:declare-step>
