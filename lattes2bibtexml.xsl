<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:bibtex="http://bibtexml.sf.net/">

  <xsl:template match="/">
    <bibtex:file xmlns:bibtex="http://bibtexml.sf.net/">
      <xsl:apply-templates select = "CURRICULO-VITAE"/>
    </bibtex:file>
  </xsl:template>

  <xsl:template match="CURRICULO-VITAE">
    <xsl:apply-templates  select = "PRODUCAO-BIBLIOGRAFICA"/>
  </xsl:template>

  <xsl:template match="PRODUCAO-BIBLIOGRAFICA">
    <xsl:apply-templates select = "ARTIGOS-PUBLICADOS"/>
  </xsl:template>

  <xsl:template match="ARTIGOS-PUBLICADOS/ARTIGO-PUBLICADO">
    <bibtex:entry>
      <bibtex:article>
	<xsl:apply-templates select = "DADOS-BASICOS-DO-ARTIGO"/>
	<xsl:apply-templates select = "DETALHAMENTO-DO-ARTIGO"/>
      </bibtex:article>
    </bibtex:entry>
  </xsl:template>

 <xsl:template match="DADOS-BASICOS-DO-ARTIGO">
   <bibtex:title>
     <xsl:apply-templates select="@TITULO-DO-ARTIGO"/>
   </bibtex:title>
   <bibtex:year>
     <xsl:apply-templates select="@ANO-DO-ARTIGO"/>
   </bibtex:year>
 </xsl:template>

<xsl:template match="DETALHAMENTO-DO-ARTIGO">
  <bibtex:journal>
     <xsl:apply-templates select="@TITULO-DO-PERIODICO-OU-REVISTA"/>
  </bibtex:journal>
  <bibtex:volume>
    <xsl:apply-templates select="@VOLUME"/>
  </bibtex:volume>
</xsl:template>

</xsl:stylesheet>
