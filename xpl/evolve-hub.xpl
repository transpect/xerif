<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="tx-evolve-hub" 
  type="tx:evolve-hub">
    
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true"/>
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="validate-hub"/>
  </p:output>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="debug-indent" select="'false'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  
  <tr:dynamic-transformation-pipeline name="evolve-hub-dyn" 
                                      load="evolve-hub/driver-docx"
                                      fallback-xpl="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xpl"
                                      fallback-xsl="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl">
    <p:input port="source">
      <p:pipe port="source" step="tx-evolve-hub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="parameters" step="tx-evolve-hub"/>
    </p:input>
    <p:input port="options">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:dynamic-transformation-pipeline>
  
  <tr:validate-with-schematron name="validate-hub">
    <p:input port="parameters">
      <p:pipe port="parameters" step="tx-evolve-hub"/>
    </p:input>
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:with-param name="family" select="'formatting'"/>
    <p:with-param name="step-name" select="'validate-formatting'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="schematron-rule-msg" select="'yes'"/>
  </tr:validate-with-schematron>
  
</p:declare-step>