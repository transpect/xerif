<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="tx-xml2tex"
  type="tx:xml2tex">
  
  <p:input port="source" primary="true">
    <p:documentation>
      Hub document
    </p:documentation>
  </p:input>
  
  <p:input port="params" primary="false">
    <p:documentation>
      Paths document
    </p:documentation>
  </p:input>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:serialization port="result" method="text" media-type="text/plain" encoding="utf8"/>
  
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xml2tex/xpl/xml2tex.xpl"/>
  
  <tr:load-cascaded name="load-latex-conf" filename="xml2tex/latex.conf.xml">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
  </tr:load-cascaded>
  
  <p:sink/>
  
  <xml2tex:convert name="hub2tex">
    <p:documentation>Converts the hub XML to TeX according to the xml2tex configuration file.</p:documentation>
    <p:input port="source">
      <p:pipe port="source" step="tx-xml2tex"/>
    </p:input>
    <p:input port="conf">
      <p:pipe port="result" step="load-latex-conf"/>     
    </p:input>
    <p:input port="paths">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="collect-all-xsl" select="(/c:param-set/c:param[@name eq 'collect-all-xsl']/@value, 'yes')[1]">
      <p:pipe port="params" step="tx-xml2tex"/>
      <p:documentation>collect all xsl templates from config. important if you work with several modes for the same elements. 
                       should be yes if common framework latex is used</p:documentation>
    </p:with-option>
  </xml2tex:convert>
  
</p:declare-step>
