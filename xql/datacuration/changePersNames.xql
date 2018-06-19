xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $distinctPersons := doc('/db/apps/sturm-edition/xml/register/referenzen.xml')//tei:listPerson;

(:
for $persName in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')/tei:TEI/tei:teiHeader/tei:profileDesc//tei:persName
:)
for $persName in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')/tei:TEI/tei:text/tei:body//tei:persName

    let $personId := $distinctPersons//tei:person[@source = $persName/@ref]/@xml:id
    let $newPersName :=
        if (contains($persName/@ref, 'http')) then
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="{$personId}" ref="{$persName/@ref}">{$persName/node()}</persName>
        else 
        <persName xmlns="http://www.tei-c.org/ns/1.0" key="{$personId}" ref="{$personId}">{$persName/node()}</persName>

return $persName

(:
return update replace $persName with $newPersName
:)