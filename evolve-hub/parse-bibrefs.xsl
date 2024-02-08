<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:hub="http://transpect.io/hub"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns="http://docbook.org/ns/docbook"
  exclude-result-prefixes="c dbk hub xs"
  version="2.0">
  
  <xsl:variable name="original-bibliography" as="document-node(element(dbk:bibliography))?" 
                select="collection()[2]"/>
  
  <xsl:variable name="bibliography-index" as="xs:integer" 
                select="1"/>
  
  <xsl:template match="c:result">
    <bibliography>
      <xsl:apply-templates select="$original-bibliography/dbk:bibliography/@*,
                                   $original-bibliography/dbk:bibliography/*[not(self::dbk:bibliomixed)], 
                                   *"/>
    </bibliography>
  </xsl:template>
  
  <xsl:template match="dataset">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:variable name="sequence-ids" as="xs:string*" 
                      select="/c:result/dataset/sequence/generate-id()"/>
  
  <xsl:template match="sequence">
    <xsl:variable name="ref-index" as="xs:integer"
                  select="index-of($sequence-ids, generate-id())"/>
    <xsl:variable name="ref-id" as="xs:string"
                  select="concat($bibliography-index, '-', $ref-index)"/>
    <xsl:variable name="rendered-ref" as="element(dbk:bibliomixed)?" 
                  select="$original-bibliography/dbk:bibliography/dbk:bibliomixed[$ref-index]"/>
    <biblioentry xml:id="ref-{$ref-id}">
      <xsl:if test="$rendered-ref">
        <abstract role="rendered">
          <para>
            <xsl:apply-templates select="$rendered-ref/node()"/>
          </para>
        </abstract>
      </xsl:if>
      <xsl:sequence select="hub:ref-wrapper(*)"/>
    </biblioentry>
  </xsl:template>
  
  <xsl:function name="hub:ref-wrapper" as="element(dbk:biblioset)*">
    <xsl:param name="ref-components" as="element()*"/>
    <xsl:variable name="pub-type" as="xs:string" 
                  select="('journal'[$ref-components[self::journal]], 
                           'collection'[$ref-components[self::collection-title or self::container-title]], 
                           'book'[$ref-components[self::author] and $ref-components[self::title]],
                           'other')[1]"/>
    <xsl:for-each-group select="$ref-components" group-by="hub:ref-type(., $pub-type)">
      <biblioset relation="{current-grouping-key()}">
        <xsl:apply-templates select="current-group()"/>
      </biblioset>
    </xsl:for-each-group>
  </xsl:function>
  
  <xsl:function name="hub:ref-type" as="xs:string">
    <xsl:param name="ref-element" as="element()"/>
    <xsl:param name="pub-type" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$pub-type = ('journal', 'collection') and $ref-element/local-name() = ('collection-title', 'container-title', 'journal', 'volume', 'editor', 'publisher', 'location')">
        <xsl:sequence select="$pub-type"/>
      </xsl:when>
      <xsl:when test="$pub-type = ('journal', 'collection') and $ref-element/local-name() = ('author', 'title', 'pages', 'date', 'note')">
        <xsl:sequence select="if($pub-type eq 'journal') then 'article' else 'chapter'"/>
      </xsl:when>
      <xsl:when test="$pub-type eq 'book'">
        <xsl:sequence select="'book'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'other'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="author
                      |editor
                      |director">
    <xsl:element name="{if(local-name() = ('author', 'editor'))
                        then local-name()
                        else 'othercredit'}">
      <xsl:if test="not(local-name() = ('author', 'editor'))">
        <xsl:attribute name="role" select="local-name()"/>
      </xsl:if>
      <personname>
        <othername>
          <xsl:apply-templates/>
        </othername>
      </personname>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="title
                      |journal
                      |collection-title
                      |container-title">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>
  
  <xsl:template match="edition">
    <edition>
      <xsl:apply-templates/>
    </edition>
  </xsl:template>
  
  <xsl:template match="note
                      |genre">
    <bibliomisc role="{local-name()}">
      <xsl:apply-templates/>
    </bibliomisc>
  </xsl:template>
  
  <xsl:template match="volume">
    <volumenum>
      <xsl:apply-templates/>
    </volumenum>
  </xsl:template>
  
  <xsl:template match="pages">
    <pagenums>
      <xsl:apply-templates/>
    </pagenums>
  </xsl:template>
  
  <xsl:template match="date">
    <date>
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <xsl:template match="location">
    <date>
      <xsl:apply-templates/>
    </date>
  </xsl:template>
  
  <xsl:template match="publisher">
    <publishername>
      <xsl:apply-templates/>
    </publishername>
  </xsl:template>
  
  <xsl:template match="@* | *">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>