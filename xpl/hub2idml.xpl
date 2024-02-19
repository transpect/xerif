<?xml version="1.0" encoding="utf-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"  
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:s="http://purl.oclc.org/dsdl/schematron"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tei2hub="http://transpect.io/tei2hub"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tx="http://transpect.io/xerif" 
  version="1.0"
  name="hub2idml"
  type="tx:hub2idml"
  >
    
  <p:input port="source" primary="true"><p:documentation>a Hub document</p:documentation></p:input>
  <p:input port="paths" primary="false"/>

  <p:option name="template" select="'xml2idml/template.idml'"/>
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" required="false" select="resolve-uri('debug')"/>
  <p:option name="status-dir-uri" required="false" select="resolve-uri('status')"/>
  <!-- the other options are contained in the paths params -->

  
  <p:output port="idmlval">
    <p:pipe port="result" step="idmlval"/>
  </p:output>
  <p:serialization port="idmlval" indent="true"/>
  
  <p:output port="idml" sequence="true">
    <p:pipe port="result" step="xml2idml"/>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl" />
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/xml2idml/xpl/xml2idml.xpl"/>
  <p:import href="http://transpect.io/idmlvalidation/xpl/idmlval.xpl" />

  <tr:simple-progress-msg name="hub2idml-start-msg" file="hub2idml-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting HUB to IDML conversion</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von HUB nach IDML</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>

  <tr:load-cascaded name="load-stylemap" filename="styles/stylemap.xsl">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="paths" step="hub2idml"/> 
    </p:input>
  </tr:load-cascaded>

  <p:xslt name="map-styles" initial-mode="docx2idml">
    <p:input port="source">
      <p:pipe port="source" step="hub2idml"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-stylemap"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="paths" step="hub2idml"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="styles/mapped-docx2idml">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <tr:xml2idml name="xml2idml" cx:depends-on="hub2idml-start-msg">
    <p:input port="paths">
      <p:pipe port="paths" step="hub2idml"/>
    </p:input>
    <p:with-option name="mapping" select="'xml2idml/mapping.xml'" />
    <p:with-option name="template" select="$template"/>
    <p:with-option name="idml-target-uri" select="/*/c:param[@name = 'idml-target-uri']/@value">
      <p:pipe port="paths" step="hub2idml"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
  </tr:xml2idml>
  
  <p:sink/>
  
  <p:choose name="idmlval" cx:depends-on="xml2idml">
    <p:when test="/*/c:param[@name = 'validate-idml']/@value = 'yes'">
      <p:xpath-context><p:pipe port="paths" step="hub2idml"/></p:xpath-context>
      <p:output port="result" primary="true">
        <p:pipe step="validate-idml" port="result"/>
      </p:output>
      
      <tr:idml-validation name="validate-idml" cx:depends-on="xml2idml">
        <p:with-option name="idmlfile" select="/*/c:param[@name = 'idml-target-uri']/@value">
          <p:pipe port="paths" step="hub2idml"/>
        </p:with-option>
        <p:with-option name="validate-regex" select="'designmap|Stories'"/> 
      </tr:idml-validation>
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true">
        <p:pipe step="bogo" port="result"/>
      </p:output>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>Option validate-idml: no</c:results>
          </p:inline>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  
  <p:sink/>
  
</p:declare-step>
