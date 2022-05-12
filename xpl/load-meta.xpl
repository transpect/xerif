<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="tx-load-meta" 
  type="tx:load-meta">
  
  <p:documentation>
    This pipeline serves as wrapper for a tr:dynamic-transformation-pipeline 
    where you can specify your customer-specific metadata loading. The output of
    tr:dynamic-transformation-pipeline is expedted to be an hub info element 
    containing the metadata as DocBook representation.
  </p:documentation>
  
  <p:input port="source">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Expects a paths document
    </p:documentation>
  </p:input>
  
  <p:output port="result" primary="false" sequence="true">
    <p:documentation>
      The metadata file
    </p:documentation>
    <p:pipe port="result" step="load-meta-dyn"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:documentation>
      The report
    </p:documentation>
    <p:pipe port="report" step="load-meta-dyn"/>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <tr:dynamic-transformation-pipeline name="load-meta-dyn" 
                                      load="metadata/load-meta"
                                      fallback-xpl="http://this.transpect.io/a9s/common/metadata/load-meta.xpl">
    <p:input port="source">
      <p:pipe port="source" step="tx-load-meta"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="source" step="tx-load-meta"/>
    </p:input>
    <p:input port="options">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:dynamic-transformation-pipeline>
  
</p:declare-step>