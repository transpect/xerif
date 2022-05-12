<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tr="http://transpect.io"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  version="1.0"
  name="hub2tei-driver">
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" />
  
  <p:input port="source" primary="true"/>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:input port="stylesheet"/>
  <p:output port="result" primary="true">
    <p:pipe port="result" step="tidy"/>
  </p:output>
  <p:output port="report" sequence="true">
    <p:pipe port="report" step="cals2html-table"/>
    <p:pipe port="report" step="dbk2tei"/>
    <p:pipe port="report" step="tidy"/>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-xml-model.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:identity name="create-model">
    <p:input port="source">
      <p:inline>
        <c:models>
          <c:model href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa_docbook-like-divs.nvdl"
            type="application/xml" schematypens="http://purl.oclc.org/dsdl/nvdl/ns/structure/1.0"/>
          <!--<c:model href="http://www.le-tex.de/resource/schema/tei-cssa/tei/tei_allPlus.rng"
            type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"/>-->            
        </c:models>
      </p:inline>
    </p:input>
  </p:identity>
  
  <p:sink/>
  
  <tr:xslt-mode msg="yes" prefix="hub2tei/20" mode="cals2html-table" name="cals2html-table">
    <p:input port="source"><p:pipe port="source" step="hub2tei-driver"></p:pipe></p:input>
    <p:input port="stylesheet"><p:pipe step="hub2tei-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" prefix="hub2tei/40" mode="hub2tei:dbk2tei" name="dbk2tei">
    <p:input port="stylesheet"><p:pipe step="hub2tei-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" prefix="hub2tei/99" mode="hub2tei:tidy" name="tidy">
    <p:input port="stylesheet"><p:pipe step="hub2tei-driver" port="stylesheet"/></p:input>
    <p:input port="models"><p:pipe step="create-model" port="result"/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:xslt-mode>
  
  <p:sink/>
  
 </p:declare-step>