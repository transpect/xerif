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
  name="customer-outputs"
  type="tx:customer-outputs">

  <p:input port="source" primary="true"><p:documentation>a TEI document</p:documentation></p:input>
  <p:input port="params" primary="false">
    <p:documentation>
      Paths document
    </p:documentation>
  </p:input>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="status-dir-uri" required="false" select="resolve-uri('status')"/>
  <!-- the other options are contained in the paths params -->

  <p:output port="result" sequence="true"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>

  <tr:dynamic-transformation-pipeline name="execute-customer-specific-conversion" 
                                      load="additional-outputs/additional-outputs"
                                      fallback-xpl="http://this.transpect.io/a9s/common/additional-outputs/additional-outputs.xpl">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="paths">
      <p:pipe port="params" step="customer-outputs"/>
    </p:input>
    <p:input port="additional-inputs">
      <p:empty/>
    </p:input>
    <p:input port="options">
      <p:empty/>
    </p:input>
  </tr:dynamic-transformation-pipeline>

</p:declare-step>