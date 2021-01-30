<?xml version="2.0" encoding="ISO-8859-1"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- <?xml version="1.0" encoding="ISO-8859-1"?> 
    <xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
-->
<!-- NOT DONE. Hard to do with replace(), etc. but those 2.0 functions
     aren't implemented in xsltproc. -->


<!-- ************************ root (proofs) template ***************  -->

<xsl:output method="text"/>

<xsl:template match="/proof">
strict digraph G {
 rotate=90;     // Landscape mode
 size="8,10.5"; // 8" x 10.5" (U.S. letter)
 <xsl:apply-templates/>
 <xsl:apply-templates select="clause"/> 
 }
</xsl:template>

<xsl:template match="clause">
  <xsl:value-of select="@id" /> [label="<xsl:value-of select="literal" />"];
</xsl:template>

</xsl:transform>

