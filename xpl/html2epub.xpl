<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:jats2html="http://transpect.io/jats2html"
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:epub="http://transpect.io/epubtools"
  xmlns:tx="http://transpect.io/xerif"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0" 
  name="tx-html2epub" 
  type="tx:html2epub">
  
  <p:input port="source" primary="true">
    <p:documentation>
      Expects a HTML Document
    </p:documentation>
  </p:input>
  
  <p:input port="params"  primary="false">
    <p:documentation>
      An c:param-set paths document
    </p:documentation>
  </p:input>
  
  <p:input port="meta"  primary="false">
    <p:documentation>
      Expects a metadata file
    </p:documentation>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:documentation>
      The EPUB file URI
    </p:documentation>
    <p:pipe port="result" step="create-epub"/>
  </p:output>
  
  <p:output port="html" primary="false">
    <p:pipe port="html" step="create-epub"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="create-epub"/>
  </p:output>
  
  <p:option name="out-dir-uri" select="'out'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/epubtools/xpl/epub-convert.xpl"/>
  <p:import href="http://transpect.io/htmltemplates/xpl/htmltemplates.xpl"/>
  
  <p:template name="load-epub-config-options-input">
    <p:input port="source">
      <p:empty/>
    </p:input>
    <p:input port="template">
      <p:inline>
        <cx:options>
          <cx:option name="basename" value="{$basename}"/>
        </cx:options>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="params" step="tx-html2epub"/>
    </p:input>
  </p:template>
  
  <p:sink/>

  <p:group name="create-epub" cx:depends-on="load-epub-config">
    <p:output port="result">
      <p:pipe port="result" step="epub-convert"/>
    </p:output>
    <p:output port="html">
      <p:pipe port="result" step="htmltemplates"/>
    </p:output>
    <p:output port="report" sequence="true">
      <p:pipe port="report" step="epub-convert"/>
    </p:output>
    <p:variable name="basename" select="/c:param-set/c:param[@name='basename']/@value">
      <p:pipe port="params" step="tx-html2epub"/>
    </p:variable>
    <p:variable name="epub-path" select="concat($out-dir-uri, '/', $basename, '.epub')"/>
    
    <html:templates name="htmltemplates">
      <p:input port="source">
        <p:pipe port="source" step="tx-html2epub"/>
      </p:input>
      <p:input port="meta">
        <p:pipe port="meta" step="tx-html2epub"/>
      </p:input>
      <p:input port="paths">
        <p:pipe port="params" step="tx-html2epub"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="different-basename" select="$basename"/>
    </html:templates>
    
    <!--<p:string-replace name="replace-base" match="/*/@xml:base">
      <p:with-option name="replace" select="concat('''', $epub-path, '''')"/>
    </p:string-replace>-->
    
    <p:delete match="*:header[@class='chunk-meta-sec'] | *:p[matches(@class, 'tsmedia(caption|source|url)')]" name="delete-header"/>
     
   <p:wrap wrapper="cx:document" match="/"/>
   <p:add-attribute name="wrap-htmltemplates" attribute-name="port" attribute-value="htmltemplates" match="/*"/>
   
    <cx:message>
      <p:with-option name="message" select="'[info] epub path: ', $epub-path"/>
    </cx:message>
    
    <p:sink/>

    <tr:dynamic-transformation-pipeline name="load-epub-config" 
                                        load="epub/load-epub-config"
                                        fallback-xpl="http://this.transpect.io/a9s/common/epub/load-epub-config.xpl" cx:depends-on="wrap-htmltemplates">
      <p:input port="source">
        <p:pipe port="meta" step="tx-html2epub"/>
      </p:input>
      <p:input port="paths">
        <p:pipe port="params" step="tx-html2epub"/>
      </p:input>
      <p:input port="options">
        <p:pipe port="result" step="load-epub-config-options-input"/>
      </p:input>
      <p:input port="additional-inputs">
        <p:pipe port="result" step="wrap-htmltemplates"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    </tr:dynamic-transformation-pipeline>
  
    <p:sink/>
    
    <p:identity cx:depends-on="load-epub-config" name="id-cover">
      <p:input port="source">
        <p:pipe port="result" step="delete-header"/>
      </p:input>
    </p:identity>
  
    <p:add-attribute attribute-name="src" match="/html:html/html:body/html:div[@id = 'epub-cover-image-container']/html:img" name="replace-cover-href">
      <p:with-option name="attribute-value" select="/*:epub-config/*:cover/@href">
        <p:pipe port="result" step="load-epub-config"/>
      </p:with-option>
    </p:add-attribute>

    <tr:store-debug pipeline-step="htmltemplates/99_with_cover">
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>

    <p:sink/>

    <epub:convert name="epub-convert">
      <p:input port="source">
        <p:pipe port="result" step="replace-cover-href"/>
      </p:input>
      <p:input port="meta">
        <p:pipe port="result" step="load-epub-config"/>
      </p:input>
      <p:input port="conf">
        <p:empty/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      <p:with-option name="terminate-on-error" select="'yes'"/>
    </epub:convert>
      
    <p:sink/>
  </p:group>

</p:declare-step>