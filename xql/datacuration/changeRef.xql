xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

for $doc in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')
    for $ref in $doc//tei:ref
        order by $doc/tei:TEI/@xml:id
        return if (contains($ref/@target, '.xml')) then
            <doc id="{$doc/tei:TEI/@xml:id}">{$ref}</doc>
        else ()