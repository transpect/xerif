<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:css="http://www.w3.org/1996/css" 
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:hub2tei="http://transpect.io/hub2tei"
  xmlns:tei2html="http://transpect.io/tei2html"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml" 
  xmlns:hub="http://transpect.io/hub"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:tr="http://transpect.io"
  xmlns="http://www.w3.org/1999/xhtml"  
  exclude-result-prefixes="css dbk xs tei2html hub2htm tei hub html epub hub2tei tr"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  version="2.0">
  
  <xsl:import href="http://transpect.io/tei2html/xsl/tei2html.xsl"/>
  <xsl:import href="http://this.transpect.io/a9s/common/xsl/shared-variables.xsl"/>
  
  <xsl:template match="head[matches(@type, 'titleabbrev')] | note[@type = 'comment']" mode="tei2html">
    <!--https://redmine.le-tex.de/issues/13166-->
  </xsl:template>
  
  <xsl:template match="css:rule[@native-name[matches(., '^[a-z]{1,3}_figure')]]/@*[name() = ('css:font-style', 'css:font-weight')]" mode="epub-alternatives">
    <!-- avoid wrapping of elements in img tags -->
  </xsl:template>

</xsl:stylesheet>