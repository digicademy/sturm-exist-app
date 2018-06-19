<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt functx" version="2.0">
    
    <!-- 
(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Stylesheet for transformation of single pages for entities (persons, places, works).
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

    <xsl:template name="entity">
        <xsl:variable name="prefName">
            <xsl:choose>
                <xsl:when test="//tei:persName">
                    <xsl:value-of select="//tei:persName[@type = 'pref']"/>
                </xsl:when>
                <xsl:when test="//tei:placeName">
                    <xsl:value-of select="//tei:placeName[@type = 'pref']"/>
                </xsl:when>
                <xsl:when test="//tei:name">
                    <xsl:value-of select="//tei:name[@type = 'pref']"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="//tei:persName">personen</xsl:when>
                <xsl:when test="//tei:placeName">orte</xsl:when>
                <xsl:when test="//tei:name">werke</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="normdata">
            <xsl:choose>
                <xsl:when test="//tei:person/@source">
                    <xsl:value-of select="//tei:person/@source"/>
                </xsl:when>
                <xsl:when test="//tei:place/@source">
                    <xsl:value-of select="//tei:place/@source"/>
                </xsl:when>
                <xsl:when test="//tei:item[@n]/@source">
                    <xsl:value-of select="//tei:item[@n]/@source"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="identifier">
            <xsl:choose>
                <xsl:when test="//tei:person">
                    <xsl:value-of select="//tei:person/@xml:id"/>
                </xsl:when>
                <xsl:when test="//tei:place">
                    <xsl:value-of select="//tei:place/@xml:id"/>
                </xsl:when>
                <xsl:when test="//tei:item[@n]">
                    <xsl:value-of select="//tei:item[@n]/@xml:id"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <section class="eight columns maincontent">
            <h2>
            <xsl:choose>
                <xsl:when test="//tei:persName">Personenregister</xsl:when>
                <xsl:when test="//tei:placeName">Ortsregister</xsl:when>
                <xsl:when test="//tei:name">Werkregister</xsl:when>
            </xsl:choose>
            </h2>
            <div class="toolbar">
                <ul class="alphabet">
                    <xsl:for-each select="//tei:list[@n = 'alphabet']/tei:item">
                        <li class="letter">
                            <a class="black button" href="{concat('../', $type, '.html#letter-', lower-case(.))}">
                                <xsl:value-of select="."/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <h3>
                <xsl:value-of select="$prefName"/>
            </h3>
            <xsl:if test="$normdata ne ''">
                <p>
                    <emph rend="strong">Normdaten:</emph> 
                    <a class="external" href="{$normdata}">
                        <xsl:value-of select="$normdata"/>
                    </a>
                </p>
            </xsl:if>
            <h4>Quellen</h4>
            <h5>Abteilung I - Briefe</h5>
            <p>
            <xsl:for-each select="//tei:linkGrp/tei:ptr">
                <a href="../../quellen/briefe/chronologie/{replace(@target, '.xml', '.html')}">
                    <xsl:value-of select="@n"/>
                    <xsl:if test="position() ne last()">, </xsl:if> 
                </a>
            </xsl:for-each>
            </p>
            <div class="info">
                <p>
                    <strong>Zitierhinweis:</strong>
                    <br/>
                    Registereintrag
                    „<xsl:value-of select="$prefName"/>“, in: 
                    <xsl:text>
                        Der STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde, erarbeitet und herausgegeben von Marjam Trautmann, 
                        Thomas Kollatz und Torsten Schrade. Mainz, Akademie der Wissenschaften und der Literatur 2018.
                    </xsl:text>
                </p>
                <p>
                    <strong>URI:</strong>
                    <br/>
                    <a href="https://sturm-edition.de/id/{$identifier}">https://sturm-edition.de/id/<xsl:value-of select="$identifier"/>
                    </a>
                </p>
                <p>
                    <strong>Nutzungshinweis:</strong>
                    <br/>
                    Edition und Forschungsdaten stehen unter einer <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International (CC-BY 4.0)</a> Lizenz. 
                    Freie Verwendung unter Angabe von Zitierhinweis, Permalink und Kenntlichmachung von Änderungen.
                </p>
            </div>
        </section>
        <section class="four columns sidebar">
            <nav class="subnavigation">
                <ul>
                    <li>
                        <a class="{if (//tei:persName) then 'active' else 'normal'}" href="../personen.html">Personenregister</a>
                    </li>
                    <li>
                        <a class="{if (//tei:placeName) then 'active' else 'normal'}" href="../orte.html">Ortsregister</a>
                    </li>
                    <li>
                        <a class="{if (//tei:name) then 'active' else 'normal'}" href="../werke.html">Werkregister</a>
                    </li>
                </ul>
            </nav>
        </section>
    </xsl:template>

</xsl:stylesheet>