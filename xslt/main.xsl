<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!--
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Main XSL stylesheet for the HTML transformation from which all other
 : transformations are initialized. Each building block of the website is
 : cleanly encapsulated in its own XLS stylesheet with an according name.
 : Check the xsl:includes below.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:include href="version.xsl"/>
    <xsl:include href="elements.xsl"/>
    <xsl:include href="head.xsl"/>
    <xsl:include href="branding.xsl"/>
    <xsl:include href="toolbar.xsl"/>
    <xsl:include href="navigation.xsl"/>
    <xsl:include href="page.xsl"/>
    <xsl:include href="letter.xsl"/>
    <xsl:include href="register.xsl"/>
    <xsl:include href="entity.xsl"/>
    <xsl:include href="footer.xsl"/>

    <xsl:param name="transformation"/>
    <xsl:param name="sender"/>
    <xsl:param name="senderKey"/>
    <xsl:param name="senderPrefName"/>
    <xsl:param name="dateString"/>
    <xsl:param name="relativeToAppBase"/>
    <xsl:param name="sourceDocPath"/>
    <xsl:param name="targetDir"/>
    <xsl:param name="idno"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" xml:space="preserve"/>

    <!-- identity transform: copy source nodes to target document -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- suppress some XML parts -->
    <xsl:template match="//tei:teiHeader"/>
    <xsl:template match="//tei:sourceDoc"/>
    <xsl:template match="//tei:facsimile"/>

    <!-- html page template -->
    <xsl:template match="//tei:text">
        <html lang="de">

            <xsl:variable name="title">
                <xsl:value-of select="string-join(//tei:title[1], '')"/>
                <xsl:text> : DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde</xsl:text>
            </xsl:variable>

            <xsl:call-template name="head">
                <xsl:with-param name="title" select="$title"/>
            </xsl:call-template>

            <body id="{replace($idno, '.xml', '')}">
                <div class="container">
                    <header class="row header">
                        <xsl:call-template name="branding"/>
                        <xsl:call-template name="navigation"/>
                    </header>

                    <main class="row content hyphenate" id="main">
                        <xsl:choose>
                            <xsl:when test="$transformation eq 'letter'">
                                <xsl:if test="contains($idno, 'v')">
                                    <xsl:call-template name="version-note"/>
                                </xsl:if>
                                <xsl:call-template name="department"/>
                                <xsl:call-template name="toolbar"/>
                                <xsl:call-template name="letter">
                                    <xsl:with-param name="dateString" select="$dateString"/>
                                </xsl:call-template>
                                <section class="twelve columns">
                                    <xsl:call-template name="version-infobox"/>
                                </section>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'lettersRegister'">
                                <xsl:call-template name="register"/>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'personsRegister'">
                                <xsl:call-template name="register"/>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'placesRegister'">
                                <xsl:call-template name="register"/>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'worksRegister'">
                                <xsl:call-template name="register"/>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'person'">
                                <xsl:call-template name="entity"/>
                            </xsl:when>
                            <xsl:when test="$transformation eq 'generatedPage'">
                                <xsl:call-template name="page"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:if test="contains($idno, 'v')">
                                    <xsl:call-template name="version-note"/>
                                </xsl:if>
                                <xsl:call-template name="page"/>
                                <section class="twelve columns">
                                    <xsl:call-template name="version-infobox"/>
                                </section>
                            </xsl:otherwise>
                        </xsl:choose>
                    </main>

                    <footer class="row footer">
                        <xsl:call-template name="footer"/>
                    </footer>
                </div>
                <script src="{$relativeToAppBase}js/jquery-1.12.4.min.js"/>
                <script src="{$relativeToAppBase}js/jquery.magnific-popup.min.js"/>
                <script src="{$relativeToAppBase}js/lightbox.js"/>
                <script src="{$relativeToAppBase}js/highlight.pack.js"/>
                <script>hljs.initHighlightingOnLoad();</script>
                <script src="{$relativeToAppBase}js/letters.js"/>
                <xsl:if test="//tei:publicationStmt/tei:idno[@type = 'file'] = 'orte.xml'">
                    <script src="https://unpkg.com/leaflet@1.3.1/dist/leaflet.js" integrity="sha512-/Nsx9X4HebavoBvEBuyp3I7od5tA0UzAxs+j83KgC8PU0kgB4XiK4Lfe4y4cgBtaRJQEIFCW+oC506aPT2L1zw==" crossorigin=""/>
                    <script src="{$relativeToAppBase}js/map.js"/>
                </xsl:if>
                <script src="{$relativeToAppBase}js/menu.js"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
