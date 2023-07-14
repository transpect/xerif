<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.w3.org/1996/css"
                xmlns:dbk="http://docbook.org/ns/docbook"
                xmlns:hub="http://transpect.io/hub"
                xmlns:hub2tei="http://transpect.io/hub2tei"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:docx2hub="http://transpect.io/docx2hub"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cx="http://xmlcalabash.com/ns/extensions"
                xmlns:tr="http://transpect.io"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="dbk docx2hub html hub2tei hub xlink css xs cx tr tei"
                version="2.0" 
                xpath-default-namespace="http://docbook.org/ns/docbook">
  
  <xsl:output indent="yes"/>
  
  <xsl:import href="http://transpect.io/hub2tei/xsl/hub2tei.xsl"/>
  
  <xsl:template match="@docx2hub:*" mode="hub2tei:dbk2tei"/>
  <xsl:variable name="tei:floatingTexts-role" as="xs:string" select="'^[a-z]{1,3}box(grey|border)$'"/>
  
  <xsl:template match="html:table[tei:p]" mode="hub2tei:tidy">
    <figure>
      <xsl:copy>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
      <caption>
        <xsl:copy select="html:table/tei:p/node()"/>
      </caption>
    </figure>
  </xsl:template>
  
  <xsl:template match="html:table/tei:p" mode="hub2tei:tidy"/>
  
  <xsl:template name="title-stm">
    <xsl:if test="not(info/title)">
      <title/>
    </xsl:if>
    <xsl:apply-templates select="info/title,
                                 info/subtitle,
                                 info/author" mode="meta"/>
  </xsl:template>
  
  <xsl:template name="publication-stm">
    <xsl:if test="not(info/publisher)">
      <publisher>xerif</publisher>
    </xsl:if>
    <xsl:apply-templates select="info/publisher,
                                 info/legalnotice,
                                 info/copyright, info/pubdate" mode="meta"/>
    <!--<distributor>
      <address>
        <addrLine>
          <name type="organisation"/>
        </addrLine>
        <addrLine>
          <name type="place"/>
        </addrLine>
      </address>
    </distributor>
    <idno type="book"/>
    <date>
      <xsl:apply-templates select="/*/dbk:info/dbk:date" mode="#current"/>  
    </date>
    <pubPlace/>
    <publisher/>-->
  </xsl:template> 
  
  <xsl:template match="/*/info/title
                      |/*/info/subtitle" mode="meta">
    <title type="{local-name()}">
      <xsl:apply-templates mode="#current"/>
    </title>
  </xsl:template>
  
  <xsl:template match="/*/info/author" mode="meta">
    <author>
      <xsl:apply-templates select="personname/othername/node()" mode="#current"/>  
    </author>
  </xsl:template>
  
  <xsl:template match="/*/info/pubdate" mode="meta">
    <date>
      <xsl:apply-templates select="node()" mode="#current"/>  
    </date>
  </xsl:template>

  <xsl:template match="/*/info/publisher" mode="meta">
    <publisher>
      <xsl:apply-templates select="publishername/node()" mode="#current"/>
    </publisher>
  </xsl:template>
  
  <xsl:template match="/*/info/legalnotice" mode="meta">
    <availability status="restricted" rend="license">
      <licence target="{@xlink:href}">
        <xsl:apply-templates mode="#current"/>
      </licence>
    </availability>
  </xsl:template>
  
  <xsl:template match="/*/info/copyright" mode="meta">
    <availability status="restricted" rend="copyright">
      <xsl:apply-templates mode="#current"/>
    </availability>
  </xsl:template>
  
  <xsl:template match="/*/info/copyright/year
                      |/*/info/copyright/holder" mode="meta">
    <p rend="{local-name()}">
      <xsl:apply-templates mode="#current"/>
    </p>
  </xsl:template>

  <xsl:template match="/*/info" mode="hub2tei:dbk2tei">
    <front>
      <titlePage>
        <docTitle>
          <xsl:if test="not(title) and not(subtitle)">
            <titlePart/>
          </xsl:if>
          <xsl:apply-templates select="title, subtitle" mode="#current"/>  
        </docTitle>
      </titlePage>
      <xsl:apply-templates select="author, authorgroup" mode="#current"/>
      <xsl:if test="not(../toc)">
        <divGen type="toc" xml:id="toc">
          <head rend="toctitle">
            <xsl:choose>
              <xsl:when test="/*[@xml:lang[contains(., 'de')]]"><xsl:value-of select="'Inhalt'"/></xsl:when>
              <xsl:otherwise><xsl:value-of select="'Content'"/></xsl:otherwise>
            </xsl:choose>
          </head> 
        </divGen>
      </xsl:if>
      <xsl:apply-templates select="//*[local-name() = ('dedication', 'preface', 'colophon', 'toc')]" mode="#current">
        <xsl:with-param name="move-front-matter-parts" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </front>
  </xsl:template>
  
  <xsl:template match="/*/info/title
                      |/*/info/subtitle" mode="hub2tei:dbk2tei">
    <titlePart type="{local-name()}">
      <xsl:apply-templates mode="#current"/>
    </titlePart>
  </xsl:template>

  <xsl:template match="dbk:titleabbrev" mode="hub2tei:dbk2tei">
    <head>
      <xsl:attribute name="type" select="'titleabbrev'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </head>
  </xsl:template>
  
  <xsl:template name="series-stm">
    <xsl:if test="dbk:info[dbk:issuenum or dbk:volumenum or dbk:biblioid]">
      <seriesStmt>
        <title type="main"><xsl:apply-templates select="dbk:info/dbk:productname" mode="meta"/></title>
        <xsl:apply-templates select="dbk:info/dbk:volumenum, dbk:info/dbk:issuenum, dbk:info/dbk:biblioid" mode="#current"/>
      </seriesStmt>
    </xsl:if>
  </xsl:template>

  <xsl:template match="/*/info/productname" mode="meta">
     <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="dbk:keywordset[not(@role = ('hub', 'docProps', 'title-page'))]" mode="hub2tei:dbk2tei">
    <keywords>
      <xsl:if test="@xml:lang">
        <xsl:apply-templates select="@xml:lang" mode="#current"/>
      </xsl:if>
      <xsl:if test="@role">
        <xsl:attribute name="rendition" select="encode-for-uri(@role)"/>
      </xsl:if>
      <xsl:attribute name="corresp" select="concat('#', ancestor::*[self::dbk:chapter|self::dbk:bibliography][1]/@xml:id)"/>
      <xsl:for-each select="dbk:keyword">
        <term>
          <xsl:if test="@role[normalize-space()]">
            <xsl:attribute name="key" select="@role"/>
          </xsl:if>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang" select="@xml:lang"/>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="dbk:para">
              <xsl:for-each select="dbk:para">
                <seg type="remap-para"><xsl:apply-templates select="node()" mode="#current"/></seg>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="node()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </term>
      </xsl:for-each>
    </keywords>
  </xsl:template>

  <xsl:template match="dbk:biblioset[@role = 'chunk-metadata'][not(../..[self::dbk:section])]" mode="hub2tei:dbk2tei">
    <keywords rendition="chunk-meta">
      <xsl:if test="@xml:lang">
        <xsl:apply-templates select="@xml:lang" mode="#current"/>
      </xsl:if>
      <xsl:attribute name="corresp" select="concat('#', ancestor::*[self::dbk:chapter | self::dbk:bibliography | self::dbk:toc | self::dbk:part][1]/@xml:id)"/>
      <xsl:for-each select="*, ../(dbk:author|dbk:authorgroup/dbk:author)/(dbk:personname/othername[@role = 'tsmetacontributionauthorname'], dbk:affiliation/dbk:orgname, dbk:email, dbk:uri)">
        <term>
          <xsl:if test="@role">
            <xsl:message select="translate(key('natives', @role)/@native-name, '_', '-')"></xsl:message>
            <xsl:attribute name="key" select="if (key('natives', @role)[self::css:rule]) 
                                              then replace(translate(key('natives', @role)/@native-name, '_', '-'), '^[a-z]{1,3}[-_]?meta[-_]?', '')
                                              else 
                                                  if (@otherclass) 
                                                  then @otherclass 
                                                  else replace(@role, '^[a-z]{1,3}[-_]?meta[-_]?', '')"/>
          </xsl:if>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang" select="@xml:lang"/>
          </xsl:if>
          <xsl:value-of select="normalize-space(.)"/>
        </term>
      </xsl:for-each>
    </keywords>
  </xsl:template>

  <xsl:template match="*:textClass" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <xsl:copy-of select="//*:keywords[not(parent::*[self::*:textClass])]"/>
    </xsl:copy>  
  </xsl:template>

  <xsl:template match="*:profileDesc" mode="hub2tei:tidy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
        <xsl:apply-templates select="//*:argument[@rend = 'abstract']" mode="meta"/>
    </xsl:copy>  
  </xsl:template>

  <xsl:template match="*:argument[@rend = 'abstract']" mode="meta">
    <abstract>
      <xsl:if test="@xml:lang"><xsl:attribute name="xml:lang" select="@xml:lang"/></xsl:if>
      <xsl:attribute name="corresp" select="concat('#', ancestor::*:div[@type = ('article', 'chapter')][1]/@xml:id)"/>
      <xsl:apply-templates select="node() except *:head" mode="hub2tei:tidy"/>
    </abstract>
  </xsl:template>

  <xsl:template match="*:keywords[not(parent::*[self::*:textClass])] | dbk:biblioset" mode="hub2tei:tidy">
    <!-- bibliosets might be preserved in reviews, so discard them until further notuce-->
  </xsl:template>

  <xsl:template match="dbk:epigraph" mode="hub2tei:dbk2tei">
    <xsl:choose>
      <xsl:when test="parent::*[self::dbk:preface | self::dbk:info | self::dbk:abstract[parent::*[self::dbk:info]]] 
                      or 
                      (exists(preceding-sibling::*) and (every $pre in preceding-sibling::* satisfies $pre[self::dbk:title or self::dbk:info or self::dbk:epigraph]))">
        <epigraph>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </epigraph>
      </xsl:when>
      <xsl:otherwise>
        <floatingText type="motto">
          <body>
            <div1>
              <xsl:apply-templates select="node()" mode="#current"/>
            </div1>
          </body>
        </floatingText>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*:div[@rend = ('alternative-title', 'keywords')]" mode="hub2tei:tidy">
    <argument>
      <xsl:apply-templates select="@* except @type, node()" mode="#current"/>  
    </argument>
  </xsl:template>

</xsl:stylesheet>
