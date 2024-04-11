<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:html="http://www.w3.org/1999/xhtml"  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:tr="http://transpect.io" exclude-result-prefixes="xs c epub"
  version="2.0">

  <xsl:variable name="edition_meta" as="element(product)?" select="(collection()/*:product)[1]"/>
  <xsl:variable name="metadata" as="document-node()?" select="collection()[/*:ONIXmessage]"/>
  <xsl:variable name="images" select="collection()[c:directory]"/>
  <xsl:variable name="ebook_meta" as="document-node(element(product))*" select="collection()[product]"/>

  
  <xsl:variable name="htmlinput" as="document-node(element(html:html))*">
    <xsl:choose>
      <xsl:when test="not($extract = '') and matches($extract, '^percentage:\s*([\d.]+|auto)$')">
        <xsl:document>
          <xsl:apply-templates select="collection()[/html:html][1]" mode="extract-percentage">
            <xsl:with-param name="percentage" select="if (matches($extract, '^percentage:\s*auto$'))
              then tr:auto-extract-length(string-length(collection()/html:html[1]/html:body))
              else number(replace($extract, '^percentage:\s*([\d.]+)$', '$1'))" tunnel="yes" as="xs:double"/>
          </xsl:apply-templates>
        </xsl:document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="collection()[/html:html]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="extract" as="xs:string?" select="$edition_meta/@tr:extract"/>
  
  <xsl:param name="debug-dir-uri" as="xs:string?"/>
  <xsl:param name="s9y1" as="xs:string?"/>
  <xsl:param name="s9y2" as="xs:string?"/>
  <xsl:param name="s9y3" as="xs:string?"/>
  <xsl:param name="s9y4" as="xs:string?"/>
  <xsl:param name="s9y5" as="xs:string?"/>
  <xsl:param name="s9y6" as="xs:string?"/>
  <xsl:param name="s9y7" as="xs:string?"/>
  <xsl:param name="s9y8" as="xs:string?"/>
  <xsl:param name="s9y9" as="xs:string?"/>
  <xsl:param name="s9y1-path" as="xs:string?"/>
  <xsl:param name="s9y2-path" as="xs:string?"/>
  <xsl:param name="s9y3-path" as="xs:string?"/>
  <xsl:param name="s9y4-path" as="xs:string?"/>
  <xsl:param name="s9y5-path" as="xs:string?"/>
  <xsl:param name="s9y6-path" as="xs:string?"/>
  <xsl:param name="s9y7-path" as="xs:string?"/>
  <xsl:param name="s9y8-path" as="xs:string?"/>
  <xsl:param name="s9y9-path" as="xs:string?"/>
  <xsl:param name="s9y1-role" as="xs:string?"/>
  <xsl:param name="s9y2-role" as="xs:string?"/>
  <xsl:param name="s9y3-role" as="xs:string?"/>
  <xsl:param name="s9y4-role" as="xs:string?"/>
  <xsl:param name="s9y5-role" as="xs:string?"/>
  <xsl:param name="s9y6-role" as="xs:string?"/>
  <xsl:param name="s9y7-role" as="xs:string?"/>
  <xsl:param name="s9y8-role" as="xs:string?"/>
  <xsl:param name="s9y9-role" as="xs:string?"/>
  
  <xsl:param name="toc-levels" as="xs:string?"/>

  <xsl:variable name="items" as="xs:string*" 
    select="($s9y1, $s9y2, $s9y3, $s9y4, $s9y5, $s9y6, $s9y7, $s9y8, $s9y9)"/>
  <xsl:variable name="paths" as="xs:string*" 
    select="($s9y1-path, $s9y2-path, $s9y3-path, $s9y4-path, $s9y5-path, $s9y6-path, $s9y7-path, $s9y8-path, $s9y9-path)"/>
  <xsl:variable name="roles" as="xs:string*" 
    select="($s9y1-role, $s9y2-role, $s9y3-role, $s9y4-role, $s9y5-role, $s9y6-role, $s9y7-role, $s9y8-role, $s9y9-role)"/>
  <xsl:variable name="work-path" as="xs:string?" select="$paths[position() = index-of($roles, 'work')]"/>
  <xsl:variable name="series" as="xs:string?" select="$items[position() = index-of($roles, 'production-line')]"/>
  <xsl:variable name="work" as="xs:string?" select="$items[position() = index-of($roles, 'work')]"/>
	<xsl:variable name="publisher-path" as="xs:string?" select="$paths[position() = index-of($roles, 'publisher')]"/>
  
  <xsl:param name="qa-run" select="'false'"/>
  <!-- internal conversion for QA purposes, will render some errors -->
  <xsl:variable name="is-qa-run" as="xs:boolean" select="$qa-run = 'true'"/>

  <!-- currently not in use: --> 
  <xsl:variable name="no-dedicated-info" as="xs:boolean" select="false()"/>

  <xsl:key name="by-id" match="*[@id | @xml:id]" use="@id | @xml:id"/>
  <xsl:key name="target-by-href" match="*[@id | @xml:id]" use="@id | @xml:id"/>
  
  <xsl:variable name="restructured-body-parts" select="$htmlinput[1]/html:html/html:body/*[@epub:type = 'copyright-page'], 
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'fulltitle'],
                                                       $htmlinput[1]/html:html/html:body/*[@epub:type = 'toc']" as="element(*)*"/>
  <xsl:variable name="language" as="xs:string?" select="(
                                                         $edition_meta/language/b252,
                                                         'ger'
                                                         )[1]"/>
  
  
  <xsl:template name="main">
    <html>
      <head>
        <xsl:call-template name="htmltitle"/>
        <xsl:apply-templates select="$ebook_meta" mode="meta"/>
        <xsl:message>
          <xsl:apply-templates select="$ebook_meta" mode="meta"/>
        </xsl:message>
        
        <xsl:apply-templates
          select="$htmlinput[1]/html:html/html:head/node() except ($htmlinput[1]/html:html/html:head/html:title, $htmlinput[1]/html:html/html:head/html:meta[@name = 'lang'])"/>
      </head>
      <!-- will be generated: -->
      <xsl:call-template name="body">
        <xsl:with-param name="_work-lang" as="xs:string" select="$language" tunnel="yes"/>
      </xsl:call-template>
    </html>
  </xsl:template>

  <xsl:template match="*[@href][starts-with(@href, '#')]
                               [not(key('target-by-href', replace(@href, '^#', ''), $htmlinput))]
                               [not($extract = '') and matches($extract, '^percentage:\s*([\d.]+|auto)$')]" priority="2">
    <!-- discard links without target in sample html -->
    <xsl:choose>
      <xsl:when test="ancestor::nav or ancestor::*[@epub:type = ('toc', 'landmarks', 'page-list')]">
        <a class="no-link">
          <xsl:apply-templates mode="#current"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Metadata tags-->
  
  <xsl:template match="product" mode="meta">
    <xsl:apply-templates select="(relatedproduct/productidentifier[b221[. = '15']], title[b202 = '01'])" mode="#current"/>
    <meta name="DC.creator" content="{string-join(contributor[b035 = 'A01']/b037, '; ')}"/>
    <!-- authors in the pattern name, surname; name, surname-->
    <xsl:apply-templates select="(publisher/b081, b003, language[b253 = '01'])" mode="#current"/>
    <meta name="DC.subject" content="{string-join(mainsubject/b070,  '; ')}"/>
  </xsl:template>
  
  <xsl:template match="b003" mode="meta">
    <meta name="DC.date">
      <xsl:attribute name="content" select="replace(., '^(\d{4})(\d{2})(\d{2})$', '$1-$2-$3')"/>
    </meta>
  </xsl:template>
  
  <xsl:template match="publisher/b081" mode="meta">
    <meta name="DC.publisher" content="{.}"/>
  </xsl:template>
  
  <xsl:template match="relatedproduct/productidentifier[b221[. = '15']]" mode="meta">
    <meta name="DC.identifier">
      <xsl:attribute name="content" select="replace(./b244, '^(\d{3})(\d)(\d{3})(\d{5})(\d)$', '$1-$2-$3-$4-$5')"/>
    </meta>
  </xsl:template>
  
  <xsl:template match="title[b202[. = '01']]" mode="meta">
    <meta name="DC.title" content="{b203}"/>
  </xsl:template>
  
  <xsl:template match="language[b253 = '01']" mode="meta">
    <meta name="lang" content="{if (b252 = 'eng') then 'en' else 'de'}"/>
  </xsl:template> 
  
  <xsl:template name="cover">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <div id="epub-cover-image-container" epub:type="cover">
      <xsl:if test="$_content">
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="'cover'"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="not($_content)">
        <h2 class="blind" title="{if ($_work-lang = 'eng') then $cover-heading-title_en else $cover-heading-title_de}"/>
      </xsl:if>
      <xsl:if test="$images//c:directory[@name = 'cover']/c:file">
        <xsl:variable name="consolidated-series" select="if ($series = 'standard') then '' else concat('_', $series)" as="xs:string?"/>
        <img src="{concat($work-path, 'images/cover/', xs:string($images//c:directory[@name = 'cover']/c:file[1]/@name))}" alt="Cover"/>
      </xsl:if>
    </div>
  </xsl:template>
  
  <xsl:template name="title-page">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'fulltitle']">
      <div class="title" xmlns:epub="http://www.idpf.org/2007/ops" epub:type="fulltitle">
        <xsl:copy-of select="$restructured-body-parts[@epub:type = 'fulltitle']/@*" copy-namespaces="no"/>
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      <xsl:if test="not($_content)">
        <h2 class="blind" title="{if ($_work-lang = 'eng') then $titlepage-heading-title_en else $titlepage-heading-title_de}"/>
      </xsl:if>
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'fulltitle']/node()"/>
    </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="impress">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'copyright-page']">
    <div>
      <xsl:copy-of select="$restructured-body-parts[@epub:type = 'copyright-page']/@*" copy-namespaces="no"/>
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      <xsl:if test="not($_content)">
        <h1 class="blind" title="{if ($_work-lang = 'eng') then $imprint-heading-title_en else $imprint-heading-title_de}"/>
      </xsl:if>
      <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'copyright-page']/node()"/>
    </div>
    </xsl:if>
  </xsl:template>
  
  
  
  <xsl:template name="about-author">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:bio']">
      <div class="{$restructured-body-parts[@epub:type = 'tr:bio']/@class}" epub:type="tr:bio" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:bio'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Vita_U')] or local-name() = ('h1', 'h2')]) ">
         <xsl:call-template name="_heading">
           <xsl:with-param name="content" select="$_content"/>
           <xsl:with-param name="class" select="$_content/@class"/>
           <xsl:with-param name="prelim" select="$no-dedicated-info"/>
         </xsl:call-template>
       </xsl:if>
       <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:bio']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="about-book">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:about-the-book']">
      <div class="{$restructured-body-parts[@epub:type = 'tr:about-the-book']/@class}" epub:type="tr:about-the-book" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:about-the-book'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Buch_U')] or local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:about-the-book']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="about-series">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'tr:additional-info']">
      <div class="{$restructured-body-parts[@epub:type = 'tr:additional-info']/@class}" epub:type="tr:additional-info" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'tr:additional-info'][1]/descendant-or-self::*[1][self::html:para[matches(@class, 'Info_Reihe_U')] or local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'tr:additional-info']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
 
  <xsl:template name="dedication">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'dedication']">
      <div class="{$restructured-body-parts[@epub:type = 'dedication']/@class}" epub:type="dedication" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'dedication'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) ">
         <xsl:call-template name="_heading">
           <xsl:with-param name="content" select="$_content"/>
           <xsl:with-param name="class" select="$_content/@class"/>
           <xsl:with-param name="prelim" select="$no-dedicated-info"/>
         </xsl:call-template>
       </xsl:if>
        <xsl:if test="not($_content) and not($restructured-body-parts[@epub:type = 'dedication'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')])">
          <h1 title="{if ($_work-lang = 'eng') then $dedication-heading-title_en else $dedication-heading-title_de}"/>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'dedication']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="motto">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = 'epigraph']">
      <div class="{$restructured-body-parts[@epub:type = 'epigraph']/@class}" epub:type="epigraph" xmlns:epub="http://www.idpf.org/2007/ops">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@epub:type = 'epigraph'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($_content) and not($restructured-body-parts[@epub:type = 'epigraph'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')])">
          <h1 title="{if ($_work-lang = 'eng') then $motto-heading-title_en else $motto-heading-title_de}"/>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'epigraph']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="frontispiece">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@class = 'frontispiz preface']">
      <div class="frontispiz preface">
        <xsl:if test="(matches($_content, '\S') or $_content//@title) and not($restructured-body-parts[@class = 'frontispiz preface'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')]) ">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="$_content/@class"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($_content) and not($restructured-body-parts[@class = 'frontispiz preface'][1]/descendant-or-self::*[1][local-name() = ('h1', 'h2')])">
          <h1 title="{if ($_work-lang = 'eng') then $frontispiece-heading-title_en else $frontispiece-heading-title_de}"/>
        </xsl:if>
        <xsl:apply-templates select="$restructured-body-parts[@class = 'frontispiz preface']/node()"/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <!-- title of the html document-->
  <xsl:template name="htmltitle" as="element(html:title)">
    <title>
      <xsl:value-of select="string-join($htmlinput[1]/html:html/html:body//html:div[matches(@class, 'title-page')][1]/html:p[matches(@class, 'HT_Titel')][1]//text(), '')"/>
    </title>
  </xsl:template>

  <xsl:template match="html:meta[@name = 'source-basename']">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="name" select="'identifier'"/>
      <xsl:attribute name="content" select="replace(@content, '^(UV_)?(\d+)(_\d+)?_.*$', '$1$2$3')"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="htmlinput-body">
    <xsl:apply-templates
      select="$htmlinput[1]/html:html/html:body/node() except ($htmlinput[1]/html:html/html:body/*:nav, $restructured-body-parts)"/>
    <xsl:apply-templates select="$htmlinput[1]/html:html/html:body/*:nav" mode="discard-toc"/>
  </xsl:template>

  <!-- merge-info is a mode that, while processing a meta-titles/webtitle element, pulls in information
       from the meta-roles and meta-persons tables -->
  <xsl:template match="* | @*" mode="merge-info title-page default">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

 
  <xsl:template name="toc">
    <xsl:param name="_content" as="node()*"/>
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <xsl:if test="$restructured-body-parts[@epub:type = ('toc')]">
      <div class="toc" id="toc" xmlns:epub="http://www.idpf.org/2007/ops" epub:type="toc">
    <xsl:choose>
       <xsl:when test="matches($_content, '\S') and not($restructured-body-parts[@epub:type = ('toc')]/*[local-name() = ('h1', 'h2')])">
          <xsl:call-template name="_heading">
            <xsl:with-param name="content" select="$_content"/>
            <xsl:with-param name="class" select="'toc'"/>
            <xsl:with-param name="prelim" select="$no-dedicated-info"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="not($_content) and not($restructured-body-parts[@epub:type = ('toc')]/*[local-name() = ('h1', 'h2')])">
            <h1 class="Frontmatter_Ueberschriften_U1_Frontmatter"><xsl:value-of select="if ($_work-lang = 'eng') then $toc-heading-title_en else $toc-heading-title_de"/></h1>
          </xsl:if>
        </xsl:otherwise>
        </xsl:choose>
       
        <xsl:apply-templates select="$restructured-body-parts[@epub:type = 'toc']/node()"/>
        <xsl:if test="$htmlinput[1]//*[@epub:type = ('footnote', 'rearnote')]">
          <p class="toc1-nolabel"><a href="#footnotes"><xsl:value-of select="if ($_work-lang = 'eng') then $footnote-heading-title_en else $footnote-heading-title_de"/></a></p>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- Footnotes -->
  <xsl:template match="*:div[@class = 'notes'] | *:section[@class='footnotes']">
    <xsl:param name="_work-lang" as="xs:string?" tunnel="yes"/>
    <xsl:element name="{concat('h', $footnote-heading-level)}">
      <xsl:attribute name="id" select="'footnotes'"/>
      <xsl:attribute name="title" select="if ($_work-lang = 'eng') then $footnote-heading-title_en else $footnote-heading-title_de"/>
    </xsl:element>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="backmatter">
    <xsl:param name="_content"/>
    <xsl:if test="$htmlinput//@epub:type = ('footnote', 'rearnote')">
      <div class="back">
        <xsl:call-template name="_heading">
          <xsl:with-param name="content" select="$_content"/>
          <xsl:with-param name="class" select="$_content/@class"/>
          <xsl:with-param name="prelim" select="$no-dedicated-info"/>
        </xsl:call-template>
      </div>
      <xsl:apply-templates select="$htmlinput//*[@epub:type = ('footnote', 'rearnote')]"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[matches(./local-name(), '^h\d')]" mode="discard-toc"/>
  <xsl:template match="html:p[matches(@class, 'toc')]" mode="discard-toc"/>
  <xsl:template match="*:nav" mode="discard-toc"/>

 
   <xsl:template name="_heading">
    <xsl:param name="content" as="node()*"/>
    <xsl:param name="class" as="xs:string?"/>
    <xsl:param name="prelim" as="xs:boolean"/>
    <xsl:apply-templates select="$content[matches(*[1]/local-name(), '^h\d')] except @class">
      <xsl:with-param name="class"
        select="string-join(($class, if ($prelim) then 'prelim' else '', if ($content/@class) then $content/@class else ''), ' ')"
      />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="info_body | impress">
    <xsl:choose>
      <xsl:when test="*:p">
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <p class="noindent">
          <xsl:apply-templates mode="#current"/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="tr:index-of" as="xs:integer*">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="node" as="node()?"/>
    <xsl:sequence select="index-of(for $n in $nodes return generate-id($n), generate-id($node))"/>
  </xsl:function>

  <xsl:template match="*:br/@clear" mode="#all"/>

  <xsl:template match="@* | *">
    <xsl:param name="class" as="xs:string?"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$class">
        <xsl:attribute name="class" select="string-join((@class, $class), ' ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*" mode="extract-percentage">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="node()" mode="extract-percentage">
    <xsl:param name="split-para" as="element(*)?" tunnel="yes"/>
    <xsl:if test="not($split-para) or . &lt;&lt; $split-para">
      <!-- empty elements are invalid sometimes-->
      <xsl:if test="not(tr:is-split-para-first-descendant(., $split-para))">
        <xsl:copy>
          <xsl:apply-templates select="@*, node()" mode="#current"/>
        </xsl:copy>
      </xsl:if>
    </xsl:if>
  	<xsl:if test=". is $split-para">
  		<xsl:call-template name="extract-info"/>
  	</xsl:if>
  </xsl:template>
  
  <xsl:template name="extract-info">
  	<!-- a project can include some texts or links in the end.-->
  </xsl:template>
	
  <xsl:function name="tr:is-split-para-first-descendant" as="xs:boolean">
    <xsl:param name="elt" as="node()?"/>
    <xsl:param name="split-para" as="element(*)?"/>
    <xsl:variable name="first-node" select="$elt/node()[1]"/>
    <xsl:choose>
      <xsl:when test="$first-node is $split-para">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$first-node &lt;&lt; $split-para">
        <xsl:sequence select="tr:is-split-para-first-descendant($first-node, $split-para)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="html:head" mode="extract-percentage">
    <xsl:param name="percentage" as="xs:double" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      <meta name="sample-percentage" content="{$percentage}"/>
      <meta name="sample-instruction" content="{$extract}"/>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="tr:auto-extract-length" as="xs:double">
    <xsl:param name="text-length" as="xs:integer"/>
    <xsl:variable name="offset" select="$text-length + 1e5" as="xs:double"/>
    <xsl:variable name="factor" select="4e-6 * $offset" as="xs:double"/>
    <xsl:variable name="exp" select="$factor * $factor * $factor * $factor" as="xs:double"/>
    <xsl:variable name="result" select="5 + 20 div (1 + $exp)" as="xs:double"/>
    <xsl:sequence select="$result" />
  </xsl:function>
  

  <xsl:template match="html:body" mode="extract-percentage">
    <xsl:param name="percentage" as="xs:double" tunnel="yes"/>
    <xsl:variable name="cutoff-length" as="xs:double" select="0.01 * $percentage * string-length(.)"/>
    <xsl:variable name="split-para" select="(.//html:p[tr:start-pos(., current()) le $cutoff-length])[last()]" as="element(html:p)?"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*" mode="#current">
        <xsl:with-param name="split-para" select="$split-para" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tr:start-pos" as="xs:double">
    <xsl:param name="elt" as="element(*)"/>
    <xsl:param name="ancestor" as="element(*)"/>
    <xsl:sequence select="sum(for $t in $ancestor//text()[. &lt;&lt; $elt] return string-length($t))"/>
  </xsl:function>
  
</xsl:stylesheet>