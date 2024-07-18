<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
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
    <p:pipe port="report" step="validate-hub"/>
    <p:pipe port="reports" step="validate-xml"/>
    <p:pipe port="result" step="validate-with-epubcheck"/>
    <p:pipe port="result" step="a11y-check"/>
  </p:output>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:import href="http://transpect.io/ace-daisy/xpl/ace.xpl"/>
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
    <p:when test="/book or /article">
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
        <p:with-param name="family" select="'bits'"/>
        <p:with-param name="step-name" select="'validate-bits'"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
        <p:with-option name="schematron-rule-msg" select="'yes'"/>
      </tr:validate-with-schematron>
      
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
        <p:pipe port="report" step="validate-docbook"/>
      </p:output>
      
      <tr:validate-with-schematron name="validate-docbook">
        <p:input port="parameters">
          <p:pipe port="paths" step="validate"/>
        </p:input>
        <p:input port="html-in">
          <p:empty/>
        </p:input>
        <p:with-param name="family" select="'dbk'"/>
        <p:with-param name="step-name" select="'validate-dbk'"/>
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
  
  <p:choose name="a11y-check" cx:depends-on="validate-with-epubcheck">
    <p:variable name="epub-is-valid" select="not(/*:schematron-output/*:failed-assert/@role[. = ('error', 'fatal-error')])"/>
    <p:variable name="run-a11y-check" select="exists(/c:param-set/c:param[@name = 'epub-a11y-check'][@value eq 'yes'])">
      <p:pipe port="paths" step="validate"/>
    </p:variable>
    <p:documentation>
      Install NodeJS and run npm install <code xmlns="http://www.w3.org/1999/xhtml">@daisy/ace -g</code>
      to install ACE on your system. Add the parameter $epub-a11y-check with value 'yes' 
      to your transpect configuration to run this step.
    </p:documentation>
    <p:when test="$epub-is-valid = 'true' and $run-a11y-check = 'true'">
      <p:output port="result"/>
      
      <tr:ace-daisy name="run-ace">
        <p:with-option name="href" select="/c:result/@os-path">
          <p:pipe port="epub-file-uri" step="validate"/>
        </p:with-option>
        <p:with-option name="ace" select="/c:param-set/c:param[@name = 'epub-a11y-ace-path']/@value">
          <p:pipe port="paths" step="validate"/>
        </p:with-option>
        <p:with-option name="rule-family-name" select="/c:param-set/c:param[@name = 'epub-a11y-rule-family-name']/@value">
          <p:pipe port="paths" step="validate"/>
        </p:with-option>
        <p:with-option name="a11y-htmlreport" select="/c:param-set/c:param[@name = 'epub-a11y-htmlreport']/@value">
          <p:pipe port="paths" step="validate"/>
        </p:with-option>
        <p:with-option name="severity-override" select="/c:param-set/c:param[@name = 'epub-a11y-severity-override']/@value">
          <p:pipe port="paths" step="validate"/>
        </p:with-option>
        <p:with-option name="lang" select="$interface-language"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      </tr:ace-daisy>
      
    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity>
        <p:input port="source">
          <p:inline>
            <c:not-applicable tr:step-name="accessibility" tr:rule-family="accessibility">
              <c:info>accessibility check is inactive.</c:info>
            </c:not-applicable>
          </p:inline>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>

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
