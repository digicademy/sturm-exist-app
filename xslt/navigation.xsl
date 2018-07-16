<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Contains the main website navigation with active/normal states.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)
-->

    <xsl:template name="navigation">
        <nav class="navigation">
            <ul>
                <li>
                    <a class="{if ($idno = 'projekt.xml' or contains($sourceDocPath, '/projekt')) then 'active' else 'normal'}" href="{$relativeToAppBase}projekt.html">Projekt</a>
                </li>
                <li>
                    <a class="{if ($idno = 'edition.xml' or contains($sourceDocPath, '/edition')) then 'active' else 'normal'}" href="{$relativeToAppBase}edition.html">Edition</a>
                </li>
                <li>
                    <a class="{if ($idno = 'quellen.xml' or contains($sourceDocPath, '/quellen')) then 'active' else 'normal'}" href="{$relativeToAppBase}quellen.html">Quellen</a>
                </li>
                <li>
                    <a class="{if ($idno = 'register.xml' or contains($sourceDocPath, '/register')) then 'active' else 'normal'}" href="{$relativeToAppBase}register.html">Register</a>
                </li>
                <li>
                    <a class="{if ($idno = 'ressourcen.xml' or contains($sourceDocPath, '/ressourcen')) then 'active' else 'normal'}" href="{$relativeToAppBase}ressourcen.html">Ressourcen</a>
                </li>
<!--
                <li>
                    <a href="#">Suche</a>
                </li>
-->
            </ul>
        </nav>
    </xsl:template>

</xsl:stylesheet>