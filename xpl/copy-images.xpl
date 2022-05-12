<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  xmlns:dbk="http://docbook.org/ns/docbook"
  version="1.0"
  name="tx-copy-images" 
  type="tx:copy-images">
  
  <p:documentation>
    This step is used to copy the images into the output directory 
    and patch the XML filerefs accordingly. 
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation>
      Expects a hub document
    </p:documentation>
  </p:input>
  <p:input port="params" primary="false">
    <p:documentation>
      Paths document
    </p:documentation>
  </p:input>
  <p:output port="result" primary="true">
    <p:documentation>
      Hub document with updated filerefs
    </p:documentation>
  </p:output>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri"/>
  <p:option name="fail-on-error" select="'true'"/>
  
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  
  <tr:dynamic-transformation-pipeline name="copy-images-and-patch-filerefs" 
                                      load="copy-images/copy-images"
                                      fallback-xpl="http://this.transpect.io/a9s/common/copy-images/copy-images.xpl">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="paths">
      <p:pipe port="params" step="tx-copy-images"/>
    </p:input>
    <p:input port="additional-inputs">
      <p:empty/>
    </p:input>
    <p:input port="options">
      <p:empty/>
    </p:input>
  </tr:dynamic-transformation-pipeline>
  
</p:declare-step>