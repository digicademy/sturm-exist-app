xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

let $persons := doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:listPerson
let $sortedPersons := <listPerson xmlns="http://www.tei-c.org/ns/1.0">{
    for $person in doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:person
    order by $person/tei:persName[@type = 'pref']/text()
    return $person
}</listPerson>
(:
return update replace $persons with $sortedPersons
:)

let $places := doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:listPlace
let $sortedPlaces := <listPlace xmlns="http://www.tei-c.org/ns/1.0">{
    for $place in doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:place
    order by $place/tei:placeName[@type = 'pref']/text()
    return $place
}</listPlace>

(:
return update replace $places with $sortedPlaces
:)

let $works := doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:list[@n = 'terms']
let $sortedWorks := <list n='terms' xmlns="http://www.tei-c.org/ns/1.0">{
    for $work in doc('/db/apps/sturm-edition/xml/register/referenzen.xml/')//tei:item
    order by $work/tei:name[@type = 'pref']/text()
    return $work
}</list>

(:
return update replace $works with $sortedWorks
:)

return ()