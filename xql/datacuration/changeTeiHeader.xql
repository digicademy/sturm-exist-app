xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare function local:month-name-de($date as xs:anyAtomicType?) as xs:string? {
   ('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')
   [month-from-date(xs:date($date))]
};

for $header in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')//tei:teiHeader

        let $idno := $header//tei:publicationStmt/tei:idno/text()

        let $historicalDate := $header//tei:correspAction/tei:date/@when|$header//tei:correspAction/tei:date/@notBefore
        let $historicalDateString := concat(day-from-date($historicalDate), '. ', local:month-name-de($historicalDate), ' ', year-from-date($historicalDate))

        let $title := 
            if ($header//tei:correspAction/tei:placeName) then
                concat(
                    $header//tei:correspAction[@type = 'sent']/tei:persName/text(),
                    ' an Herwarth Walden, ',
                    $historicalDateString,
                    ', ',
                    functx:trim($header//tei:correspAction[@type = 'sent']/tei:placeName[1])
                 )
            else 
                 concat(
                    $header//tei:correspAction[@type = 'sent']/tei:persName/text(),
                    ' an Herwarth Walden, ',
                    $historicalDateString
                 )
        let $finalTitle := normalize-space(string(replace($title, 'Unknown', 'unbekannter Ort')))

        let $xenoData := $header//tei:xenoData/text()

        let $correspDesc := $header//tei:correspDesc

        let $repository := $header//tei:repository/text()
        let $uri := $header//tei:idno[@type='URI']/text()

        let $new := 
    <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
        <fileDesc>
            <titleStmt>
                <title>{$finalTitle}</title>
                <editor>
                    <persName ref="https://orcid.org/0000-0003-2423-7144">
                        <forename>Marjam</forename>
                        <surname>Trautmann</surname>
                    </persName>
                </editor>
                <respStmt>
                    <persName ref="https://orcid.org/0000-0002-0953-2818">
                        <forename>Torsten</forename>
                        <surname>Schrade</surname>
                    </persName>
                    <resp>
                        <note>Herausgeber</note>
                    </resp>
                </respStmt>
                <respStmt>
                    <persName ref="https://orcid.org/0000-0003-2423-7144">
                        <forename>Marjam</forename>
                        <surname>Trautmann</surname>
                    </persName>
                    <resp>
                        <note>Herausgeberin</note>
                    </resp>
                </respStmt>
            </titleStmt>
            <publicationStmt>
                <publisher>
                    <ref target="http://www.adwmainz.de">Akademie der Wissenschaften und der Literatur | Mainz</ref>
                </publisher>
                <pubPlace ref="http://sws.geonames.org/2874225">Mainz</pubPlace>
                <availability>
                    <licence target="https://creativecommons.org/licenses/by/4.0/">
                        This file is licensed under the terms of the Creative-Commons-License CC BY 4.0
                    </licence>
                </availability>
                <idno type="file">{$idno}</idno>
                <idno type="uri">https://sturm-edition.de/id/{replace($idno, '.xml', '')}</idno>
                <idno type="xml">https://sturm-edition.de/api/v1/files/{$idno}</idno>
                <date when="2018-04-01"/>
            </publicationStmt>
            <sourceDesc>
                <bibl>
                    {concat(replace($idno, '.xml', ''), ', ', $finalTitle)}, 
                    bearbeitet von Marjam Trautmann, in: Der STURM. Digitale Quellenedition zur Geschichte der internationalen 
                    Avantgarde, erarbeitet und herausgegeben von Marjam Trautmann und Torsten Schrade. 
                    Mainz, Akademie der Wissenschaften und der Literatur, 01.04.2018.
                    </bibl>
                <msDesc>
                    <msIdentifier>
                        <country>DE</country>
                        <settlement>Berlin</settlement>
                        <repository>{$repository}</repository>
                        <idno type="uri">{$uri}</idno>
                    </msIdentifier>
                </msDesc>
            </sourceDesc>
        </fileDesc>
        <xenoData type="uri">{$xenoData}</xenoData>
        <profileDesc xmlns="http://www.tei-c.org/ns/1.0">
            {$correspDesc}
        </profileDesc>
        <revisionDesc>
            <listChange>
                <change>
                    <date when="2018-04-01" n="1"/>
                </change>
            </listChange>
        </revisionDesc>
    </teiHeader>
(:
return update replace $header with $new
:)
return $new
