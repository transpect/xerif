<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="htmlreport" 
  type="tx:htmlreport">
  
  <p:documentation>
    Converts TEI XML to HTML and creates an HTML report with existing
    SVRL reports.
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation>
      Expects an HTML Document
    </p:documentation>
  </p:input>
  
  <p:input port="paths" primary="false"/>
  
  <p:input port="reports" primary="false" sequence="true"/>

  <p:output port="result" primary="true"/>
    
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://transpect.io/htmlreports/xpl/patch-svrl.xpl"/>
  
  <tr:patch-svrl name="report">
    <p:input port="reports">
      <p:pipe port="reports" step="htmlreport"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="paths" step="htmlreport"/>
    </p:input>
    <p:with-option name="report-title" select="'report'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:patch-svrl>
 
</p:declare-step>