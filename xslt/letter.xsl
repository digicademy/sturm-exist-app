<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Stylesheet for the transformation of letters from the STURM-Archive.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
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

                <xsl:variable name="identifier">
                    <xsl:value-of select="/tei:TEI/@xml:id"/>
                </xsl:variable>

                <xsl:variable name="editor">
                    <xsl:choose>
                        <xsl:when test="//tei:editor/tei:persName/@ref">
                            <a href="{//tei:editor/tei:persName/@ref}">
                                <xsl:value-of select="//tei:editor/tei:persName/tei:surname"/>,
                                <xsl:value-of select="//tei:editor/tei:persName/tei:forename"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//tei:editor/tei:persName/tei:surname"/>,
                            <xsl:value-of select="//tei:editor/tei:persName/tei:forename"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="formattedDate">
                    <xsl:call-template name="dateTime-to-RFC-2822">
                        <xsl:with-param name="dateTime">
                            <xsl:value-of select="//tei:change[1]/tei:date[1]/@when"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:if test="contains($idno, 'v')">
                    <div class="versions">
                        <p>
                            <strong>Hinweis:</strong><br/> Sie betrachten gerade folgende ältere Version dieser Quelle: 
                            Version <xsl:value-of select="//tei:change[1]/tei:date/@n"/> vom <xsl:value-of select="$formattedDate"/>
                        </p>
                        <p>
                            Die aktuelle Version dieser Quelle findet sich unter folgender URI: <br/>
                            <a href="https://sturm-edition.de/id/{$identifier}">https://sturm-edition.de/id/<xsl:value-of select="$identifier"/></a>
                        </p>
                    </div>
                </xsl:if>

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

                <div class="info">
                    <p>
                        <strong>Zitierhinweis:</strong>
                        <br/>
                        <xsl:value-of select="$editor"/>:
                        „<xsl:value-of select="subsequence(tokenize(string-join(//tei:title[1]/text(), ''), ','), 1, 1)"/>, 
                        <xsl:value-of select="subsequence(tokenize(string-join(//tei:title[1]/text(), ''), ','), 2, 1)"/>“, in: 
                        <xsl:text>
                            DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde, erarbeitet und herausgegeben von Marjam Trautmann und Torsten Schrade. Mainz, Akademie der Wissenschaften und der Literatur, 
                        </xsl:text>
                        Version <xsl:value-of select="//tei:change[1]/tei:date/@n"/> vom <xsl:value-of select="$formattedDate"/>.
                    </p>
                    <p>
                        <strong>URI:</strong>
                        <br/>
                        <a href="https://sturm-edition.de/id/{$identifier}">https://sturm-edition.de/id/<xsl:value-of select="$identifier"/></a>
                    </p>
                    <p>
                        <strong>Versionen:</strong>
                        <xsl:for-each select="//tei:revisionDesc/tei:listChange/tei:change/tei:date">
                            <xsl:variable name="formattedDate">
                                <xsl:call-template name="dateTime-to-RFC-2822">
                                    <xsl:with-param name="dateTime">
                                        <xsl:value-of select="@when"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <br/>
                            <a href="https://sturm-edition.de/id/{$identifier}/{@n}">
                                https://sturm-edition.de/id/<xsl:value-of select="$identifier"/>/<xsl:value-of select="@n"/>
                            </a> (<xsl:value-of select="$formattedDate"/>)
                        </xsl:for-each>
                    </p>
                    <p>
                        <strong>Nutzungshinweis:</strong>
                        <br/>
                        Edition und Forschungsdaten stehen unter einer <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International (CC-BY 4.0)</a> Lizenz. 
                        Freie Verwendung unter Angabe von Zitierhinweis, Permalink und Kenntlichmachung von Änderungen.
                    </p>
                </div>
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

    <xsl:template name="dateTime-to-RFC-2822">
        <xsl:param name="dateTime"/>
        <!-- extract components -->
        <xsl:variable name="year" as="xs:integer" select="xs:integer(substring($dateTime, 1, 4))"/>
        <xsl:variable name="month" as="xs:integer" select="xs:integer(substring($dateTime, 6, 2))"/>
        <xsl:variable name="day" as="xs:integer" select="xs:integer(substring($dateTime, 9, 2))"/>
        <!-- calculate day-of-week using Zeller's_congruence -->
        <xsl:variable name="a" as="xs:integer" select="xs:integer($month &lt; 3)"/>
        <xsl:variable name="m" as="xs:integer" select="xs:integer($month + 12*$a)"/>
        <xsl:variable name="y" as="xs:integer" select="xs:integer($year - $a)"/>
        <xsl:variable name="K" as="xs:integer" select="xs:integer($y mod 100)"/>
        <xsl:variable name="J" as="xs:integer" select="xs:integer(floor($y div 100))"/>
        <xsl:variable name="h" as="xs:integer" select="xs:integer(($day + floor(13*($m + 1) div 5) + $K + floor($K div 4) + floor($J div 4) + 5*$J + 6) mod 7)"/>
        <!-- construct output 
        <xsl:value-of select="substring('SunMonTueWedThuFriSat', 3 * $h + 1, 3)"/>
        <xsl:text>, </xsl:text>
        -->
        <xsl:value-of select="$day"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="substring('JanFebMrzAprMaiJunJulAugSepOktNovDez', 3 * ($month - 1) + 1, 3)"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="$year"/>
        <xsl:value-of select="substring-after($dateTime, 'T')"/>
    </xsl:template>

</xsl:stylesheet>