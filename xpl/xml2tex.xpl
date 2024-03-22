<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="tx-xml2tex"
  type="tx:xml2tex">
  
  <p:input port="source" primary="true">
    <p:documentation>
      Hub document
    </p:documentation>
  </p:input>
  
  <p:input port="params" primary="false">
    <p:documentation>
      Paths document
    </p:documentation>
  </p:input>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:serialization port="result" method="text" media-type="text/plain" encoding="utf8"/>
  
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xml2tex/xpl/xml2tex.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>

  <tr:simple-progress-msg name="load-xml2tex-config-msg" file="load-xml2tex-config.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Loading xml2tex configuration</c:message>
          <c:message xml:lang="de">Lade Konfiguration von xml2tex</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <tr:load-cascaded name="load-latex-conf" filename="xml2tex/latex.conf.xml">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
  </tr:load-cascaded>
  
  <p:sink/>
  
  <tr:load-cascaded name="load-xml2tex-helpers-xslt" filename="xml2tex/10.helpers.xsl">
    <p:with-option name="debug" select="$debug" />
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri" />
    <p:input port="paths">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
  </tr:load-cascaded>
  
  <p:sink/>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="xml2tex/12" mode="xml2tex:helpers">
    <p:input port="stylesheet">
      <p:pipe step="load-xml2tex-helpers-xslt" port="result"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>

  <tr:simple-progress-msg name="xml2tex-start-msg" file="xml2tex-start.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Starting xml2tex conversion</c:message>
          <c:message xml:lang="de">Beginne xml2tex-Konvertierung</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>
  
  <xml2tex:convert name="hub2tex">
    <p:documentation>Converts the hub XML to TeX according to the xml2tex configuration file.</p:documentation>
    <p:input port="conf">
      <p:pipe port="result" step="load-latex-conf"/>     
    </p:input>
    <p:input port="paths">
      <p:pipe port="params" step="tx-xml2tex"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="collect-all-xsl" select="(/c:param-set/c:param[@name eq 'collect-all-xsl']/@value, 'yes')[1]">
      <p:pipe port="params" step="tx-xml2tex"/>
      <p:documentation>collect all xsl templates from config. important if you work with several modes for the same elements. 
                       should be yes if common framework latex is used</p:documentation>
    </p:with-option>
  </xml2tex:convert>

  <tr:simple-progress-msg name="xml2tex-end-msg" file="xml2tex-end.txt">
    <p:input port="msgs">
      <p:inline>
        <c:messages>
          <c:message xml:lang="en">Successfully finished xml2tex conversion</c:message>
          <c:message xml:lang="de">xml2tex-Konvertierung erfolgreich abgeschlossen</c:message>
        </c:messages>
      </p:inline>
    </p:input>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:simple-progress-msg>

  
</p:declare-step>
