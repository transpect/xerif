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
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="hub2epub" 
  type="tx:hub2epub">
  
   <p:input port="source" primary="true">
    <p:documentation>
      Expects a HUB XML Document
    </p:documentation>
  </p:input>
  
  <p:input port="params" primary="false">
    <p:documentation>
      A c:param-set paths document
    </p:documentation>
  </p:input>
  
  <p:input port="meta" primary="false">
    <p:documentation>
      Metadata
    </p:documentation>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:pipe port="html" step="create-epub"/>
  </p:output>
  
  <p:output port="xml" primary="false">
    <p:pipe port="result" step="clean-output-xml"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="create-epub"/>
  </p:output>
  
  <p:output port="epub-path" primary="false">
    <p:pipe port="result" step="create-epub"/>
  </p:output>
  
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:option name="output-xml" select="'tei'">
    <p:documentation>preferred XML Output. possible values: "bits" or "tei"</p:documentation>
  </p:option>
  
  <p:import href="http://transpect.io/hub2html/xpl/hub2html.xpl"/>
  <p:import href="http://transpect.io/hub2tei/xpl/hub2tei.xpl"/>
  <p:import href="http://transpect.io/tei2html/xpl/tei2html.xpl"/>
  <p:import href="http://transpect.io/hub2bits/xpl/hub2bits.xpl"/>
  <p:import href="http://transpect.io/jats2html/xpl/jats2html.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/insert-srcpaths/xpl/insert-srcpaths.xpl"/>
  
  <p:import href="html2epub.xpl"/>
  
  <p:choose name="choose-output-xml">
    <p:when test="$output-xml eq 'tei'">
      <p:output port="result" primary="true">
        <p:pipe port="result" step="hub2tei"/>
      </p:output>
      <p:output port="html" primary="false">
        <p:pipe port="result" step="tei2html"/>
      </p:output>
      
      <hub2tei:hub2tei name="hub2tei">
        <p:input port="source">
          <p:pipe port="source" step="hub2epub"/> 
        </p:input>
        <p:input port="paths">
          <p:pipe port="params" step="hub2epub"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </hub2tei:hub2tei>
      
      <tr:store-debug name="store-tei" pipeline-step="difftest/out-tei">
        <p:with-option name="active" select="'yes'"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
        <p:with-option name="indent" select="true()"/>
      </tr:store-debug>
      
      <tei2html:tei2html name="tei2html">
        <p:input port="paths">
          <p:pipe port="params" step="hub2epub"/>
        </p:input>
        <p:with-option name="srcpaths" select="'yes'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tei2html:tei2html>
      
    </p:when>
    <p:when test="$output-xml eq 'bits'">
      <p:output port="result" primary="true">
        <p:pipe port="result" step="hub2bits"/>
        <!--<p:pipe port="result" step="insert-srcpaths-into-bits"/>-->
      </p:output>
      <p:output port="html" primary="false">
        <p:pipe port="result" step="jats2html"/>
      </p:output>
      
      <jats:hub2bits name="hub2bits">
        <p:input port="source">
          <p:pipe port="source" step="hub2epub"/> 
        </p:input>
        <p:input port="models">
          <p:inline>
            <c:models>
              <c:model href="http://jats.nlm.nih.gov/extensions/bits/2.0/rng/BITS-book2.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"/>
            </c:models>
          </p:inline>
        </p:input>
        <p:input port="paths">
          <p:pipe port="params" step="hub2epub"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </jats:hub2bits>
            
      <tr:store-debug name="store-bits" pipeline-step="difftest/out-bits">
        <p:with-option name="active" select="'yes'"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
        <p:with-option name="indent" select="true()"/>
      </tr:store-debug>
      
      <jats:html name="jats2html">
        <p:input port="paths">
          <p:pipe port="params" step="hub2epub"/>
        </p:input>
        <p:with-option name="srcpaths" select="'yes'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </jats:html>
      
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true">
        <p:pipe port="result" step="identity-hub"/>
      </p:output>
      <p:output port="html" primary="false">
        <p:pipe port="result" step="hub2html"/>
      </p:output>
      
      <p:identity name="identity-hub">
        <p:input port="source">
          <p:pipe port="source" step="hub2epub"/>
        </p:input>
      </p:identity>
      
      <hub2htm:convert name="hub2html">
        <p:input port="paths">
          <p:pipe port="params" step="hub2epub"/>
        </p:input>
        <p:input port="other-params">
          <p:empty/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </hub2htm:convert>
      
    </p:otherwise>
  </p:choose>
  
  <p:delete name="clean-output-xml" match="@css:* | css:rules | @srcpath | @c:*"/>
  
  <p:sink/>
  
  <p:choose name="create-epub">
    <p:when test="/*/c:param[@name = 'create-epub']/@value = 'yes'">
      <p:xpath-context><p:pipe port="params" step="hub2epub"/></p:xpath-context>
      <p:output port="result">
        <p:pipe port="result" step="html2epub"/>
      </p:output>
      <p:output port="report" sequence="true">
        <p:pipe port="report" step="html2epub"/>
      </p:output>
      <p:output port="html">
        <p:pipe port="html" step="html2epub"/>
      </p:output>
      
      <tx:html2epub name="html2epub">
        <p:input port="source">
          <p:pipe port="html" step="choose-output-xml"/>
        </p:input>
        <p:input port="params">
          <p:pipe port="params" step="hub2epub"/>
        </p:input>
        <p:input port="meta">
          <p:pipe port="meta" step="hub2epub"/>
        </p:input>
        <p:with-option name="out-dir-uri" select="$out-dir-uri"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tx:html2epub>
      
    </p:when>
    <p:otherwise>
      <p:output port="result">
        <p:inline><c:result os-path="bogo"/></p:inline>
      </p:output>
      <p:output port="html">
        <p:pipe port="result" step="identity-html"/>
      </p:output>
      <p:output port="report">
        <p:pipe port="result" step="identity-html"/>
      </p:output>
      
      <p:identity name="identity-html">
        <p:input port="source">
          <p:pipe port="html" step="choose-output-xml"/>
        </p:input>
      </p:identity>
      
    </p:otherwise>  
  </p:choose>
  
  <tr:store-debug pipeline-step="difftest/out-html" extension="xhtml">
    <p:input port="source">
      <p:pipe step="create-epub" port="html"/>
    </p:input>
    <p:with-option name="active" select="'yes'"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
   
  <p:sink/>

</p:declare-step>
