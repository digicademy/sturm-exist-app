<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Stylesheet for the transformation of letters from the STURM-Archive.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:param name="sourcetype"/>
    <xsl:param name="repository"/>
    <xsl:param name="folios"/>
    <xsl:param name="uri"/>
    <xsl:param name="dateISO"/>
    <xsl:param name="placeName"/>
    <xsl:param name="placeRef"/>
    <xsl:param name="doi"/>

    <xsl:template name="letter">
        <xsl:param name="dateString"/>
        <section class="eight columns maincontent">
            <div class="{$sourcetype}">

                <h4 class="dateline">
                    <xsl:if test="$dateString ne ''"> [<time datetime="{$dateISO}">
                            <xsl:value-of select="$dateString"/>
                        </time>
                        <xsl:if test="//tei:correspAction[@type='sent']/tei:date/@notBefore"> oder später</xsl:if> <xsl:text> / </xsl:text>
                    </xsl:if>
                    <xsl:if test="$placeName">
                        <span class="locality">
                            <xsl:choose>
                                <xsl:when test="$placeName eq 'Unknown'">
                                    <xsl:value-of select="replace($placeName, 'Unknown', 'unbekannter Ort')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="../../../register/orte/{//tei:correspAction[@type='sent']/tei:placeName/@key}.html" class="locality">
                                        <xsl:value-of select="$placeName"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>]
                    </xsl:if>
                </h4>

                <xsl:for-each select="//tei:text/tei:body/tei:div">
                    <div class="{@type}">
                        <xsl:apply-templates select="./child::node()"/>
                    </div>
                </xsl:for-each>

                <xsl:if test="//tei:note">
                    <xsl:call-template name="apparatus"/>
                </xsl:if>

            </div>
        </section>
        <section class="four columns sidebar">
            <h3 class="facsimile-header">Faksimiles dieser Quelle</h3>
            <div class="facsimile mfp-lightbox">
                <xsl:call-template name="facsimile"/>
            </div>
            <div class="dfg-viewer">
                <a target="_blank" href="http://dfg-viewer.de/show/?set%5Bmets%5D={$metadata}&amp;set%5Bimage%5D=1" class="button black external">
                    DFG Viewer
                </a>
            </div>
            <p class="rights">
                Bestandshaltende Institution: <a href="http://staatsbibliothek-berlin.de/">Staatsbibliothek zu Berlin - Preußischer Kulturbesitz</a>. Lizenz: Public Domain.
            </p>
        </section>
    </xsl:template>

    <!-- structural templates -->

    <xsl:template name="department">
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
                <a href="{concat($relativeToAppBase, 'quellen/briefe/chronologie.html')}">
                    Briefe von 1914 bis 1922 <xsl:if test="contains($targetDir, 'chronologie')">
                        <span title="Aktuell gewählte Ansicht"> ←</span>
                    </xsl:if>
                </a>
            </p>
            <p>
                <strong>Absender/in: </strong> 
                <a href="{concat($relativeToAppBase, 'quellen/briefe/', lower-case(substring($idno, 15, 3)), '.html')}">
                    <xsl:value-of select="concat(//tei:correspAction[@type = 'sent']/tei:persName, ' an ', //tei:correspAction[@type = 'received']/tei:persName)"/>
                    <xsl:if test="not(contains($targetDir, 'chronologie'))">
                        <span title="Aktuell gewählte Ansicht"> ←</span>
                    </xsl:if>
                </a>
            </p>
            <p class="msidentifier">
                <strong>Quelle: </strong>Staatsbibliothek zu Berlin, Handschriftenabteilung, Sturm-Archiv I, <xsl:value-of select="$senderPrefName"/>, 
                <a class="external" href="{$uri}">
                    <xsl:value-of select="$folios"/>
                </a>
            </p>
        </div>
    </xsl:template>

    <xsl:template name="apparatus">
        <xsl:if test="//tei:text//tei:note">
        <div class="aparatus">
            <xsl:call-template name="footnotes"/>
        </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="facsimile">
        <xsl:for-each select="//tei:facsimile//tei:graphic">
            <figure>
                <figcaption>
                    <xsl:value-of select="@n"/>
                </figcaption>
                <a href="{@url}" title="Blatt {@n}">
                    <img src="{@url}" alt="Blatt {@n}"/>
                </a>
            </figure>
        </xsl:for-each>
    </xsl:template>

    <!-- matching templates -->

    <xsl:template match="tei:opener">
        <div class="opener">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:opener/tei:dateline">
        <h6 class="date">
            <xsl:apply-templates select="node()"/>
        </h6>
    </xsl:template>

    <xsl:template match="tei:opener/tei:salute">
        <h5 class="salute">
            <xsl:apply-templates select="node()"/>
        </h5>
    </xsl:template>

    <xsl:template match="tei:closer">
        <div class="closer">
            <p>
                <xsl:apply-templates select="//tei:text/tei:body/tei:div/tei:closer/child::node()"/>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="tei:closer/tei:dateline">
        <p>
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>

    <xsl:template match="tei:postscript">
        <div class="postscript">
            <xsl:apply-templates select="//tei:text/tei:body/tei:div/tei:postscript/child::node()"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:pb">
        <span id="{@xml:id}" class="pb">
            <br/>
            <a class="external" href="{@facs}">[<xsl:value-of select="@n"/>]</a>
            <br/>
        </span>
    </xsl:template>

    <xsl:template match="tei:placeName">
        <a class="locality" href="../../../register/orte/{@key}.html">
            <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>

    <xsl:template match="tei:persName">
        <a class="person" href="../../../register/personen/{@key}.html">
            <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>

    <xsl:template match="tei:term">
        <a class="{@type}" href="../../../register/werke/{@key}.html">
            <xsl:apply-templates select="node()"/>
        </a>
        <xsl:if test="@ref">
            <xsl:text> </xsl:text>
            <a class="external" href="{@ref}" title="Weitere Informationen aus Normdatenrepositorium">(ℹ)</a>
        </xsl:if>
        <xsl:if test="@source">
            <xsl:text> </xsl:text>
            <a class="external doi" href="{@source}" title="Digitalisat aufrufen">[Digitalisat]</a>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:signed">
        <span class="signed">
            <!--
            <xsl:if test="//tei:closer[text()]/tei:signed">
                <br/>
            </xsl:if>
            -->
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'attachment']/tei:div/tei:head">
        <p>
            <strong>
                <xsl:apply-templates select="node()"/>
            </strong>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:div[@type = 'attachment']/tei:div">
        <div class="{@type}">
            <xsl:apply-templates select="./child::node()"/>
        </div>
    </xsl:template>

</xsl:stylesheet>