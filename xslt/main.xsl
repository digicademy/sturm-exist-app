<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Main XSL stylesheet for the HTML transformation from which all other 
 : transformations are initialized. Each building block of the website is
 : cleanly encapsulated in its own XLS stylesheet with an according name.
 : Check the xsl:includes below.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

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
                <xsl:text> : Der STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde</xsl:text>
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
                                <div class="department">
                                    <h3>
                                        <a href="{$relativeToAppBase}quellen/briefe.html">Abteilung I, Briefe</a>
                                    </h3>
                                    <p>
                                        <strong>Dokumenttyp: </strong> 
                                        <xsl:choose>
                                            <xsl:when test="$sourcetype = 'postcard'">Postkarte</xsl:when>
                                            <xsl:when test="$sourcetype = 'militaryMail'">Feldpost</xsl:when>
                                            <xsl:when test="$sourcetype = 'telegram'">Telegramm</xsl:when>
                                            <xsl:otherwise>Brief</xsl:otherwise>
                                        </xsl:choose>
                                    </p>
                                    <p>
                                        <strong>Chronologie: </strong> 
                                        <a href="{concat($relativeToAppBase, 'quellen/briefe/chronologie.html')}">Briefe von 1914 bis 1915 <xsl:if test="contains($targetDir, 'chronologie')"><span title="Aktuell gewählte Ansicht"> ←</span></xsl:if></a>
                                    </p>
                                    <p>
                                        <strong>Briefwechsel: </strong> 
                                        <a href="{concat($relativeToAppBase, 'quellen/briefe/', lower-case(substring($idno, 15, 3)), '.html')}">
                                            <xsl:value-of select="concat(//tei:correspAction[@type = 'sent']/tei:persName, ' an Herwarth Walden')"/>
                                            <xsl:if test="not(contains($targetDir, 'chronologie'))">
                                                <span title="Aktuell gewählte Ansicht"> ←</span>
                                            </xsl:if>
                                        </a>
                                    </p>
                                    <p class="msidentifier">
                                        <strong>Quelle: </strong>Staatsbibliothek zu Berlin, Handschriftenabteilung, Sturm-Archiv I, <xsl:value-of select="$senderPrefName"/>, <a class="external" href="{$uri}"><xsl:value-of select="$folios"/></a>
                                    </p>
                                </div>
                                <xsl:call-template name="toolbar"/>
                                <xsl:call-template name="letter">
                                    <xsl:with-param name="dateString" select="$dateString"/>
                                </xsl:call-template>
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
                            <xsl:otherwise>
                                <xsl:call-template name="page"/>
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
                <!-- Piwik -->
                <script type="text/javascript">
                    var _paq = _paq || [];
                    _paq.push(['trackPageView']);
                    _paq.push(['enableLinkTracking']);
                    (function() {
                    var u="//stats.adwmainz.net/";
                    _paq.push(['setTrackerUrl', u+'piwik.php']);
                    _paq.push(['setSiteId', 29]);
                    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
                    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
                    })();
                </script>
                <noscript>
                    <p>
                        <img src="//stats.adwmainz.net/piwik.php?idsite=29" style="border:0;" alt=""/>
                    </p>
                </noscript>
                <!-- End Piwik Code -->
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>