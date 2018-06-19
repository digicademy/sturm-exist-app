<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt functx" version="2.0">

<!-- 
(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Main stylsheet for the transformation of all registers (letters, persons, places
 : works).
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

    <xsl:include href="functx.xsl"/>
    <xsl:include href="alphabet.xsl"/>

    <xsl:template name="register">
        <xsl:choose>
            <xsl:when test="//tei:text/tei:body/tei:div/tei:list[@n = 'letters']">
                <xsl:call-template name="lettersRegister"/>
            </xsl:when>
            <xsl:when test="//tei:listPerson">
                <section class="eight columns maincontent">
                    <h2>
                        <xsl:value-of select="//tei:title"/>
                    </h2>
                    <div class="toolbar">
                        <xsl:call-template name="alphabet"/>
                    </div>
                    <xsl:call-template name="personsRegister"/>
                </section>
                <section class="four columns sidebar">
                    <nav class="subnavigation">
                        <ul>
                            <li>
                                <a class="active" href="personen.html">Personenregister</a>
                            </li>
                            <li>
                                <a class="normal" href="orte.html">Ortsregister</a>
                            </li>
                            <li>
                                <a class="normal" href="werke.html">Werkregister</a>
                            </li>
                        </ul>
                    </nav>
                </section>
            </xsl:when>
            <xsl:when test="//tei:listPlace">
                <section class="eight columns maincontent">
                    <h2>
                        <xsl:value-of select="//tei:title"/>
                    </h2>
                    <div class="toolbar">
                        <xsl:call-template name="alphabet"/>
                    </div>
                    <div id="map" class="leaflet">
                    </div>
                    <xsl:call-template name="placesRegister"/>
                </section>
                <section class="four columns sidebar">
                    <nav class="subnavigation">
                        <ul>
                            <li>
                                <a class="normal" href="personen.html">Personenregister</a>
                            </li>
                            <li>
                                <a class="active" href="orte.html">Ortsregister</a>
                            </li>
                            <li>
                                <a class="normal" href="werke.html">Werkregister</a>
                            </li>
                        </ul>
                    </nav>
                </section>
            </xsl:when>
            <xsl:when test="//tei:list[@n = 'works']">
                <section class="eight columns maincontent">
                    <h2>
                        <xsl:value-of select="//tei:title"/>
                    </h2>
                    <div class="toolbar">
                        <xsl:call-template name="alphabet"/>
                    </div>
                    <xsl:call-template name="worksRegister"/>
                </section>
                <section class="four columns sidebar">
                    <nav class="subnavigation">
                        <ul>
                            <li>
                                <a class="normal" href="personen.html">Personenregister</a>
                            </li>
                            <li>
                                <a class="normal" href="orte.html">Ortsregister</a>
                            </li>
                            <li>
                                <a class="active" href="werke.html">Werkregister</a>
                            </li>
                        </ul>
                    </nav>
                </section>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="personsRegister">
        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:listPerson/tei:listPerson">
            <xsl:call-template name="lemmaList"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="placesRegister">
        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:listPlace/tei:listPlace">
            <xsl:call-template name="lemmaList"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="worksRegister">
        <xsl:for-each select="//tei:text/tei:body/tei:div/tei:list[@n = 'works']">
            <xsl:call-template name="lemmaList"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="lemmaList">
        <div class="row" id="letter-{lower-case(./tei:head/text())}">
            <div class="twelve columns">
                <h3>
                    <xsl:value-of select="./tei:head/text()"/>
                </h3>
                <ul class="lemmalist">
                    <xsl:variable name="type">
                        <xsl:choose>
                            <xsl:when test="./tei:person">personen</xsl:when>
                            <xsl:when test="./tei:place">orte</xsl:when>
                            <xsl:when test="./tei:item">werke</xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:for-each select="./tei:person|./tei:place|./tei:item">
                        <li id="{@xml:id}" class="lemma">
                            <a href="{concat($type, '/', @xml:id, '.html')}">
                                <xsl:value-of select="./tei:persName[@type = 'pref']/text()|./tei:placeName[@type = 'pref']/text()|./tei:name[@type = 'pref']/text()"/>
                            </a>
                            <xsl:if test="substring(@source, 1, 4) eq 'http'">
                                (<a href="{@source}" target="_blank" class="external" title="Weitere Informationen">ℹ</a>)
                            </xsl:if>
                            – <strong>Abteilung I, Briefe: </strong>
                            <xsl:for-each select="./tei:linkGrp/tei:ptr">
                                <a href="../quellen/briefe/chronologie/{replace(@target, '.xml', '.html')}">
                                    <xsl:value-of select="@n"/>
                                    <xsl:if test="position() ne last()">, </xsl:if> 
                                </a>
                            </xsl:for-each>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="lettersRegister">
        <div class="row content">
            <div class="twelfe columns">
            <xsl:for-each select="//tei:text/tei:body/tei:div/tei:list/tei:item">
                <h4>
                    <xsl:value-of select="replace(@n, '_', ' ')"/>
                </h4>
                <xsl:for-each select=".//tei:list">
                    <h5 class="year">
                        <xsl:value-of select="@n"/>
                    </h5>
                    <ol class="letters">
                        <xsl:for-each select=".//tei:item">
                            <li>
                                <a href="{concat('briefe/chronologie/', replace(./tei:ref[1]/@target, '.xml', '.html'))}">
                                    <time datetime="{./tei:ref[1]/tei:time/@when}">
                                        <xsl:value-of select="./tei:ref[1]/tei:time"/>
                                    </time>, <span class="locality">
                                        <xsl:value-of select="./tei:ref[1]/tei:placeName"/>
                                    </span>, 
                                </a> 
                                [ <span class="repository"> <a href="{./tei:ref[2]/@target}" class="external" target="blank">
                                        <xsl:value-of select="./tei:ref[2]/text()"/>
                                    </a>
                                </span> ] 
                            </li>
                        </xsl:for-each>
                    </ol>
                </xsl:for-each>
            </xsl:for-each>
            </div>
        </div>
    </xsl:template>

</xsl:stylesheet>