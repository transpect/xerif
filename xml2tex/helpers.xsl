<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:calstable="http://docs.oasis-open.org/ns/oasis-exchange/table" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:functx="http://www.functx.com"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs xhtml"
  version="2.0">
  
  <!-- helper transformations that are used for rendering purposes
       and not affect the xml output -->
  
  <xsl:import href="../xsl/shared-variables.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/calstable/xsl/normalize.xsl"/>
  <xsl:import href="http://transpect.io/xslt-util/functx/Strings/Replacing/escape-for-regex.xsl"/>
  
  <xsl:template match="@* | node()" mode="xml2tex:helpers xml2tex:table-split-restore">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- split tables with Andrew Welch’s table normalization algorithm -->
  
  <xsl:template match="*[local-name() = ('table', 'informaltable')]
                        [dbk:tgroup/dbk:tbody/dbk:row[dbk:entry//processing-instruction()[name() eq 'latex']
                                                     [matches(., functx:escape-for-regex($xml2tex:split-table-pi))]]]
                        [not(@role eq 'tablerotated') or $xml2tex:split-landscape-tables]" mode="xml2tex:helpers">
    <xsl:call-template name="xml2tex:split-table">
      <xsl:with-param name="table" select="." as="element()"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="dbk:entry//processing-instruction()[name() eq 'latex']
                                                          [matches(., 
                                                             functx:escape-for-regex($xml2tex:split-table-pi)
                                                           )]" mode="xml2tex:helpers">
    <xsl:param name="split" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:if test="not($split)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="xml2tex:split-table">
    <xsl:param name="table" as="element()"/>
    <xsl:variable name="table-split" as="node()+">
      <xsl:for-each-group select="calstable:check-normalized(
                                    calstable:normalize(dbk:tgroup/dbk:tbody), 'no'
                                  )/dbk:row" 
                          group-starting-with="dbk:row[dbk:entry//processing-instruction()[name() eq 'latex']
                                                      [matches(., functx:escape-for-regex($xml2tex:split-table-pi))]]">
        <xsl:if test="not(position() eq 1)">
          <xsl:processing-instruction name="latex" select="'{\newpage}%&#xa;'"/>
        </xsl:if>
        <xsl:element name="{$table/name()}">
          <xsl:attribute name="xml:id" select="if(position() ne 1) 
                                               then concat($table/@xml:id, '_split', position())
                                               else $table/@xml:id"/>
          <xsl:apply-templates select="$table/@* except $table/@xml:id" mode="#current"/>
          <xsl:call-template name="xml2tex:split-table-title">
            <xsl:with-param name="table" select="$table" as="element()"/>
            <xsl:with-param name="pos" select="position()" as="xs:integer"/>
          </xsl:call-template>
          <xsl:call-template name="xml2tex:split-table-info">
            <xsl:with-param name="table" select="$table" as="element()"/>
            <xsl:with-param name="pos" select="position()" as="xs:integer"/>
          </xsl:call-template>
          <tgroup>
            <xsl:apply-templates select="$table/dbk:tgroup/@*, 
                                         $table/dbk:tgroup/dbk:colspec" mode="#current"/>
            <xsl:call-template name="xml2tex:split-table-head">
              <xsl:with-param name="table" select="$table" as="element()"/>
              <xsl:with-param name="pos" select="position()" as="xs:integer"/>
            </xsl:call-template>
            <tbody>
              <xsl:apply-templates select="current-group()" mode="#current">
                <xsl:with-param name="split" select="true()" as="xs:boolean" tunnel="yes"/>
              </xsl:apply-templates>
            </tbody>
            <xsl:if test="position() eq last()">
              <xsl:apply-templates select="$table/dbk:tgroup/dbk:tfoot" mode="#current"/>
            </xsl:if>
          </tgroup>
          <xsl:call-template name="xml2tex:split-table-caption">
            <xsl:with-param name="table" select="$table" as="element()"/>
            <xsl:with-param name="pos" select="position()" as="xs:integer"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="table-restored" as="node()+">
      <xsl:apply-templates select="$table-split" mode="xml2tex:table-split-restore"/>
    </xsl:variable>
    <xsl:sequence select="$table-restored"/>
  </xsl:template>
  
  <xsl:template name="xml2tex:split-table-title">
    <xsl:param name="table" as="element()"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:if test="(   $pos eq 1 and not($xml2tex:table-caption-pos = 'bottom'))
                   or $xml2tex:repeat-split-table-title
                   or ($pos eq last() and $xml2tex:table-caption-pos = 'bottom')">
      <xsl:apply-templates select="$table/dbk:title" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="xml2tex:split-table-head">
    <xsl:param name="table" as="element()"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:if test="$pos eq 1 or $xml2tex:repeat-split-table-head">
      <xsl:apply-templates select="$table/dbk:tgroup/dbk:thead" mode="#current"/>
    </xsl:if>
  </xsl:template>
 
  <xsl:template name="xml2tex:split-table-info">
    <xsl:param name="table" as="element()"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:if test="$pos eq last() or $xml2tex:repeat-split-table-info">
      <xsl:apply-templates select="$table/dbk:info(:copyright info:)" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="xml2tex:split-table-caption">
    <xsl:param name="table" as="element()"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:if test="$pos eq last() or $xml2tex:repeat-split-table-caption">
      <xsl:apply-templates select="$table/dbk:caption" mode="#current"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="dbk:tbody/dbk:row/dbk:entry[@linkend][@morerows eq '0']" mode="xml2tex:table-split-restore">
    <xsl:copy>
      <xsl:apply-templates select="@* except (@morerows
                                             |@linkend
                                             |@namest
                                             |@nameend)" mode="xml2tex:helpers"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="dbk:tbody/dbk:row/dbk:entry[@linkend][not(@morerows) or @morerows ne '0'] | dbk:entry/@xml:id" 
                mode="xml2tex:table-split-restore"/>
  
  <xsl:template match="dbk:row/dbk:entry[not(for $rowspan in @morerows 
                                             return parent::row/following-sibling::*[$rowspan])]/@morerows" 
                mode="xml2tex:table-split-restore"/>

</xsl:stylesheet>
