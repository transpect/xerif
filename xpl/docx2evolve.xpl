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
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="docx2evolve" 
  type="tx:docx2evolve">
  
  <p:input port="source" primary="true" sequence="true"/>
  
  <p:input port="meta" primary="false" sequence="true"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="insert-meta"/>
  </p:output>
  
  <p:output port="hub-flat" primary="false">
    <p:pipe port="result" step="docx2hub"/>
  </p:output>

  <p:output port="hub-rich" primary="false">
    <p:pipe port="result" step="evolve-hub-dyn"/>
  </p:output>
  
  <p:output port="report" sequence="true">
    <p:pipe port="report" step="docx2hub"/>
    <p:pipe port="report" step="check-styles"/>
    <p:pipe port="report" step="evolve-hub-dyn"/>
  </p:output>
  
  <p:serialization port="hub-flat" indent="true"/>
  <p:serialization port="hub-rich" indent="true"/>
  
  <p:option name="file" required="true"/>
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/check-styles.xpl"/>
  
  <p:import href="evolve-hub.xpl"/>
  <p:import href="copy-images.xpl"/>
  
  <docx2hub:convert name="docx2hub" mml-space-handling="xml-space" srcpaths="yes" >
    <p:with-option name="docx" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="mathtype2mml" select="'yes'"/>
  </docx2hub:convert>
  
  <tr:check-styles name="check-styles">
    <p:input port="parameters">
      <p:pipe port="source" step="docx2evolve"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="cssa" select="'styles/cssa.xml'"/>
    <p:with-option name="differentiate-by-style" select="'true'"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:check-styles>     
  
  <tx:evolve-hub name="evolve-hub-dyn">
    <p:input port="parameters">
      <p:pipe port="source" step="docx2evolve"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:evolve-hub>
  
  <tx:copy-images name="copy-images-and-patch-filerefs">
    <p:input port="params">
      <p:pipe port="source" step="docx2evolve"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:copy-images>
  
  <tx:insert-meta name="insert-meta">
    <p:input port="meta">
      <p:pipe port="meta" step="docx2evolve"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="source" step="docx2evolve"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:insert-meta>
  
</p:declare-step>