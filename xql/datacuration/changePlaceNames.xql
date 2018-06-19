xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $distinctPlaces := doc('/db/apps/sturm-edition/xml/register/referenzen.xml')//tei:listPlace;

(:
for $placeName in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')/tei:TEI/tei:teiHeader/tei:profileDesc//tei:placeName[@ref]
:)

for $placeName in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')/tei:TEI/tei:text/tei:body//tei:placeName[@ref]


    let $placeId := $distinctPlaces//tei:place[@source = $placeName/@ref]/@xml:id
    let $newPlaceName :=
        if (contains($placeName/@ref, 'http')) then
        <placeName xmlns="http://www.tei-c.org/ns/1.0" key="{$placeId}" ref="{$placeName/@ref}">{$placeName/node()}</placeName>
        else 
        <placeName xmlns="http://www.tei-c.org/ns/1.0" key="{$placeId}" ref="{$placeId}">{$placeName/node()}</placeName>


return $placeName

(:
return update replace $placeName with $newPlaceName
:)