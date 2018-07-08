<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exslt="http://exslt.org/common" exclude-result-prefixes="xs tei exslt" version="2.0">

<!-- 
(:
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Stylesheet containing the website footer.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)
-->

    <xsl:template name="footer">
        <section class="six columns service">
            <h5>Links</h5>
            <ul class="standard">
                <li>
                    <a href="http://www.arthistoricum.net/themen/portale/sturm/">Themenportal „Herwarth Walden und DER STURM“</a>
                </li>
                <li>
                    <a href="http://bluemountain.princeton.edu/exist/apps/bluemountain/title.html?titleURN=bmtnabg">Blue Mountain Project der Universität Princeton</a>
                </li>
                <li>
                    <a href="http://kalliope.staatsbibliothek-berlin.de/de/findingaid_index?fa.id=DE-611-BF-4273&amp;fa.enum=111&amp;lastparam=true">STURM-Archiv der Staatsbibliothek zu Berlin</a>
                </li>
                <li>
                    <a href="http://digi.ub.uni-heidelberg.de/diglit/sturm">STURM-Bestände der Universitätsbibliothek Heidelberg</a>
                </li>
                <li>
                    <a href="http://www.zikg.eu/bibliothek/studienzentrum/digitalisierung/kataloge-sturm">STURM-Bestände des Zentralinstituts für Kunstgeschichte</a>
                </li>
            </ul>
            <h5>Nachnutzung</h5>
            <p>
                Edition und Forschungsdaten stehen unter einer 
                <a href="https://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International (CC-BY 4.0)</a> 
                Lizenz und können unter Berücksichtigung der Lizenzbedingungen frei nachgenutzt werden. 
                Die Editionssoftware dieses Projektes steht unter MIT-Lizenz und kann <a href="#">frei heruntergeladen</a> und 
                weiterentwickelt werden.
            </p>
        </section>
        <section class="six columns contact">
            <h5>Herausgeber</h5>
            <p>
                DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde, 
                erarbeitet und herausgegeben von Marjam Trautmann und Torsten Schrade, 
                Softwareversion 1.0.0 - 2018. <br/> URI: <a href="https://sturm-edition.de/">https://sturm-edition.de/</a>
            </p>
            <h5>Kontakt</h5>
            <a href="http://www.adwmainz.de/">
                <img id="logo" src="{$relativeToAppBase}images/adwlogo.png"/>
            </a>
            <address x-ms-format-detection="none" vocab="http://schema.org/" typeof="Organization">
                <span property="name">Akademie der Wissenschaften und der Literatur Mainz</span><br/>
                <div property="address" typeof="PostalAddress">
                    <span property="streetAddress">Geschwister-Scholl-Str. 2</span><br/>
                    <span property="postalCode">55131</span><xsl:text> </xsl:text>
                    <span property="addressLocality">Mainz</span>
                </div>
                Tel: 
                <span property="telephone" class="telephone">06131 577 119</span><br/>
                <span property="email"><a href="mailto:redaktion@sturm-edition.de">redaktion@sturm-edition.de</a></span><br/>
                <a class="imprint" href="{$relativeToAppBase}impressum.html">Impressum</a><br/>
                <a class="privacy" href="{$relativeToAppBase}datenschutz.html">Datenschutzerklärung</a>
            </address>
        </section>
    </xsl:template>
</xsl:stylesheet>