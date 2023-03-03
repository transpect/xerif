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
  
  <p:output port="tex" primary="false">
    <p:pipe port="result" step="hub2tex"/>
  </p:output>
  

  <p:serialization port="tex" method="text" media-type="text/plain" encoding="utf8"/>
   
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
  
  <p:option name="file-ext" select="'meta.xml'"/>

  <p:option name="create-idml" required="false" select="'no'"/>
  <p:option name="idml-target-uri"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
   <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <p:import href="get-paths.xpl"/>
  <p:import href="evolve-hub.xpl"/>
  <p:import href="htmlreport.xpl"/>
  <p:import href="insert-meta.xpl"/>
  <p:import href="load-meta.xpl"/>
  <p:import href="xml2tex.xpl"/>

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

  <p:load name="load-hub-skeleton" href="http://this.transpect.io/a9s/ts/assets/ts_title.hub.flat.xml" dtd-validate="false"/>

  <tx:insert-meta name="insert-meta"  cx:depends-on="load-hub-skeleton">
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
  
  <tx:xml2tex name="hub2tex">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:xml2tex>
  
  <p:sink/>
  
 
</p:declare-step>
