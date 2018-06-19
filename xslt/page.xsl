<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Stylsheet for transformation of standard website content like the project
 : description, the homepage etc.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

    <xsl:param name="lettersCount"/>
    <xsl:param name="placesCount"/>
    <xsl:param name="personsCount"/>
    <xsl:param name="worksCount"/>
    <xsl:param name="subNavigation"/>

    <xsl:template name="page">
        <xsl:variable name="idno">
            <xsl:value-of select="//tei:publicationStmt/tei:idno[@type = 'file']/text()"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$idno = 'index.xml'">
                <xsl:call-template name="homepage"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="//tei:text/tei:body/tei:div[@type='section']">
                        <xsl:for-each select="//tei:text/tei:body/tei:div[@type='section']">
                            <section class="{@n} columns">
                                <xsl:apply-templates select="./child::node()"/>
                                <xsl:if test="position() = 1 and //tei:note">
                                    <div class="aparatus">
                                        <xsl:call-template name="footnotes"/>
                                    </div>
                                </xsl:if>
                            </section>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <section class="twelve columns">
                            <xsl:apply-templates select="//tei:text/tei:body/tei:div[1]/child::node()"/> 
                        </section>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="homepage">
        <section class="twelve columns">
            <div class="row teaser">
                <div class="six columns letters">
                    <div class="teasercontainer">
                        <a href="quellen/briefe.html" class="teaserbox">
                            <img src="images/briefe.png" alt=""/>
                            <h4 class="teaserheader">Briefe</h4>
                            <p class="teasertext">
                                <xsl:value-of select="replace(//tei:div[@n = 'letters']//tei:p, '###lettersCount###', $lettersCount)"/>
                            </p>
                        </a>
                    </div>
                </div>
                <div class="six columns persons">
                    <div class="teasercontainer">
                        <a href="register/personen.html" class="teaserbox">
                            <img src="images/personen.png" alt=""/>
                            <h4 class="teaserheader">Personen</h4>
                            <p class="teasertext">
                                <xsl:value-of select="replace(//tei:div[@n = 'persons']//tei:p, '###personsCount###', $personsCount)"/>
                            </p>
                        </a>
                    </div>
                </div>
            </div>
            <div class="row teaser">
                <div class="six columns places">
                    <div class="teasercontainer">
                        <a href="register/orte.html" class="teaserbox">
                            <img src="images/orte.png" alt=""/>
                            <h4 class="teaserheader">Orte</h4>
                            <p class="teasertext">
                                <xsl:value-of select="replace(//tei:div[@n = 'places']//tei:p, '###placesCount###', $placesCount)"/>
                            </p>
                        </a>
                    </div>
                </div>
                <div class="six columns works">
                    <div class="teasercontainer">
                        <a href="register/werke.html" class="teaserbox">
                            <img src="images/werke.png" alt=""/>
                            <h4 class="teaserheader">Werke</h4>
                            <p class="teasertext">
                                <xsl:value-of select="replace(//tei:div[@n = 'works']//tei:p, '###worksCount###', $worksCount)"/>
                            </p>
                        </a>
                    </div>
                </div>
            </div>
            <div class="row preface">
                <div class="twelve columns preface">
                    <xsl:apply-templates select="//tei:div[@n = 'preface']"/>
                </div>
            </div>
        </section>
    </xsl:template>

    <xsl:template match="tei:ab[@type = 'subNavigation']">
        <xsl:variable name="select">
            <xsl:choose>
                <xsl:when test="@select">
                    <xsl:value-of select="@select"/>
                </xsl:when>
                <xsl:otherwise>
                    notinmenu
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>
        <xsl:if test="exists($subNavigation)">
            <nav class="subnavigation">
                <ul>
                    <xsl:for-each select="tokenize($subNavigation, ' ')">
                        <xsl:variable name="sourcePath">
                            <xsl:value-of select="substring-before(., ':')"/>
                        </xsl:variable>
                        <xsl:variable name="path">
                            <xsl:value-of select="replace(substring-before(., ':'), '.xml', '.html')"/>
                        </xsl:variable>
                        <xsl:variable name="title">
                            <xsl:value-of select="replace(substring-after(., ':'), '#', ' ')"/>
                        </xsl:variable>
                        <xsl:variable name="class">
                            <xsl:choose>
                                <xsl:when test="contains($sourcePath, $idno)">
                                    <xsl:text>active</xsl:text>
                                </xsl:when>
                                <xsl:when test="contains($sourcePath, $select)">
                                    <xsl:text>active</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>normal</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <li>
                            <a href="{$path}" class="{$class}">
                                <xsl:value-of select="$title"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </nav>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>