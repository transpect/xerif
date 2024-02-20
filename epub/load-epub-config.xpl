<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pos="http://exproc.org/proposed/steps/os"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="load-epub-config">
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Metadata document
    </p:documentation>
  </p:input>
  
  <p:input port="stylesheet" primary="false"/>
  
  <p:input port="parameters" kind="parameter" primary="true"/>
  
  <p:input port="htmltemplates" sequence="true">
     <p:documentation>htmltemplates document</p:documentation>
  </p:input>

  <p:output port="result" primary="true" sequence="true">
    <p:documentation>
      The patched epub-config document
    </p:documentation>
  </p:output>
  
  <p:option name="basename" select="''"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <tr:load-cascaded name="load-epub-config-template" 
                    filename="epub/epub-config.xml" 
                    fallback="http://this.transpect.io/a9s/common/epub/epub-config.xml">
    <p:input port="paths">
      <p:pipe port="parameters" step="load-epub-config"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
  
  <p:xslt name="populate-epub-config-template">
    <p:input port="source">
      <p:pipe port="result" step="load-epub-config-template"/>
      <p:pipe port="source" step="load-epub-config"/>
      <p:pipe port="htmltemplates" step="load-epub-config"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="load-epub-config"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
</p:declare-step>