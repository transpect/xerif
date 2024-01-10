<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="generate-xmp">
  
  <p:documentation>
    Wraps source and metadata document together and generate XMP file from it.
  </p:documentation>
  
  <p:input port="source" primary="true"/>
  <p:input port="stylesheet"/>
  <p:input port="parameters"/>
  <p:input port="options"/>
  <p:output port="result"/>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:wrap-sequence wrapper-prefix="cx" wrapper="documents" wrapper-namespace="http://xmlcalabash.com/ns/extensions"/>
  
  <tr:store-debug name="debug-before-generate-xmp" pipeline-step="generate-xmp/02_input">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:xslt name="generate-xmp-xsl">
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="generate-xmp"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="parameters" step="generate-xmp"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug name="debug-after-generate-xmp" pipeline-step="generate-xmp/04_final">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>