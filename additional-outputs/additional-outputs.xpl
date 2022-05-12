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
  name="customer-output">

  <p:input port="source" primary="true"/>
  <p:input port="stylesheet">
    <p:empty/>
  </p:input>
  <p:input port="parameters"/>
  <p:input port="options">
    <p:empty/>
  </p:input>
  <p:output port="result" sequence="true">
    <p:pipe port="result"  step="identity"/>
  </p:output>

  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri"/>
  <!-- the other options are contained in the paths params -->

  <p:identity name="identity">
    <p:input port="source">
      <p:pipe port="source" step="customer-output"/>
    </p:input>
  </p:identity>

  <p:sink/>

</p:declare-step>