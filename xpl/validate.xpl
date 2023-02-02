<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="validate" 
  type="tx:validate">
  
  <p:documentation>
    Validates TEI with RelaxNG and Schematron and generates SVRL reports.
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation>
      Expects a TEI or BITS XML Document
    </p:documentation>
  </p:input>
  
  <p:input port="paths" primary="false"/>
  
  <p:input port="epub-file-uri" primary="false">
    <p:documentation>
      The EPUB file URI as provided by the 
      'result' port from epubtools. 
    </p:documentation>
  </p:input>
  
  <p:input port="schema" primary="false">
    <p:document href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"/>
  </p:input>

  <p:input port="hub" primary="false" sequence="true">
    <p:documentation>
      The hub file after copying images to allow checking on conversion errors
    </p:documentation>
  </p:input>
  
  <p:output port="result" primary="true"/>
  
  <p:output port="reports" primary="false" sequence="true">
    <p:pipe port="reports" step="validate-xml"/>
    <p:pipe port="result" step="validate-with-epubcheck"/>
    <p:pipe port="report" step="validate-hub"/>
  </p:output>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://transpect.io/epubcheck-idpf/xpl/epubcheck.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-rng.xpl"/>  
  
  <p:choose name="validate-xml">
    <p:when test="/*:TEI">
      <p:xpath-context>
        <p:pipe port="source" step="validate"/>
      </p:xpath-context>
      <p:output port="result" primary="true" />
      <p:output port="reports" sequence="true">
        <p:pipe port="report" step="validate-tei-schema"/>
        <p:pipe port="report" step="validate-business-rules"/>
      </p:output>
  
      <tr:validate-with-rng-svrl name="validate-tei-schema">
        <p:input port="schema">
          <p:pipe port="schema" step="validate"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:validate-with-rng-svrl>
  
      <tr:validate-with-schematron name="validate-business-rules">
        <p:input port="parameters">
          <p:pipe port="paths" step="validate"/>
        </p:input>
        <p:input port="html-in">
          <p:empty/>
        </p:input>
        <p:with-param name="family" select="'business-rules'"/>
        <p:with-param name="step-name" select="'validate-business-rules'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="schematron-rule-msg" select="'yes'"/>
      </tr:validate-with-schematron>
  
    </p:when>
    <p:when test="/*:hub or /*:book">
      <p:xpath-context>
        <p:pipe port="source" step="validate"/>
      </p:xpath-context>
      <p:output port="result" primary="true" />
      <p:output port="reports" sequence="true">
        <p:pipe port="report" step="validate-bits-schema"/>
        <p:pipe port="report" step="validate-bits-business-rules"/>
      </p:output>
      
      <tr:validate-with-schematron name="validate-bits-business-rules">
        <p:input port="parameters">
          <p:pipe port="paths" step="validate"/>
        </p:input>
        <p:input port="html-in">
          <p:empty/>
        </p:input>
        <p:with-param name="family" select="'bits-business-rules'"/>
        <p:with-param name="step-name" select="'validate-bits-business-rules'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="schematron-rule-msg" select="'yes'"/>
      </tr:validate-with-schematron>
      
      <p:delete match="@css:* | css:rules | @srcpath | @c:*"/>
      
      <tr:validate-with-rng-svrl name="validate-bits-schema">
        <p:input port="schema">
          <p:document href="http://jats.nlm.nih.gov/extensions/bits/2.0/rng/BITS-book2.rng"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:validate-with-rng-svrl>
      
    </p:when>
    <p:otherwise>
      <p:output port="result" primary="true" />
      <p:output port="reports" sequence="true">
        <p:pipe port="report" step="validate-business-rules"/>
      </p:output>
      
      <tr:validate-with-schematron name="validate-business-rules">
        <p:input port="parameters">
          <p:pipe port="paths" step="validate"/>
        </p:input>
        <p:input port="html-in">
          <p:empty/>
        </p:input>
        <p:with-param name="family" select="'business-rules'"/>
        <p:with-param name="step-name" select="'validate-business-rules'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="schematron-rule-msg" select="'yes'"/>
      </tr:validate-with-schematron>
    </p:otherwise>
  </p:choose>
  
  <tr:epubcheck-idpf name="validate-with-epubcheck">
    <p:with-option name="epubfile-path" select="/c:result/@os-path">
      <p:pipe port="epub-file-uri" step="validate"/>
    </p:with-option>
    <p:with-option name="interface" select="'commandline'"/>
    <!--<p:with-option name="epubcheck-version" select="'4.2.2'"/>--><!-- always use the latest version -->
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:epubcheck-idpf>

  <p:sink/>
  
  <tr:validate-with-schematron name="validate-hub">
    <p:input port="source">
      <p:pipe port="hub" step="validate"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="paths" step="validate"/>
    </p:input>
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:with-param name="family" select="'copy-images'"/>
    <p:with-param name="step-name" select="'copy-images'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="schematron-rule-msg" select="'yes'"/>
  </tr:validate-with-schematron>

</p:declare-step>