<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tei2hub="http://transpect.io/tei2hub"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tx="http://transpect.io/xerif" 
  version="1.0"
  name="export-chunks"
  type="tx:export-chunks"
  >
    
  <p:input port="source" primary="true"><p:documentation>an XHTML document</p:documentation></p:input>
  <p:input port="tei" primary="false"><p:documentation>a TEI document to easily extract metadata information</p:documentation></p:input>
  <p:input port="paths" primary="false"/>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="status-dir-uri" required="false" select="resolve-uri('status')"/>
  <!-- the other options are contained in the paths params -->

<!--  <p:output port="result" sequence="true"/>-->

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/xproc-util/html-embed-resources/xpl/html-embed-resources.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>

  <tr:simple-progress-msg name="hub2idml-start-msg" file="hub2idml-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting to chunk HTML</c:message>
          <c:message xml:lang="de">Beginne Splitting von HTML-Chunks</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>

    <tr:load-cascaded name="html-postprocess-stylesheet" filename="tei2html/postprocess-html-for-chunks.xsl">
      <p:input port="paths">
        <p:pipe port="paths" step="export-chunks"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="required" select="'no'"/>
    </tr:load-cascaded>

  <p:sink/>

    <p:xslt name="postprocess-html">
      <p:documentation>Adds some changes to the HTML (metatags, chunk base-uris etc.)</p:documentation>
      <p:input port="source">
        <p:pipe port="source" step="export-chunks"/>
        <p:pipe port="tei" step="export-chunks"><p:documentation>add TEI to extract meta informations more easily</p:documentation></p:pipe>
      </p:input>
      <p:input port="stylesheet">
        <p:pipe port="result" step="html-postprocess-stylesheet"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-param name="s9y1-path" select="/c:param-set/c:param[@name eq 's9y1-path']/@value">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
      <p:with-param name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
      <p:with-param name="out-dir-uri" select="replace(/c:param-set/c:param[@name eq 'out-dir-uri']/@value, '/(docx|idml)$', '')">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
    </p:xslt>
    
    <tr:store-debug name="store-postprocessed-html" pipeline-step="tei2html/99-postprocessed">
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
      <p:with-option name="indent" select="true()"/>
    </tr:store-debug>

    <p:xslt name="split-html-articles" initial-mode="export">
      <p:documentation>creates chunks from HTML</p:documentation>
      <p:input port="stylesheet">
        <p:pipe port="result" step="html-postprocess-stylesheet"/>
      </p:input>
      <p:input port="parameters">
        <p:empty/>
      </p:input>
      <p:with-param name="s9y1-path" select="/c:param-set/c:param[@name eq 'file']/@value">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
      <p:with-param name="basename" select="/c:param-set/c:param[@name eq 'basename']/@value">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
      <p:with-param name="out-dir-uri" select="replace(/c:param-set/c:param[@name eq 'out-dir-uri']/@value, '/(docx|idml)$', '')">
        <p:pipe port="paths" step="export-chunks"/>
      </p:with-param>
    </p:xslt>

    <p:sink/>

  <p:for-each name="splitting-html">
    <p:iteration-source>
      <p:pipe port="secondary" step="split-html-articles"/>
    </p:iteration-source>
    
    <!--      <tr:html-embed-resources fail-on-error="false" unavailable-resource-message="yes">
      <p:input port="catalog">
      <p:document href="../../../xmlcatalog/catalog.xml"/>
      </p:input>
      </tr:html-embed-resources>
    -->
    <p:choose>
      <p:when test="ends-with(base-uri(), 'html')">
        <p:store include-content-type="true" name="export" indent="true" omit-xml-declaration="false" method="html" version="5.0">
          <p:with-option name="href" select="base-uri()"/>
        </p:store>
      </p:when>
      <p:otherwise>
        <p:store include-content-type="true" name="export" indent="true" omit-xml-declaration="false" method="xml">
          <p:with-option name="href" select="base-uri()"/>
        </p:store>
      </p:otherwise>
    </p:choose>
  </p:for-each>

<!--  <p:sink  name="s5"/>-->
  
</p:declare-step>
