<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils" 
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:s="http://purl.oclc.org/dsdl/schematron" 
  xmlns:hub2htm="http://transpect.io/hub2htm" 
  xmlns:idml2xml="http://transpect.io/idml2xml"
  xmlns:epub="http://transpect.io/epubtools" 
  xmlns:tr="http://transpect.io"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0" 
  name="idml2epub">

  <p:input port="params" primary="true"/>
  
  <p:input port="schema" primary="false">
    <p:document href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"/>
  </p:input>

  <p:option name="file" required="true"/>
  <p:option name="all-styles" required="false" select="'no'"/>
  <!-- Schematron checks? -->
  <p:option name="check" required="false" select="'yes'"/>
  <p:option name="local-css" required="false" select="'false'"/>
  <p:option name="epub-check-http-resources" required="false" select="'false'">
    <p:documentation>true/false override for conf param with same name. Made this configurable separately
    because link checking takes so much time.</p:documentation>
  </p:option>

  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  <p:option name="rule-category-span-class" select="'category'" required="false"/>
  <p:option name="progress" required="false" select="'yes'"/>
  <p:option name="testset-only" select="'no'">
    <p:documentation>Whether only one metadata set (i.e., no secondary port) should be returned by the metadata normalizer.</p:documentation>
  </p:option>
  <p:option name="extract" required="false" select="''">
    <p:documentation>see tei2epub.xpl</p:documentation>
  </p:option>
  <p:option name="toc-levels" required="false" select="''">
    <p:documentation>parameter to determine toc depth</p:documentation>
  </p:option>
	<p:option name="testdata-format" required="false" select="'epub'">
		<p:documentation>Stores epub-schematron or output from tei2html to diff for ci tests. The value for epub-schematron is 'epub'.</p:documentation>
	</p:option>
	<p:option name="export-chunks" required="false" select="no">
		<p:documentation>Whether to create Chunks from articles etc.</p:documentation>
	</p:option>

  <p:output port="hub-flat" primary="false">
    <p:pipe port="result" step="idml2hub"/>
  </p:output>
  <p:serialization port="hub-flat" omit-xml-declaration="false"/>

  <p:output port="paths">
    <p:pipe port="result" step="get-paths"/>
  </p:output>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="remove-srcpaths"/>
  </p:output>

  <p:output port="html" sequence="true">
    <p:pipe port="html" step="tei2epub"/>
  </p:output>  
  
  <p:output port="htmlreport" sequence="true">
    <p:pipe port="result" step="htmlreport"/>
  </p:output>
  <p:serialization port="htmlreport" omit-xml-declaration="false"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/idml2xml/xpl/idml2hub.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/hub2tei/xpl/hub2tei.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/check-styles.xpl"/>
  <p:import href="get-paths.xpl"/>
  <p:import href="tei2epub.xpl"/>
  <p:import href="load-meta.xpl"/>
  <p:import href="validate.xpl"/>
  <p:import href="htmlreport.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl" />
  <p:import href="export-chunks.xpl"/>  
  <p:import href="customer-outputs.xpl"/>

  <tr:resolve-params name="resolve-params"/>

  <p:in-scope-names name="expand-options-as-params"/>
  
  <p:insert match="/c:param-set" position="last-child" name="consolidate-params">
    <p:input port="source">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:input port="insertion" select="//c:param">
      <p:pipe port="result" step="expand-options-as-params"/>
    </p:input>
  </p:insert>
  
  <p:string-replace name="start-msg-replace" match="file">
    <p:with-option name="replace" select="concat('''', replace($file, '^.+/', ''), '''')"/>
    <p:input port="source">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">////////// Starting idml2tei2epub conversion of <file/> \\\\\\\\\\</c:message>
          <c:message xml:lang="de">////////// Beginne idml2tei2epub-Konvertierung von <file/> \\\\\\\\\\</c:message>
        </c:messages>
      </p:inline>
    </p:input>
  </p:string-replace>
  
  <tr:simple-progress-msg name="start-msg" file="idml2epub-start.txt">
    <p:input port="msgs">
      <p:pipe port="result" step="start-msg-replace"/>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  <p:sink/>
  
  <tr:file-uri name="normalize-filename">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <tx:get-paths name="get-paths">
    <p:input port="params">
      <p:pipe port="result" step="consolidate-params"/>
    </p:input>
    <p:with-option name="file" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:get-paths>
  
  <tx:load-meta name="load-meta-wrapper">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:load-meta>


  <idml2xml:hub name="idml2hub" cx:depends-on="load-meta-wrapper">
    <p:with-option name="srcpaths" select="'yes'"/>
    <p:with-option name="all-styles" select="$all-styles"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="idmlfile" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
  </idml2xml:hub>
  
  <p:sink/>

  <tr:load-cascaded name="load-stylemap" filename="styles/stylemap.xsl">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
    <p:pipe port="result" step="get-paths"/> 
    </p:input>
  </tr:load-cascaded>

  <p:xslt name="map-styles" initial-mode="idml2docx">
    <p:input port="source">
      <p:pipe port="result" step="idml2hub"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-stylemap"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="styles/mapped-idml2docx">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <hub:evolve-hub name="evolve-hub" cx:depends-on="map-styles" load="evolve-hub/driver-idml">
    <p:input port="source">
      <p:pipe port="result" step="map-styles"/> 
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub:evolve-hub>
  
  <hub2tei:hub2tei name="hub2tei" cx:depends-on="evolve-hub">
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub2tei:hub2tei>

  <p:delete match="@srcpath" name="remove-srcpaths"/>

  <p:sink/>

  <p:choose name="customer-outputs" cx:depends-on="hub2tei">
    <p:when test="/*/c:param[@name = 'customer-outputs']/@value[. = ('bits', 'jats')]">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:customer-outputs name="custom-output" >
        <p:input port="source">
          <p:pipe port="result" step="hub2tei"/>
        </p:input>
        <p:input port="params">
          <p:pipe port="result" step="get-paths"/>
        </p:input>
        <p:with-option name="debug" select="$debug" />
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:customer-outputs>
      <p:sink/>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>Option create-customer-outputx: no</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink/>
    </p:otherwise>  
  </p:choose>

  <tx:tei2epub name="tei2epub">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:with-option name="out-dir-uri" select="$out-dir-uri"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:tei2epub>

  <p:sink/>
  
  <tr:store-debug name="store-tei" pipeline-step="difftest/out-tei">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
    <p:with-option name="indent" select="true()"/>
  </tr:store-debug>

  <tr:store-debug pipeline-step="difftest/out-html" extension="xhtml">
    <p:input port="source">
      <p:pipe step="tei2epub" port="html"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <p:group name="schematron-validation">
    <p:output port="reports" sequence="true">
      <p:pipe port="report" step="sch_idml"/>
      <p:pipe port="report" step="sch_flat-hub"/>
      <p:pipe port="report" step="check-styles"/>
    </p:output>
    
    <tr:validate-with-schematron name="sch_idml">
      <p:input port="source">
        <p:pipe port="DocumentStoriesSorted" step="idml2hub"/>
      </p:input>
      <p:input port="html-in">
        <p:empty/>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="get-paths"/>
      </p:input>
      <p:with-param name="family" select="'idml'"/>
      <p:with-param name="step-name" select="'sch_idml2hub_dss'"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      <p:with-option name="active" select="$check"/>
    </tr:validate-with-schematron>
    
    <p:sink/>
    
    <tr:check-styles name="check-styles">
      <p:input port="source">
        <p:pipe port="result" step="map-styles"/>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="get-paths"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="cssa" select="'styles/cssa-idml.xml'"/>
      <p:with-option name="differentiate-by-style" select="'true'"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    </tr:check-styles>
    
    <p:sink/>
    
    <tr:validate-with-schematron name="sch_flat-hub">
      <p:input port="source">
        <p:pipe port="result" step="map-styles"/>
      </p:input>
      <p:input port="html-in">
        <p:empty/>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="get-paths"/>
      </p:input>
      <p:with-param name="family" select="'flat-hub'"/>
      <p:with-param name="step-name" select="'sch_flat-hub'"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    </tr:validate-with-schematron>
    
  <p:sink/>

  </p:group>

  <p:sink/>

  <tx:validate name="validate">
    <p:input port="source">
      <p:pipe port="result" step="hub2tei"/>
    </p:input>
    <p:input port="schema">
      <p:pipe port="schema" step="idml2epub"/>
    </p:input>
    <p:input port="hub">
      <p:pipe port="result" step="evolve-hub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="epub-file-uri">
      <p:pipe port="result" step="tei2epub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:validate>

  <p:sink/>

  <tx:htmlreport name="htmlreport">
    <p:input port="source">
      <p:pipe port="html" step="tei2epub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="reports">
      <p:pipe port="report" step="idml2hub"/>
      <p:pipe port="report" step="hub2tei"/>
      <p:pipe port="report" step="evolve-hub"/>
      <p:pipe port="reports" step="validate"/>
      <p:pipe port="reports" step="schematron-validation"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:htmlreport>

  <p:sink/>

  <p:string-replace name="success-msg-replace" match="file">
    <p:with-option name="replace" select="concat('''', replace($file, '^.+/', ''), '''')"/>
    <p:input port="source">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">\\\\\\\\\\ Successfully finished idml2tei2epub conversion of <file/> //////////</c:message>
          <c:message xml:lang="de">\\\\\\\\\\ idml2tei2epub-Konvertierung von <file/> erfolgreich abgeschlossen //////////</c:message>
        </c:messages>
      </p:inline>
    </p:input>    
  </p:string-replace>
  
  <tr:simple-progress-msg name="success-msg" file="idml2epub-success.txt" cx:depends-on="htmlreport">
    <p:input port="msgs">
      <p:pipe port="result" step="success-msg-replace"/>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>
  
  <p:choose name="split-html">
    <p:when test="/*/c:param[@name = 'export-chunks']/@value = 'yes'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:export-chunks>
        <p:input port="source">
          <p:pipe port="html" step="tei2epub"/>
        </p:input>
        <p:input port="tei">
          <p:pipe port="result" step="hub2tei"/>
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:export-chunks>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>do not chunk html</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink  name="s4"/>
    </p:otherwise>  
  </p:choose>


</p:declare-step>