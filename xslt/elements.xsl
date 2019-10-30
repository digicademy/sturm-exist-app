<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Generic stylesheet that transforms inline and structural XML elements
 : into their HTML counterparts. This stylesheed is automatically applied
 : to any text content of the website.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <!-- grid -->
    <xsl:template match="tei:div[@type='row']">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@rend"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="row{$class}">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:div[@type='columns']">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="@rend"/>
                </xsl:when>
                <xsl:otherwise>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="columns {@n}{$class}">
            <xsl:apply-templates select="node()"/>
        </div>
    </xsl:template>

    <!-- headings -->
    <xsl:template match="tei:ab[@rend]">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@style">
                    <xsl:value-of select="@style"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>standard</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@rend = 'h1'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h1 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h1>
                    </xsl:when>
                    <xsl:otherwise>
                        <h1 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h1>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'h2'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h2 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h2>
                    </xsl:when>
                    <xsl:otherwise>
                        <h2 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h2>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'h3'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h3 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h3>
                    </xsl:when>
                    <xsl:otherwise>
                        <h3 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h3>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'h4'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h4 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h4>
                    </xsl:when>
                    <xsl:otherwise>
                        <h4 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h4>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'h5'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h5 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h5>
                    </xsl:when>
                    <xsl:otherwise>
                        <h5 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h5>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'h6'">
                <xsl:choose>
                    <xsl:when test="@xml:id">
                        <h6 id="{@xml:id}" class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h6>
                    </xsl:when>
                    <xsl:otherwise>
                        <h6 class="{$class}">
                            <xsl:apply-templates select="node()"/>
                        </h6>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'pre'">
                <pre>
                    <xsl:apply-templates select="node()"/>
                </pre>
            </xsl:when>
            <xsl:when test="@rend = 'nav'">
                <nav class="subnavigation">
                    <xsl:apply-templates select="node()"/>
                </nav>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- links -->
    <xsl:template match="tei:ref">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@rend">
                    <xsl:value-of select="@rend"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>internal</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- link to external ressource -->
            <xsl:when test="substring(@target, 1, 4) eq 'http'">
                <a class="external {$class}" href="{@target}">
                    <xsl:apply-templates select="node()"/>
                </a>
            </xsl:when>
            <!-- link to letter -->
            <xsl:when test="substring(@target, 1, 4) eq 'Q.01'">
                <xsl:variable name="letterTarget">
                    <xsl:choose>
                        <xsl:when test="contains(@target, '#')">
                            <xsl:value-of select="concat(substring-before(@target, '#'), '.html#', substring-after(@target, '#'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(@target, '.html')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <a class="letter {$class}" href="{$relativeToAppBase}quellen/briefe/chronologie/{$letterTarget}">
                    <xsl:apply-templates select="node()"/>
                </a>
            </xsl:when>
            <!-- link to page/file like "edition.xml" -->
            <xsl:otherwise>
                <a class="{$class}" href="{$relativeToAppBase}{replace(@target, '.xml', '.html')}">
                    <xsl:apply-templates select="node()"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- lists -->
    <xsl:template match="tei:list[@rend]">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>standard</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@rend = 'ul'">
                <ul class="{$class}">
                    <xsl:apply-templates select="node()"/>
                </ul>
            </xsl:when>
            <xsl:when test="@rend = 'ol'">
                <ol class="{$class}">
                    <xsl:apply-templates select="node()"/>
                </ol>
            </xsl:when>
            <xsl:when test="@rend = 'sourcelist'">
                <xsl:call-template name="sourcelist"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:list[@rend]/tei:item">
        <xsl:choose>
            <xsl:when test="./tei:list">
                <li class="nested">
                    <xsl:apply-templates select="node()"/>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates select="node()"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="sourcelist">
        <h4 class="year" id="y{@source}">
            <xsl:value-of select="@source"/>
        </h4>
        <ol class="sourcelist letters">
            <xsl:for-each select="./tei:item">
                <xsl:variable name="dir">
                    <xsl:choose>
                        <xsl:when test="@n = 'chronological'">
                            <xsl:text>chronologie/</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(lower-case(@n), '/')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <li>
                    <a href="{concat($dir, @source, '.html')}">
                        <xsl:value-of select="."/>
                    </a>
                </li>
            </xsl:for-each>
        </ol>
    </xsl:template>

    <!-- code -->
    <xsl:template match="tei:code">
        <code class="{@rend}">
            <xsl:apply-templates select="node()"/>
        </code>
    </xsl:template>

    <!-- tables -->
    <xsl:template match="tei:table">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>standard</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <table class="{$class}">
            <xsl:if test=".//tei:head">
                <caption>
                    <xsl:apply-templates select=".//tei:head"/>
                </caption>
            </xsl:if>
            <xsl:if test=".//tei:row[@rend='th']">
                <thead>
                    <tr>
                        <xsl:for-each select=".//tei:row[@rend = 'th']/tei:cell">
                            <th>
                                <xsl:apply-templates select="node()"/>
                            </th>
                        </xsl:for-each>
                    </tr>
                </thead>
            </xsl:if>
            <tbody>
                <xsl:for-each select=".//tei:row[not(@rend)]">
                    <tr>
                        <xsl:for-each select=".//tei:cell">
                            <td>
                                <xsl:apply-templates select="node()"/>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

    <!-- images -->
    <xsl:template match="tei:figure">
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>standard</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <figure class="{$class}">
            <xsl:apply-templates select="node()"/>
        </figure>
    </xsl:template>

    <xsl:template match="tei:figure/tei:caption">
        <figcaption>
            <xsl:apply-templates select="node()"/>
        </figcaption>
    </xsl:template>

    <xsl:template match="tei:graphic">
        <xsl:choose>
            <xsl:when test="parent::tei:figure/@type eq 'mfp-lightbox'">
                <a href="{@url}">
                    <img src="{@url}"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <img src="{@url}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- quotes -->
    <xsl:template match="tei:cit|tei:quote">
        <blockquote>
            <xsl:apply-templates select="./tei:quote/*"/>
            <xsl:if test="./tei:bibl">
                <cite>
                    <xsl:if test="./tei:bibl/tei:author">
                        <span class="author">
                            <xsl:apply-templates select="./tei:bibl/tei:author/*"/>
                        </span>
                    </xsl:if>
                    <xsl:if test="./tei:bibl/tei:title">
                        <xsl:text> </xsl:text>
                        <span class="bibl">
                            <xsl:apply-templates select="./tei:bibl/tei:title/*"/>
                        </span>
                    </xsl:if>
                </cite>
            </xsl:if>
        </blockquote>
    </xsl:template>
    <xsl:template match="tei:q">
        <q>
            <xsl:apply-templates select="node()"/>
        </q>
    </xsl:template>

    <!-- address -->
    <xsl:template match="tei:ab[@type='sender']|tei:ab[@type='recipient']">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    <xsl:template match="tei:ab/tei:address">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="parent::tei:ab[@type='sender']">
                    <xsl:text>sender</xsl:text>
                </xsl:when>
                <xsl:when test="parent::tei:ab[@type='recipient']">
                    <xsl:text>recipient</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>standard</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <p class="address {$type}">
            <xsl:apply-templates select="node()"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:p/tei:address">
            <xsl:choose>
                <xsl:when test="@rend='inline'">
                    <span class="address inline">
                        <xsl:apply-templates select="node()"/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <p class="address">
                        <xsl:apply-templates select="node()"/>
                    </p>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:addrLine">
        <span class="addrLine">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- footnotes -->
    <xsl:template name="footnotes">
        <ol class="footnotes">
            <xsl:for-each select="//tei:body">
                <xsl:for-each select=".//tei:note">
                    <li id="ap-{position()}">
                        <xsl:apply-templates select="child::node()"/>
                        <a href="#fn-{position()}"> » </a>
                    </li>
                </xsl:for-each>
            </xsl:for-each>
        </ol>
    </xsl:template>
    <xsl:template match="tei:note">
        <xsl:if test="not(ancestor::resp)">
            <xsl:variable name="count">
                <xsl:number level="any" count="tei:note" from="tei:text"/>
            </xsl:variable>
            <sup class="fn">
                <a href="#ap-{$count}" id="fn-{$count}">
                    <xsl:value-of select="$count"/>
                </a>
            </sup>
        </xsl:if>
    </xsl:template>

    <!-- linebreaks -->
    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <!-- dates -->
    <xsl:template match="tei:date">
        <time datetime="{@when}">
            <xsl:apply-templates select="node()"/>
        </time>
    </xsl:template>

    <!-- underlined text -->
    <xsl:template match="tei:hi[@rend = 'underline']">
        <span class="underline">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- twice underlined text-->
    <xsl:template match="tei:hi[@rend = 'twice-underline']">
        <span class="twice-underline">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- strike through text-->
    <xsl:template match="tei:hi[@rend = 'line-through']">
        <del>
            <xsl:apply-templates select="node()"/>
        </del>
    </xsl:template>

    <!-- sup -->
    <xsl:template match="tei:hi[@rend = 'super']">
        <sup>
            <xsl:apply-templates select="node()"/>
        </sup>
    </xsl:template>

    <!-- sub -->
    <xsl:template match="tei:hi[@rend = 'sub']">
        <sub>
            <xsl:apply-templates select="node()"/>
        </sub>
    </xsl:template>

    <!-- em -->
    <xsl:template match="tei:emph[@rend = 'em']">
        <em>
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>

    <!-- strong -->
    <xsl:template match="tei:emph[@rend = 'strong']">
        <strong>
            <xsl:apply-templates select="node()"/>
        </strong>
    </xsl:template>

    <!-- small caps -->
    <xsl:template match="tei:emph[@rend = 'small-caps']">
        <span class="small-caps">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- unclear -->
    <xsl:template match="tei:unclear">
        <em class="unclear" title="Unsichere Lesung">
            <xsl:apply-templates select="node()"/>
        </em>
    </xsl:template>
 
    <!-- sic -->
    <xsl:template match="tei:sic">
        <span class="sic">
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>

    <!-- foreign language -->
    <xsl:template match="tei:foreign">
        <i class="foreign">
            <xsl:apply-templates select="node()"/>
        </i>
    </xsl:template>

</xsl:stylesheet>