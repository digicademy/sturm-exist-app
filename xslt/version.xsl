<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!--
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Contains the version note and info box with the version information.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:param name="identifier">
        <xsl:value-of select="//tei:TEI/@xml:id"/>
    </xsl:param>

    <xsl:param name="latestPublicationDate">
        <xsl:call-template name="dateTime-to-RFC-2822">
            <xsl:with-param name="dateTime">
                <xsl:value-of select="//tei:change[1]/tei:date[1]/@when"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:param>

    <xsl:param name="editor">
        <xsl:for-each select="//tei:titleStmt/tei:editor">
            <xsl:value-of select="./tei:persName/tei:surname"/>,
            <xsl:value-of select="./tei:persName/tei:forename"/>
            <xsl:if test="position() ne last()">
                <xsl:text> / </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:param>

    <xsl:template name="version-note">
        <xsl:if test="contains($idno, 'v')">
            <div class="versions">
                <p>
                    <strong>Hinweis:</strong>
                    <br/> Sie betrachten gerade folgende ältere Version: 
                    Version <xsl:value-of select="//tei:change[1]/tei:date/@n"/> vom <xsl:value-of select="$latestPublicationDate"/>
                </p>
                <p>
                    Die aktuelle Version findet sich unter folgender URI: <br/>
                    <a href="https://sturm-edition.de/id/{$identifier}">https://sturm-edition.de/id/<xsl:value-of select="$identifier"/>
                    </a>
                </p>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="version-infobox">
        <div class="info">
            <p>
                <strong>Zitierhinweis:</strong>
                <br/>
                <xsl:value-of select="$editor"/>:
                „<xsl:value-of select="subsequence(tokenize(string-join(//tei:title[1]/text(), ''), ','), 1, 1)"/>
                <xsl:if test="$transformation eq 'letter'">,<xsl:value-of select="subsequence(tokenize(string-join(//tei:title[1]/text(), ''), ','), 2, 1)"/>
                </xsl:if>“, in: 
                <xsl:text>
                    DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde, erarbeitet und herausgegeben von Marjam Trautmann und Torsten Schrade. Mainz, Akademie der Wissenschaften und der Literatur, 
                </xsl:text>
                Version <xsl:value-of select="//tei:change[1]/tei:date/@n"/> vom <xsl:value-of select="$latestPublicationDate"/>.
            </p>
            <p>
                <strong>URI:</strong>
                <br/>
                <a href="https://sturm-edition.de/id/{$identifier}">https://sturm-edition.de/id/<xsl:value-of select="$identifier"/>
                </a>
            </p>
            <p>
                <strong>Versionen:</strong>
                <xsl:for-each select="//tei:revisionDesc/tei:listChange/tei:change/tei:date">
                    <xsl:variable name="dateOfVersion">
                        <xsl:call-template name="dateTime-to-RFC-2822">
                            <xsl:with-param name="dateTime">
                                <xsl:value-of select="@when"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <br/>
                    <a href="https://sturm-edition.de/id/{$identifier}/{@n}">
                        https://sturm-edition.de/id/<xsl:value-of select="$identifier"/>/<xsl:value-of select="@n"/>
                    </a> (<xsl:value-of select="$dateOfVersion"/>)
                </xsl:for-each>
            </p>
            <p>
                <strong>Nutzungshinweis:</strong>
                <br/>
                Edition und Forschungsdaten stehen unter einer <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International (CC-BY 4.0)</a> Lizenz. 
                Freie Verwendung unter Angabe von Zitierhinweis, Permalink und Kenntlichmachung von Änderungen.
            </p>
        </div>
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
        <!-- construct output -->
        <xsl:value-of select="$day"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="substring('JanFebMrzAprMaiJunJulAugSepOktNovDez', 3 * ($month - 1) + 1, 3)"/>
        <xsl:text>. </xsl:text>
        <xsl:value-of select="$year"/>
        <xsl:value-of select="substring-after($dateTime, 'T')"/>
    </xsl:template>

</xsl:stylesheet>