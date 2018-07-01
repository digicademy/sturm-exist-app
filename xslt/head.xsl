<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Contains the head of the website with title and metadata.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

    <xsl:template name="head">
        <xsl:param name="title"/>
        <head>
            <meta charset="utf-8"/>
            <meta name="description" content=""/>
            <meta name="author" content="Marjam Mahmoodzada"/>
            <meta name="author" content="Torsten Schrade"/>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
            <title>
                <xsl:value-of select="$title"/>
            </title>
            <script>
                var Hyphenopoly = {
                    require: {
                        "de": "FORCEHYPHENOPOLY"
                    },
                    paths: {
                        patterndir: "/js/Hyphenopoly/patterns/",
                        maindir: "/js/Hyphenopoly/"
                    },
                    setup: {
                        classnames: {
                            "container": {}
                        }
                    }
                };
            </script>
            <script src="{$relativeToAppBase}js/Hyphenopoly/Hyphenopoly_Loader.js"/>
            <link href="https://fonts.googleapis.com/css?family=Tinos:400,400i,700,700i&amp;subset=latin-ext" rel="stylesheet"/>
            <link href="https://fonts.googleapis.com/css?family=Ramaraja" rel="stylesheet"/>
            <link rel="stylesheet" type="text/css" href="{$relativeToAppBase}css/MyFontsWebfontsKit/MyFontsWebfontsKit.css"/>
            <link rel="stylesheet" type="text/css" media="screen" href="{$relativeToAppBase}css/normalize.css"/>
            <link rel="stylesheet" type="text/css" media="screen" href="{$relativeToAppBase}css/skeleton.css"/>
            <link rel="stylesheet" type="text/css" media="screen" href="{$relativeToAppBase}css/magnific-popup.css"/>
            <link rel="stylesheet" type="text/css" media="screen" href="{$relativeToAppBase}css/atom-one-light.css"/>
            <xsl:if test="//tei:publicationStmt/tei:idno[@type = 'file'] = 'orte.xml'">
                <link rel="stylesheet" type="text/css" media="screen" href="https://unpkg.com/leaflet@1.3.1/dist/leaflet.css" integrity="sha512-Rksm5RenBEKSKFjgI3a41vrjkw4EVPlJ3+OiI65vTjIdo9brlAacEuKOiQ5OFh7cOI1bkDwLqdLw3Zg0cRJAAQ==" crossorigin=""/>
            </xsl:if>
            <link rel="stylesheet" type="text/css" media="screen" href="{$relativeToAppBase}css/style.css"/>
            <link rel="stylesheet" type="text/css" media="print" href="{$relativeToAppBase}css/print.css"/>
            <link rel="icon" type="image/png" href="{$relativeToAppBase}images/favicon.png"/>
        </head>
    </xsl:template>

</xsl:stylesheet>