xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $distinctTerms := doc('/db/apps/sturm-edition/xml/register/referenzen.xml')//tei:list[@n = 'terms'];

for $term in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')//tei:term[@key]

    let $termId := $distinctTerms//tei:item[@source = $term/@key]/@xml:id
    let $source := if ($term/@ref) then $term/@ref else ()
    let $ref := if (contains($term/@key, 'http')) then $term/@key else ()
    let $type := $term/@type

    let $newTerm :=
        if (exists($source) and exists($ref)) then
        <term xmlns="http://www.tei-c.org/ns/1.0" type="{$type}" key="{$termId}" source="{$source}" ref="{$ref}">{$term/node()}</term>
        else if (exists($source)) then
        <term xmlns="http://www.tei-c.org/ns/1.0" type="{$type}" key="{$termId}" source="{$source}">{$term/node()}</term>
        else if (exists($ref)) then
        <term xmlns="http://www.tei-c.org/ns/1.0" type="{$type}" key="{$termId}" ref="{$ref}">{$term/node()}</term>
        else
        <term xmlns="http://www.tei-c.org/ns/1.0" type="{$type}" key="{$termId}">{$term/node()}</term>


return $term

(:
return update replace $term with $newTerm
:)