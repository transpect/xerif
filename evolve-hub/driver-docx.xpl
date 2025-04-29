<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  xmlns:hub="http://transpect.io/hub"
  xmlns:tx="http://transpect.io/xerif"
  version="1.0"
  name="driver-docx">
    
  <p:input port="source" primary="true"/>
  <p:input port="stylesheet" primary="false"/>
  <p:input port="parameters" kind="parameter" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:output port="report" sequence="true">
    <p:pipe port="report" step="split-at-tab"/>
    <p:pipe port="report" step="dissolve-sidebars-without-purpose"/>
    <p:pipe port="report" step="meta-infos-to-sidebar"/>
    <p:pipe port="report" step="preprocess-hierarchy"/>
    <p:pipe port="report" step="hierarchy"/>
    <p:pipe port="report" step="postprocess-hierarchy"/>
    <p:pipe port="report" step="figure-captions"/>
    <p:pipe port="report" step="table-captions"/>
    <p:pipe port="report" step="repair-hierarchy"/>
    <p:pipe port="report" step="process-meta"/>
    <p:pipe port="report" step="join-phrases"/>
    <p:pipe port="report" step="twipsify-lengths"/>
    <p:pipe port="report" step="identifiers"/>
    <p:pipe port="report" step="tabs-to-indent"/>
    <p:pipe port="report" step="handle-indent"/>
    <p:pipe port="report" step="strip-space"/>
    <p:pipe port="report" step="prepare-lists"/>
    <p:pipe port="report" step="lists"/>
    <p:pipe port="report" step="postprocess-lists"/>
    <p:pipe port="report" step="ids"/>
    <p:pipe port="report" step="blockquotes"/>
    <p:pipe port="report" step="clean-hub"/>
    <p:pipe port="report" step="repair-language-markup"/>
    <p:pipe port="report" step="preprocess-hyphens"/>
    <p:pipe port="report" step="custom-1"/>
    <p:pipe port="report" step="custom-2"/>
  </p:output>
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="debug-indent" select="'false'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub_lists-by-indent.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/00" mode="hub:split-at-tab" name="split-at-tab">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/01" mode="hub:dissolve-sidebars-without-purpose" name="dissolve-sidebars-without-purpose">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/02" mode="hub:meta-infos-to-sidebar" name="meta-infos-to-sidebar">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/03" mode="hub:preprocess-hierarchy" name="preprocess-hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/04" mode="hub:hierarchy" name="hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/05" mode="hub:postprocess-hierarchy" name="postprocess-hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/12" mode="hub:figure-captions" name="figure-captions">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/13" mode="hub:table-captions" name="table-captions">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/40" mode="hub:repair-hierarchy" name="repair-hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/41" mode="hub:process-meta-sidebar" name="process-meta">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/42" mode="hub:join-phrases" name="join-phrases">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/43" mode="hub:twipsify-lengths" name="twipsify-lengths">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/44" mode="hub:identifiers" name="identifiers">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/51" mode="hub:tabs-to-indent"  name="tabs-to-indent">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/52" mode="hub:handle-indent" name="handle-indent">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/53" mode="hub:strip-space" name="strip-space">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/54" mode="hub:prepare-lists" name="prepare-lists">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/55" mode="hub:lists" name="lists">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/56" mode="hub:postprocess-lists" name="postprocess-lists">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/60" mode="hub:ids" name="ids">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/65" mode="hub:blockquotes" name="blockquotes">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/90" mode="hub:clean-hub" name="clean-hub">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/91" mode="hub:repair-language-markup" name="repair-language-markup">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>

  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/93" mode="preprocess-hyphens"  name="preprocess-hyphens">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/95" mode="custom-1" name="custom-1">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/96" mode="custom-2" name="custom-2">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
</p:declare-step>
