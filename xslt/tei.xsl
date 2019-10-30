<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!--
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : This stylesheet is used for the generation of TEI/XML files
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:param name="type"/>
    <xsl:param name="title"/>
    <xsl:param name="editorName"/>
    <xsl:param name="editorEmail"/>
    <xsl:param name="url"/>
    <xsl:param name="file"/>
    <xsl:param name="date"/>
    <xsl:param name="bibl"/>
    <xsl:param name="description"/>

    <xsl:output method="xml" encoding="UTF-8" indent="yes" xml:space="preserve"/>

    <!-- identity transform: copy source nodes to target document -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- surrounding TEI document -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$type eq 'cmif'">
                <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/TEI-Correspondence-SIG/CMIF/master/schema/cmi-customization.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
            </xsl:when>
            <xsl:otherwise>
                <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model">href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
            </xsl:otherwise>
        </xsl:choose>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="$title"/>
                        </title>
                        <editor>
                            <xsl:value-of select="$editorName"/>
                            <email>
                                <xsl:value-of select="$editorEmail"/>
                            </email>
                        </editor>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <ref target="http://www.adwmainz.de/">Akademie der Wissenschaften und der Literatur | Mainz</ref>
                        </publisher>
                        <xsl:if test="$file">
                            <idno type="file">
                                <xsl:value-of select="$file"/>
                            </idno>
                        </xsl:if>
                        <xsl:if test="$url">
                            <idno type="url">
                                <xsl:value-of select="$url"/>
                            </idno>
                        </xsl:if>
                        <date when="{$date}"/>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/4.0/">This file is licensed under the terms of the Creative-Commons-License CC BY 4.0</licence>
                        </availability>
                    </publicationStmt>
                    <sourceDesc>
                        <xsl:if test="$bibl">
                            <bibl type="online" xml:id="STURM">
                                <xsl:value-of select="$bibl"/> <ref target="https://sturm-edition.de/">https://sturm-edition.de/</ref>
                            </bibl>
                        </xsl:if>
                        <xsl:if test="$description">
                            <p>
                                <xsl:value-of select="$description"/>
                            </p>
                        </xsl:if>
                    </sourceDesc>
                </fileDesc>
                <xsl:if test="$type eq 'cmif'">
                <profileDesc>
                    <xsl:apply-templates select="node()"/>
                </profileDesc>
                </xsl:if>
            </teiHeader>
            <text>
                <body>
                <xsl:choose>
                    <xsl:when test="$type eq 'cmif'">
                        <p/>
                    </xsl:when>
                    <xsl:otherwise>
                        <div>
                            <xsl:apply-templates select="node()"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
                </body>
            </text>
        </TEI>
    </xsl:template>

</xsl:stylesheet>