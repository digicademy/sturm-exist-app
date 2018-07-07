<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : The website header with branding and home links.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.1.0 
 : @licence MIT
:)
-->

    <xsl:template name="branding">
        <div class="branding">
            <a href="/">
                <h1 class="title">
                    <span class="tighter">DER</span><xsl:text> </xsl:text><span class="tight">ST</span><span class="normal">URM</span>
                </h1>
                <h2 class="subtitle">Digitale Quellenedition zur Geschichte der internationalen Avantgarde</h2>
            </a>
        </div>
    </xsl:template>

</xsl:stylesheet>