<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:hub="http://transpect.io/hub" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:functx="http://www.functx.com"
  xmlns:idml2xml="http://transpect.io/idml2xml"
  xmlns="http://docbook.org/ns/docbook" 
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs hub functx idml2xml" 
  version="2.0">
  
  <!-- map style names to Word style names (strip style directory names and underscores ) and vice versa
  -->
  <!-- style is Hub 1.0, css:rule is Hub 1.1 or later -->
  <xsl:key name="hub:style-by-role" match="style | css:rule" use="(@role, @name)[1]" />

  <xsl:template match="@* | node()" mode="#all" priority="-0.5">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
    
  <xsl:template match="css:rule[not(@layout-type = 'layer')]/@name" mode="idml2docx">
    <xsl:attribute name="name" select="hub:strip-idml-style-name(., ../@native-name)"/>
  </xsl:template>

  <xsl:template match="css:rule[not(@layout-type = 'layer')]/@native-name[starts-with(., 'meta:')]" mode="idml2docx">
    <xsl:attribute name="native-name" select="replace(., '^meta:', '')"/>
  </xsl:template>

  <xsl:template match="*/@role[. = /hub/info/css:rules/css:rule/@name]" mode="idml2docx">
    <xsl:attribute name="role" select="hub:strip-idml-style-name(., key('hub:style-by-role', .)/@native-name)"/>
  </xsl:template>
  
  <xsl:function name="hub:strip-idml-style-name" as="xs:string*">
    <xsl:param name="style-name" as="xs:string"/>
    <xsl:param name="native-style-name" as="xs:string?"/>
    <xsl:variable name="new-basic-name" as="xs:string?" select="tokenize($native-style-name, ':')[last()]"/>
    <xsl:variable name="normalized-name" as="xs:string?" select="replace(translate(replace($new-basic-name, '^\$ID/', ''), '_/$äöüÄÖÜ []()%+ß', ''), '^(\d)', '_$1')"/>
    <xsl:variable name="tilde-tokens" as="xs:string*" select="tokenize($normalized-name, '~')"/>
    <xsl:variable name="tilded-new-name" as="xs:string?" select="string-join(($tilde-tokens[1], $tilde-tokens[. = ('SPLIT', 'DISCARD')]), '_-_')"/>
    <xsl:variable name="replace-some-more" as="xs:string?" select="replace(replace($tilded-new-name, '^(abstract)', 'ts$1'), 'tsmeat', 'tsmeta')"/>
    <xsl:sequence select="replace($replace-some-more, '(intended|indent)$', '')"/>
  </xsl:function>

  <!-- docx2idml: create directories -->

  <xsl:template match="css:rule/@native-name" mode="docx2idml">
    <xsl:variable name="new-native-name" select="hub:replace-docx-native-style-names(../@name, .)"/>
    <xsl:attribute name="name" select="hub:postprocess-idml-style-name($new-native-name)"/>
    <xsl:attribute name="native-name" select="$new-native-name"/>
  </xsl:template>

  <xsl:function name="hub:postprocess-idml-style-name" as="xs:string*">
    <xsl:param name="style-name" as="xs:string"/>
    <xsl:sequence select="replace(translate($style-name, ':', '_'), '^([\dÜÖÄß])', '_')"/>
  </xsl:function>

  <xsl:template match="*/@role[. = /hub/info/css:rules/css:rule/@name]" mode="docx2idml">
    <xsl:attribute name="role" select="hub:postprocess-idml-style-name(hub:replace-docx-native-style-names(., key('hub:style-by-role', .)/@native-name))"/>
  </xsl:template>

  <xsl:function name="hub:replace-docx-native-style-names" as="xs:string*">
    <xsl:param name="style-name" as="xs:string"/>
    <xsl:param name="native-style-name" as="xs:string?"/>
    <xsl:variable name="new-basic-name" as="xs:string?" select="$native-style-name"/>
    <xsl:variable name="replace-special-styles" as="xs:string?" select="hub:map-styles($new-basic-name)"/>
    <xsl:sequence select="$replace-special-styles"/>
  </xsl:function>

  <xsl:template match="css:rule/@name" mode="docx2idml"/>

  <!-- add lost styles to rules-->

  <xsl:variable name="add-para-rules-styles" select="('ts_figure_source', 'ts_figure_caption', 'ts_table_source', 'ts_table_caption', 'ts_body_-_intended')" as="xs:string+"/>

  <xsl:template match="css:rules" mode="docx2idml">
    <xsl:copy>
      <xsl:apply-templates select="node()" mode="#current"/>
      <xsl:for-each select="$add-para-rules-styles">
        <css:rule>
          <xsl:attribute name="name" select="."/>
          <xsl:attribute name="native-name" select="hub:map-styles(.)"/>
          <xsl:attribute name="layout-type" select="'para'"/>
        </css:rule>
      </xsl:for-each>
        <css:rule>
          <xsl:attribute name="name" select="'ts_box_border'"/>
          <xsl:attribute name="native-name" select="'ts_box_border'"/>
          <xsl:attribute name="layout-type" select="'object'"/>
        </css:rule>
        <css:rule>
          <xsl:attribute name="name" select="'ts_box_grey'"/>
          <xsl:attribute name="native-name" select="'ts_box_grey'"/>
          <xsl:attribute name="layout-type" select="'object'"/>
        </css:rule>
        <css:rule>
          <xsl:attribute name="name" select="'ts_figure'"/>
          <xsl:attribute name="native-name" select="'ts_figure'"/>
          <xsl:attribute name="layout-type" select="'object'"/>
        </css:rule>
        <css:rule>
          <xsl:attribute name="name" select="'ts_figure_-_stroke'"/>
          <xsl:attribute name="native-name" select="hub:map-styles('ts_figure_-_stroke')"/>
          <xsl:attribute name="layout-type" select="'object'"/>
        </css:rule>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mediaobject[not(@role)]" mode="docx2idml">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'ts_figure'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="figure/title" mode="docx2idml">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'ts_figure_caption'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="figure/caption/para" mode="docx2idml" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'ts_figure_source'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="table/caption/para" mode="docx2idml">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'ts_table_source'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="div[matches(@role, 'box')]" mode="docx2idml" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="replace(@role, '^tsbox(border|grey)$', 'ts_box_$1')"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="table/title" mode="docx2idml">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="'ts_table_caption'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para[not(@role)]" mode="docx2idml" priority="-0.25">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="role" select="if (preceding-sibling::*[1][self::info]) then 'ts_body' else 'ts_body_-_intended'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:variable name="styles" as="element(styles)">
    <styles>
      <style target-name="ts_body" style-regex="^text$"/>
      <style target-name="Überschriften:ts_heading_$1" style-regex="^ts_heading_([1-5])$"/>
      <style target-name="Überschriften:ts_author" style-regex="^ts_author$"/>
      <style target-name="ts_body~intended" style-regex="^ts_body_-_intended$"/>
      <style target-name="ts_box_$1" style-regex="^tsbox(grey|border)$"/>
    </styles>
  </xsl:variable>

  <xsl:function name="hub:map-styles" as="xs:string*">
    <xsl:param name="style-name" as="xs:string"/>
    <xsl:sequence select="if (some $s in $styles/*:style/@style-regex satisfies matches($style-name, $s)) 
                          then for $s in $styles/*:style[matches($style-name, @style-regex )][1] return replace($style-name, $s/@style-regex, $s/@target-name) 
                          else $style-name"/>
  </xsl:function>

</xsl:stylesheet>
