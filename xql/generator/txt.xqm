xquery version "3.0";

(:
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Module for generating TXT files
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)

module namespace sturm_txt = "https://sturm-edition.de/sturm_txt";

import module namespace functx = 'http://www.functx.com';
import module namespace sturm_serialize = 'https://sturm-edition.de/sturm_serialize' at '../utilities/serializer.xqm';

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function sturm_txt:Beacon($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $targetDir := concat($appRoot, $appName, $target)

    let $persons := doc(concat($appRoot, $appName, $source, 'personen.xml'))//tei:person[contains(@source, 'gnd')]
    let $places := doc(concat($appRoot, $appName, $source, 'orte.xml'))//tei:place[contains(@source, 'gnd')]
    let $works := doc(concat($appRoot, $appName, $source, 'werke.xml'))//tei:item[contains(@source, 'gnd')]

    let $personBeacon := sturm_txt:GenerateBeacon($persons, 'personen')
    let $placesBeacon := sturm_txt:GenerateBeacon($places, 'orte')
    let $worksBeacon := sturm_txt:GenerateBeacon($works, 'werke')

    let $storePersonBeacon := xmldb:store($targetDir, 'personen.txt', sturm_serialize:Txt($personBeacon))
    let $storePlacesBeacon := xmldb:store($targetDir, 'orte.txt', sturm_serialize:Txt($placesBeacon))
    let $storeWorksBeacon := xmldb:store($targetDir, 'werke.txt', sturm_serialize:Txt($worksBeacon))

    return (
        <processed timestamp="{current-dateTime()}">personen.txt</processed>,
        <processed timestamp="{current-dateTime()}">orte.txt</processed>,
        <processed timestamp="{current-dateTime()}">werke.txt</processed>
    )
};

declare function sturm_txt:GenerateBeacon($entities, $type as xs:string) {

    let $beaconHeader := (
'#FORMAT: BEACON
',
'#PREFIX: http://d-nb.info/gnd/
',
'#RELATION: http://www.w3.org/2000/01/rdf-schema#seeAlso
',
'#DESCRIPTION: Der STURM. Digitale Quellenedition zur Geschichte der europäischen Avantgarde
',
'#CREATOR: Torsten Schrade <Torsten.Schrade@adwmainz.de>
',
'#CONTACT: Torsten Schrade <Torsten.Schrade@adwmainz.de>
',
concat('#FEED: https://sturm-edition.de/beacon/', $type, '.txt
'),
'#UPDATE: monthly
',
'#INSTITUTION: Digital Academy - Academy of Sciences and Literature Mainz
'
)

    let $beaconRows := 
        for $entity in $entities
        return concat('
', $entity/replace(@source, 'http://d-nb.info/gnd/', ''), '||', 'https://sturm-edition.de/id/', $entity/@xml:id)

    return ($beaconHeader, $beaconRows)
};