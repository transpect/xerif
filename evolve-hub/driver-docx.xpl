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
  
  <p:option name="debug" required="false" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="debug-indent" select="'false'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl" />
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub_lists-by-indent.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/00" mode="hub:split-at-tab">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/01" mode="hub:dissolve-sidebars-without-purpose">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/02" mode="hub:meta-infos-to-sidebar">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/03" mode="hub:preprocess-hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/04" mode="hub:hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/05" mode="hub:postprocess-hierarchy">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/12" mode="hub:figure-captions">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/13" mode="hub:table-captions">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/40" mode="hub:repair-hierarchy">
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
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/42" mode="hub:join-phrases">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/43" mode="hub:twipsify-lengths">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/44" mode="hub:identifiers">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.2" prefix="evolve-hub/51" mode="hub:tabs-to-indent" name="tabs-to-indent">
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
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/60" mode="hub:ids">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/65" mode="hub:blockquotes">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/90" mode="hub:clean-hub">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/91" mode="hub:repair-language-markup">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>

  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/93" mode="preprocess-hyphens">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/95" mode="custom-1">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
  <tr:xslt-mode msg="yes" hub-version="1.1" prefix="evolve-hub/96" mode="custom-2">
    <p:input port="stylesheet"><p:pipe step="driver-docx" port="stylesheet"/></p:input>
    <p:input port="parameters"><p:pipe step="driver-docx" port="parameters"/></p:input>
    <p:input port="models"><p:empty/></p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="debug-indent" select="$debug-indent"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:xslt-mode>
  
</p:declare-step>
