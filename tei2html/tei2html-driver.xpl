<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="tei2html-driver"
  >
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" />
  
  <p:input port="source" primary="true"/>
  <p:input port="meta" sequence="false" primary="false"/>
  <p:input port="boilerplate" sequence="false" primary="false">
    <p:empty/>
  </p:input>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:input port="stylesheet"/>
  <p:output port="result" primary="true"/>
  <p:output port="report" sequence="true">
    <p:pipe port="report" step="epub-alternatives"/>
    <p:pipe port="report" step="tei2html"/>
    <p:pipe port="report" step="clean-up"/>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  
  <tr:xslt-mode prefix="tei2html/02" mode="epub-alternatives" name="epub-alternatives">
    <p:input port="source">
      <p:pipe step="tei2html-driver" port="source"/>
      <p:pipe step="tei2html-driver" port="meta"/>
      <p:pipe step="tei2html-driver" port="boilerplate"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:input port="stylesheet"><p:pipe step="tei2html-driver" port="stylesheet"/></p:input>
    <p:with-option name="debug" select="$debug"><p:empty/></p:with-option>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"><p:empty/></p:with-option>
  </tr:xslt-mode>
  
  <p:sink/>

  <tr:xslt-mode prefix="tei2html/05" mode="tei2html" name="tei2html">
    <p:input port="source">
      <p:pipe step="epub-alternatives" port="result"/>
      <p:pipe step="tei2html-driver" port="meta"/>
      <p:pipe step="tei2html-driver" port="boilerplate"/>
    </p:input>
    <p:input port="stylesheet"><p:pipe step="tei2html-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"><p:empty/></p:with-option>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"><p:empty/></p:with-option>
  </tr:xslt-mode>

  <tr:xslt-mode prefix="tei2html/20" mode="clean-up" name="clean-up">
    <p:input port="source">
      <p:pipe step="tei2html" port="result"/>
      <p:pipe step="tei2html-driver" port="meta"/>
      <p:pipe step="tei2html-driver" port="boilerplate"/>
    </p:input>
    <p:input port="stylesheet"><p:pipe step="tei2html-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"><p:empty/></p:with-option>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"><p:empty/></p:with-option>
  </tr:xslt-mode>
  
</p:declare-step>
