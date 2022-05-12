<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="get-paths"
  type="tx:get-paths">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>Generate clades document from recursive directory listing and 
    evaluate matching clades for input file.</p>
  </p:documentation>
  
  <p:input port="params">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>params</dt><dd>expects a c:param-set document</dd></dl>
    </p:documentation>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>result</dt><dd>provides the paths document</dd></dl>
    </p:documentation>  
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>report</dt><dd>provides an document with error messages</dd></dl>
    </p:documentation>
  </p:output>
  
  <p:option name="file" required="true"/>
  
  <p:option name="debug"/>
  <p:option name="debug-dir-uri"/>  
  <p:option name="status-dir-uri"/>

  <!--  *
        * import xproc modules
        * -->
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/get-clades-from-dirs.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>

  <tr:simple-progress-msg file="paths.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Evaluate cascade config</c:message>
          <c:message xml:lang="de">Ermittle Kaskadierende Konfiguration</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <!-- construct transpect clades configuration from directory cascade -->
  
  <cx:message>
    <p:input port="source">
      <p:pipe port="params" step="get-paths"/>
    </p:input>
    <p:with-option name="message" select="'[info] get clades from dirs'"/>
  </cx:message>
  
  <tr:get-clades-from-dirs name="clades">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>    
  </tr:get-clades-from-dirs>
  
  <!-- paths-for-files for svnifiy needs a static conf -->
  
  <p:store include-content-type="true">
    <p:with-option name="href" select="'../../../conf/conf.xml'"/>
  </p:store>
  
  <!-- load XSLT and perform paths step to determine matching clades from file name 
   and generate a parameter set -->

  <p:identity cx:depends-on="clades">
    <p:input port="source">
      <p:pipe port="result" step="clades"/>
    </p:input>
  </p:identity>
  
  <cx:message>
    <p:with-option name="message" select="'[info] load paths document: ', /tr:conf/@paths-xsl-uri"/>
  </cx:message>
  
  <p:load name="import-paths-xsl">
    <p:with-option name="href" select="/tr:conf/@paths-xsl-uri"/>
  </p:load>
  
  <cx:message>
    <p:with-option name="message" select="'[info] get paths'"/>
  </cx:message>
      
  <p:sink/>  
  
  <tr:paths name="paths" cx:depends-on="import-paths-xsl">
    <p:with-option name="file" select="$file"/>
    <p:with-option name="determine-transpect-project-version" select="'no'"/>
    <p:with-option name="debug" select="$debug"/>  
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:input port="stylesheet">
      <p:pipe port="result" step="import-paths-xsl"/>
    </p:input>
    <p:input port="conf">
      <p:pipe port="result" step="clades"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="params" step="get-paths"/>
    </p:input>
  </tr:paths>
      
  <tr:store-debug pipeline-step="get-paths/08.param-set-including-paths">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>
