xquery version "3.0";

(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : XQuery for resolving all referenced normdata instances for persons, places and
 : works. Fetches names and additional information from the respective normdata
 : repositories, namely the GND, Wikidata and Geonames. The results are stored in
 : a single 'referenzen.xml' file that is the basis for the different XML and HTML
 : register generations. The resulting file is saved with a timestamp since its content
 : will be further edited (adding names that could not be resolved etc.).
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';
declare namespace rdfs = 'http://www.w3.org/2000/01/rdf-schema#';
declare namespace skos = 'http://www.w3.org/2004/02/skos/core#';
declare namespace marc21 = 'http://www.loc.gov/MARC21/slim';
declare namespace gn = 'http://www.geonames.org/ontology#';
declare namespace wgs84_pos = 'http://www.w3.org/2003/01/geo/wgs84_pos#';

declare variable $appRoot := '/db/apps/';
declare variable $appName := 'sturm-edition';
declare variable $sourceDir := concat($appRoot, $appName, '/xml/quellen/');
declare variable $targetDir := concat($appRoot, $appName, '/xml/register/');

let $colletion := collection($sourceDir)

let $registerContent := (
<listPerson xmlns="http://www.tei-c.org/ns/1.0">{
    for $ref in distinct-values($colletion//tei:persName/@ref)
        let $data := 
            if (contains($ref, 'gnd')) then (
                for $gnd in doc(concat(replace($ref, 'http', 'https'), '/about/marcxml'))
                return <persName>{functx:trim($gnd//marc21:datafield[@tag = '100']/marc21:subfield[@code = 'a']/text())}</persName>
            )
            else if (contains($ref, 'wikidata')) then (
                for $wikidata in doc(concat('https://www.wikidata.org/wiki/Special:EntityData/', replace($ref, 'http://www.wikidata.org/entity/', ''), '.rdf'))
                return <persName>{functx:trim($wikidata//rdf:Description[@rdf:about = $ref]/skos:prefLabel[@lang = 'de']/text()|$wikidata//rdf:Description[@rdf:about = $ref]/skos:prefLabel[@lang = 'en']/text()|$wikidata//rdf:Description[@rdf:about = $ref]/rdfs:label[1]/text())}</persName>
            )
            else (
                for $person in $colletion//tei:persName[@ref = $ref]/text()
                return <persName>{functx:trim($person)}</persName>
            )
    return <person source="{$ref}">{functx:distinct-deep($data)}</person>
}</listPerson>,
<listPlace xmlns="http://www.tei-c.org/ns/1.0">{
    for $ref in distinct-values($colletion//tei:placeName/@ref)
        let $data := 
            if (contains($ref, 'geonames')) then (
                for $geonames in doc(concat($ref, '/about.rdf'))
                    let $placeName := <placeName>{functx:trim($geonames//gn:alternateName[xml:lang = 'de']/text()|$geonames//gn:name/text())}</placeName>
                    let $coordinates := <location><geo>{concat(functx:trim($geonames//wgs84_pos:lat/text()), ' ', functx:trim($geonames//wgs84_pos:long/text()))}</geo></location>
                return ($placeName, $coordinates)
            )
            else (
                for $place in $colletion//tei:placeName[@ref = $ref]/text()
                return <placeName>{functx:trim($place)}</placeName>
            )
    return <place source="{$ref}">{functx:distinct-deep($data)}</place>
}</listPlace>,
<list n="terms" xmlns="http://www.tei-c.org/ns/1.0">{
    let $terms :=
        for $term in $colletion//tei:term
            let $key := $term/@key
        group by $key
        order by $key
        return $term
    let $distinctTerms := <distinctTerms>{functx:distinct-deep($terms)}</distinctTerms>
    let $items :=
        for $key in distinct-values($distinctTerms//term/@key)
            let $data :=
                for $term in $distinctTerms//term[@key = $key]
                return if ($term/@ref) then (<ref target="{$term/@ref}"/>, <name>{$term/data()}</name>)
                        else <name>{functx:trim($term/data())}</name>
        return <item source="{$key}" n="{distinct-values($distinctTerms//term[@key = $key]/@type)}">{functx:distinct-deep($data)}</item>
    return $items
}</list>
)

let $transformationParameters := 
    <parameters>
        <param name="registerName" value="Register referenzierter Entitäten mit aufgelösten Normdaten" />
        <param name="registerFile" value="referenzen.xml" />
        <param name="registerDate" value="{current-date()}" />
        <param name="registerDescription" value="Enthält alle in den Briefen referenzierten Entitäten mit aufgelösten Normdaten bzw. Textstellen bei internen Referenzen" />
    </parameters>

let $xsl := doc(concat($appRoot, $appName, '/xslt/registers.xsl'))
let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

let $filename := concat('referenzen_', substring(string(current-date()), 1, 10), '.xml')
let $storeToDB := xmldb:store($targetDir, $filename, normalize-space(serialize($xml)))

return <processed>{$filename}</processed>
