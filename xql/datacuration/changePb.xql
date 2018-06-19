xquery version "3.0";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

for $pb in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')//tei:pb
    let $newPb := <pb xmlns="http://www.tei-c.org/ns/1.0" xml:id="{concat('S.', $pb/@n)}" n="{$pb/@n}" facs="{$pb/@facs}"/>
order by $pb/@n

(:
return update replace $pb with $newPb
:)
return $pb

(: find duplicate ids
let $docs :=
for $doc in collection('/db/apps/sturm-edition/xml/quellen/01.briefe/')
    for $id in distinct-values($doc//tei:pb/@xml:id)
    where count($doc//tei:pb[@xml:id eq $id]) gt 1
    order by $doc/tei:TEI/@xml:id
    return <doc>{concat($doc/tei:TEI/@xml:id, ' - ', $id)}</doc>

return <root>{$docs}</root>
:)