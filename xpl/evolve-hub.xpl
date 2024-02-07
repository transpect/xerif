<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="tx-evolve-hub" 
  type="tx:evolve-hub">
    
  <p:input port="source" primary="true"/>
  <p:input port="params" primary="false"/>
  <p:output port="result" primary="true"/>
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="evolve-hub-dyn"/>
  </p:output>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="debug-indent" select="'false'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/dynamic-transformation-pipeline.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  
  <tr:simple-progress-msg name="evolve-hub-start-msg" file="evolve-hub-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting flat Hub XML to evolved Hub XML conversion</c:message>
          <c:message xml:lang="de">Beginne Konvertierung von flachem Hub XML zu angereichertem Hub XML</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <tr:dynamic-transformation-pipeline name="evolve-hub-dyn" 
                                      load="evolve-hub/driver-docx"
                                      fallback-xpl="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xpl"
                                      fallback-xsl="http://this.transpect.io/a9s/common/evolve-hub/driver-docx.xsl">
    <p:input port="paths">
      <p:pipe port="params" step="tx-evolve-hub"/>
    </p:input>
    <p:input port="options">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:dynamic-transformation-pipeline>

  <p:choose name="choose-parse-bibrefs">
    <p:when test="/c:param-set/c:param[@name eq 'parse-bibliographic-references']/@value = 'yes'">
      <p:xpath-context>
        <p:pipe port="params" step="tx-evolve-hub"/>
      </p:xpath-context>
      
      <tr:dynamic-transformation-pipeline name="parse-bibrefs-dyn" 
                                          load="evolve-hub/parse-bibrefs"
                                          fallback-xpl="http://this.transpect.io/a9s/common/evolve-hub/parse-bibrefs.xpl"
                                          fallback-xsl="http://this.transpect.io/a9s/common/evolve-hub/parse-bibrefs.xsl">
        <p:input port="paths">
          <p:pipe port="params" step="tx-evolve-hub"/>
        </p:input>
        <p:input port="additional-inputs">
          <p:empty/>
        </p:input>
        <p:input port="options">
          <p:empty/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      </tr:dynamic-transformation-pipeline>
      
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>

  <tr:simple-progress-msg name="evolve-hub-end-msg" file="evolve-hub-end.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully finished flat Hub XML to evolved Hub XML conversion</c:message>
          <c:message xml:lang="de">Konvertierung von flachem Hub XML zu angereichertem Hub XML erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
</p:declare-step>
