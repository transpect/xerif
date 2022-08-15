<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  xmlns:dbk="http://docbook.org/ns/docbook"
  version="1.0"
  name="tx-insert-meta"
  type="tx:insert-meta">
  
  <p:documentation>
    This step transforms the metadata to hub and inserts it 
    into the source document.
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
  
  <p:input port="meta" primary="false">
    <p:documentation>
      Your arbitrary metadata file
    </p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation>
      The hub document with the metadata inserted
    </p:documentation>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <tr:load-cascaded name="load-meta-xsl" filename="metadata/metadata2hub.xsl">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="params" step="tx-insert-meta"/>
    </p:input>
  </tr:load-cascaded>
  
  <tr:store-debug pipeline-step="metadata/07_metadata2hub.xsl" extension="xsl">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:xslt name="metadata2hub">
    <p:input port="source">
      <p:pipe port="meta" step="tx-insert-meta"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-meta-xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="params" step="tx-insert-meta"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="metadata/08_metadata2hub">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:sink/>
  
  <p:insert match="/dbk:hub/dbk:info" position="last-child">
    <p:input port="source">
      <p:pipe port="source" step="tx-insert-meta"/>
    </p:input>
    <p:input port="insertion" select="/dbk:info/cx:documents/*">
      <p:pipe port="result" step="metadata2hub"/>
    </p:input>
  </p:insert>
  
  <tr:store-debug pipeline-step="metadata/12_metadata-inserted">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>