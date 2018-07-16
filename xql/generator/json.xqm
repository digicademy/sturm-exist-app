xquery version "3.0";

(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Module for generating JSON files
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)

module namespace sturm_json = "https://sturm-edition.de/sturm_json";

import module namespace functx = 'http://www.functx.com';
import module namespace sturm_serialize = 'https://sturm-edition.de/sturm_serialize' at '../utilities/serializer.xqm';

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function sturm_json:Registers($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $targetDir := concat($appRoot, $appName, $target)

    let $lettersJSON := <root>{doc(concat($appRoot, $appName, $source, 'briefe.xml'))//tei:item}</root>
    let $personsJSON := <root>{doc(concat($appRoot, $appName, $source, 'personen.xml'))//tei:person}</root>
    let $placesJSON := <root>{doc(concat($appRoot, $appName, $source, 'orte.xml'))//tei:place}</root>
    let $worksJSON := <root>{doc(concat($appRoot, $appName, $source, 'werke.xml'))//tei:item}</root>

    let $storeToDB := xmldb:store($targetDir, 'briefe.json', sturm_serialize:Json($lettersJSON))
    let $storeToDB := xmldb:store($targetDir, 'personen.json', sturm_serialize:Json($personsJSON))
    let $storeToDB := xmldb:store($targetDir, 'orte.json', sturm_serialize:Json($placesJSON))
    let $storeToDB := xmldb:store($targetDir, 'werke.json', sturm_serialize:Json($worksJSON))

    return 
        <processed timestamp="{current-dateTime()}">briefe.json</processed>,
        <processed timestamp="{current-dateTime()}">personen.json</processed>,
        <processed timestamp="{current-dateTime()}">orte.json</processed>,
        <processed timestamp="{current-dateTime()}">werke.json</processed>
};