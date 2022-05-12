<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="load-meta">
  
  <p:documentation>
    Loads an onix file which is expected to be stored 
    in the content repository with the same basename as
    the source file.
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      Expects a paths document
    </p:documentation>
  </p:input>
  
  <p:input port="stylesheet" primary="false"/>
  
  <p:input port="parameters" kind="parameter" primary="true"/>
  
  <p:output port="result" primary="true" sequence="true">
    <p:documentation>
      The metadata file or empty
    </p:documentation>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths-for-files-xml.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>

  <!-- Determine paths for ONIX document in content repository. 
       It is expected that ONIX file has the same basename as the source file. -->
  
  <tr:paths-for-files-xml name="get-metadata-path">
    <p:input port="conf">
      <p:document href="http://this.transpect.io/conf/transpect-conf.xml"/>
    </p:input>
    <p:with-option name="filenames" select="concat(/c:param-set/c:param[@name eq 'basename']/@value, '.onix.xml')"/>
  </tr:paths-for-files-xml>
  
  <tr:store-debug pipeline-step="metadata/02_path">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:try>
    <p:group>
      
      <p:load name="load-onix">
        <p:with-option name="href" select="/c:files/c:file/@name"/>
      </p:load>
      
    </p:group>
    <p:catch>
      
      <p:load name="load-fallback">
        <p:with-option name="href" select="'fallback.onix.xml'"/>
      </p:load>
      
    </p:catch>
  </p:try>
  
  <tr:store-debug pipeline-step="metadata/04_metadata-loaded">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>
