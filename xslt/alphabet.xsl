<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt functx" version="2.0">

<!-- 
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Alphabet navigation for the different registers (places, persons, works).
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:template name="alphabet">
        <ul class="alphabet">
            <xsl:for-each select="//tei:head">
                <li class="letter">
                    <a class="black button" href="#letter-{lower-case(.)}">
                        <xsl:value-of select="."/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>

</xsl:stylesheet>