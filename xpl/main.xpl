<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:docx2hub="http://transpect.io/docx2hub"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:tei2hub="http://transpect.io/tei2hub"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="main" 
  type="tx:main">
  
  <p:documentation>
    Demo Conversion Pipeline.
    Possible Inputs: Docx, BITS or TEI
    Possible Outputs: LaTex, EPUB, IDML, BITS, TEI, HUB    
  </p:documentation>
  
  <p:input port="conf" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <p>See the section on <a
          href="https://subversion.le-tex.de/common/transpect-demo/content/le-tex/setup-manual/en/out/xhtml/transpect-setup.xhtml#sec-cascade"
          >configuration clades.</a>
      </p>
      <p>The converter works also without clade-based configuration. If you store your content in an arbitrary directory (e.g,
        /my/dir/idml/mycontent.idml), you may put content-specific configuration overrides into /my/dir/css, /my/dir/evolve-hub,
        etc.</p>
    </p:documentation>
    <p:document href="http://this.transpect.io/conf/transpect-conf.xml"/>
  </p:input>
  
  <p:input port="schema" primary="false">
    <p:document href="http://www.le-tex.de/resource/schema/tei-cssa/tei_allPlus-cssa.rng"/>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:pipe port="xml" step="hub2epub"/>
  </p:output>
  
  <p:output port="tex" primary="false">
    <p:pipe port="result" step="hub2tex"/>
  </p:output>
  
  <p:output port="html" primary="false">
    <p:pipe port="result" step="hub2epub"/>
  </p:output>
  
  <p:output port="htmlreport" primary="false">
    <p:pipe port="result" step="htmlreport"/>
  </p:output>
  
  <p:output port="xmp" primary="false">
    <p:pipe port="result" step="generate-xmp-wrapper"/>
  </p:output>

  <p:serialization port="tex" method="text" media-type="text/plain" encoding="utf8"/>
  <p:serialization port="result" indent="true"/>
  <p:serialization port="html" method="xhtml"/>
  <p:serialization port="htmlreport" method="xhtml"/>
  
  <p:option name="file" required="true"/>
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="table-headers-and-footers-from-tblLook" select="'no'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="interface-language" select="'de'"/>
  
  <p:option name="output-xml" select="'tei'">
    <p:documentation>preferred XML Output. possible values: "bits" or "tei"</p:documentation>
  </p:option>
  
  <p:option name="layout" select="'c'">
    <p:documentation>
      letter represents specific layout: a, b, c, e
    </p:documentation>
  </p:option>
  
  <p:option name="toc-depth" select="3">
    <p:documentation>
      Depth of Table of Contents
    </p:documentation>
  </p:option>

  <p:option name="numbering-depth" select="3">
    <p:documentation>
      Depth of Headline Numbering, 3 is "1.1.1"
    </p:documentation>
  </p:option>
  
  <p:option name="title-pages" select="'yes'">
    <p:documentation>
      Render half-title, full-title and imprint. Possible values are 'yes' or 'no'
    </p:documentation>
  </p:option>

  <p:option name="notes-type" select="'footnotes'">
    <p:documentation>
      Whether notes should be placed as 'footnotes' or 'endnotes'
    </p:documentation>
  </p:option>

  <p:option name="notes-per-chapter" select="'no'">
    <p:documentation>
      Should notes be rendered and renumbered per chapter? Valid values are 'yes' and 'no'
    </p:documentation>
  </p:option>

  <p:option name="endnotes-with-chapter" select="'no'">
    <p:documentation>
      Show chapter headlines in endnote listing. Values: 'yes'/'no'.
    </p:documentation>
  </p:option>
  
  <p:option name="notes-per-chapter-notoc" select="'yes'">
    <p:documentation>
      Suppress endnote headings of chapter endnotes in table of contents. Values: 'yes'/'no'. 
    </p:documentation>
  </p:option>

  <p:option name="pubtype" select="'mono'">
    <p:documentation>
      Publication type. Can be represented by an arbitrary string.
    </p:documentation>
  </p:option>

  <p:option name="running-header" select="'no'">
    <p:documentation>
      Whether to render running headers. Permitted values: 'yes' or 'no'.
    </p:documentation>
  </p:option>

  <p:option name="run-local" select="'no'">
    <p:documentation>
      Fix image paths to match local output directory.
    </p:documentation>
  </p:option>
  
  <p:option name="create-idml" required="false" select="'no'"/>
  <p:option name="idml-target-uri"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
  <p:import href="http://transpect.io/tei2hub/xpl/tei2hub.xpl"/>
  <p:import href="http://transpect.io/bits2hub/xpl/bits2hub.xpl"/>
  
  <p:import href="htmlreport.xpl"/>
  <p:import href="xml2tex.xpl"/>
  <p:import href="validate.xpl"/>
  <p:import href="hub2idml.xpl"/>
  <p:import href="export-chunks.xpl"/>
  <p:import href="docx2evolve.xpl"/>
  <p:import href="insert-meta.xpl"/>
  <p:import href="load-meta.xpl"/>
  <p:import href="hub2epub.xpl"/>
  <p:import href="generate-xmp.xpl"/>  

  <p:string-replace name="start-msg-replace" match="file">
    <p:with-option name="replace" select="concat('''', replace($file, '^.+/', ''), '''')"/>
    <p:input port="source">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">////////// Starting docx2tex conversion of <file/> \\\\\\\\\\</c:message>
          <c:message xml:lang="de">////////// Beginne docx2tex-Konvertierung von <file/> \\\\\\\\\\</c:message>
        </c:messages>
      </p:inline>
    </p:input>    
  </p:string-replace>
  
  <tr:simple-progress-msg name="start-msg" file="docx2tex-start.txt">
    <p:input port="msgs">
      <p:pipe port="result" step="start-msg-replace"/>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <p:sink/>
  
  <tr:file-uri name="normalize-filename">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>

  <p:sink/>
  
   <p:load name="load-paths-xsl"  cx:depends-on="start-msg">
    <p:with-option name="href" select="/tr:conf/@paths-xsl-uri">
      <p:pipe port="conf" step="main"/>
    </p:with-option>
  </p:load>
  
  <p:sink/>
  
  <p:in-scope-names name="expand-options-as-parameter-set"/>
  
  <tr:store-debug pipeline-step="cascade/param-set">
    <p:input port="source">
      <p:pipe port="result" step="expand-options-as-parameter-set"/>
    </p:input>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <tr:paths name="get-paths" cx:depends-on="start-msg">
    <p:with-option name="file" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-paths-xsl"/>
    </p:input>
    <p:input port="conf">
      <p:pipe port="conf" step="main"/>
    </p:input>
    <p:input port="params">
     <p:pipe port="result" step="expand-options-as-parameter-set"/>
    </p:input> 
  </tr:paths>
  
  <tx:load-meta name="load-meta-wrapper">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tx:load-meta>
  
  <p:choose name="create-hub" cx:depends-on="load-meta-wrapper">
    <p:when test="/*/c:param[@name = 'ext']/@value = 'docx'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <p:output port="result" primary="true">
        <p:pipe port="result" step="docx2evolve"/>
      </p:output>
      <p:output port="report" primary="false" sequence="true">
        <p:pipe port="report" step="docx2evolve"/>
      </p:output>
      
      <tx:docx2evolve name="docx2evolve">
        <p:input port="source">
          <p:pipe port="result" step="get-paths"/>
        </p:input>
        <p:input port="meta">
          <p:pipe port="result" step="load-meta-wrapper"/>
        </p:input>
        <p:with-option name="file" select="$file"/>
        <p:with-option name="table-headers-and-footers-from-tblLook" select="$table-headers-and-footers-from-tblLook"/>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tx:docx2evolve>
      
    </p:when>
    <p:otherwise>
      <p:output port="result"  primary="true">
        <p:pipe port="result" step="create-hub2"/>
      </p:output>
      
      <p:output port="report" primary="false">
        <p:pipe port="report" step="create-hub2"/>
      </p:output>
      
      <p:load name="load-xml">
        <p:with-option name="href" select="/c:result/@local-href">
          <p:pipe port="result" step="normalize-filename"/>
        </p:with-option>
      </p:load>
      <p:choose name="create-hub2">
        <p:when test="/*:TEI">
          <p:output port="result"  primary="true">
            <p:pipe port="result" step="tei2hub"/>
          </p:output>
          
          <p:output port="report" primary="false">
            <p:pipe port="report" step="tei2hub"/>
          </p:output>
          
          <tei2hub:tei2hub name="tei2hub">
            <p:input port="source">
              <p:pipe port="result" step="load-xml"/>
            </p:input>
            <p:input port="paths">
              <p:pipe port="result" step="get-paths"/>
            </p:input>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
            <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
          </tei2hub:tei2hub>
        </p:when>
        <p:otherwise>
          <p:output port="result"  primary="true">
            <p:pipe port="result" step="bits2hub"/>
          </p:output>
          
          <p:output port="report" primary="false">
            <p:pipe port="report" step="bits2hub"/>
          </p:output>
          
          <tr:bits2hub name="bits2hub">
            <p:input port="source">
              <p:pipe port="result" step="load-xml"/>
            </p:input>
            <p:input port="paths">
              <p:pipe port="result" step="get-paths"/>
            </p:input>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
            <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
          </tr:bits2hub>
        </p:otherwise>
      </p:choose>
    </p:otherwise>
  </p:choose>
  
  <tx:xml2tex name="hub2tex" cx:depends-on="create-hub">
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:xml2tex>
  
  <p:sink/>
  
  <tx:hub2epub name="hub2epub" cx:depends-on="hub2tex">
    <p:input port="source">
      <p:pipe port="result" step="create-hub"/> 
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="output-xml" select="$output-xml"/>
  </tx:hub2epub>
  
  <tx:validate name="validate" cx:depends-on="hub2epub">
    <p:input port="source">
      <p:pipe port="xml" step="hub2epub"/>
    </p:input>
    <p:input port="hub">
      <p:pipe port="result" step="create-hub"/>
    </p:input>
    <p:input port="schema">
      <p:pipe port="schema" step="main"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="epub-file-uri">
      <p:pipe port="epub-path" step="hub2epub"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="interface-language" select="$interface-language"/>
  </tx:validate>
  
  <p:sink/>
  
  <tx:htmlreport name="htmlreport" cx:depends-on="validate">
    <p:input port="source">
      <p:pipe port="result" step="hub2epub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="get-paths"/>
    </p:input>
    <p:input port="reports">
      <p:pipe port="report" step="create-hub"/>
      <p:pipe port="reports" step="validate"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tx:htmlreport>
  
  <p:sink/>

  <p:choose name="idml-synth">
    <p:when test="/*/c:param[@name = 'create-idml']/@value = 'yes'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:hub2idml name="hub2idml" >
        <p:input port="source">
          <p:pipe port="result" step="create-hub"/>
        </p:input>
        <p:input port="paths">
          <p:pipe port="result" step="get-paths"/> 
        </p:input>
        <p:with-option name="debug" select="$debug" />
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
      </tx:hub2idml>
    </p:when>
    <p:otherwise>
      <p:identity name="bogo">
        <p:input port="source">
          <p:inline>
            <c:results>Option create-idml: no</c:results>
          </p:inline>
        </p:input>
      </p:identity>
      <p:sink/>
    </p:otherwise>  
  </p:choose>

  <p:choose name="split-html">
    <p:when test="/*/c:param[@name = 'export-chunks']/@value = 'yes'">
      <p:xpath-context><p:pipe port="result" step="get-paths"/></p:xpath-context>
      <tx:export-chunks>
        <p:input port="source">
          <p:pipe port="result" step="hub2epub"/>
        </p:input>
        <p:input port="tei">
          <p:pipe port="xml" step="hub2epub"/>
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
      <p:sink name="s4"/>
    </p:otherwise>  
  </p:choose>
  
  <tx:generate-xmp name="generate-xmp-wrapper">
    <p:input port="source">
      <p:pipe port="result" step="load-meta-wrapper"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="get-paths"/> 
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>    
  </tx:generate-xmp>

  <p:sink/>
  
</p:declare-step>