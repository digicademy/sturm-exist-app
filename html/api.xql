xquery version "3.0";

(:~
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : XQuery based REST API
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
 : 
 : API architecture: api-entry-point/collection/resource-id
 :
 : /api/
 :     letters
 :            /Q.01.19140115.FMA.01
 :     places
 :            /O.0000001
 :     persons
 :            /P.0000001
 :     works
 :            /W.0000001
 :     files
 :            /Q.01.19140115.FMA.01.xml
 :            /projekt.xml
:)

import module namespace functx = 'http://www.functx.com';
import module namespace sturm_serialize = 'https://sturm-edition.de/sturm_serialize' at '../xql/utilities/serializer.xqm';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace sturm_api = 'https://sturm-edition.de/sturm_api';

declare variable $appRoot := '/db/apps/';
declare variable $appName := 'sturm-edition';

(: ########## FUNCTIONS ##################################################################################################### :)

declare function sturm_api:getResourceCollection($type as xs:string, $format as xs:string) {

    let $resource := 
        if ($type eq 'letters') then
            doc('../xml/register/briefe.xml')
        else if ($type eq 'persons') then
            doc('../xml/register/personen.xml')
        else if ($type eq 'places') then
            doc('../xml/register/orte.xml')
        else if ($type eq 'works') then
            doc('../xml/register/werke.xml')
        else if ($type eq 'files') then
            <files>{(
                for $page in collection(concat($appRoot, $appName, '/xml/seiten/'))
                    return <idno key="{$page//tei:TEI/@xml:id}" type="page" version="{$page//tei:change[1]/tei:date/@n}">{concat('S.', substring-after(util:document-name($page), 'S.'))}</idno>,
                for $versionedPage in collection(concat($appRoot, $appName, '/xml/versionen/seiten/'))
                    return <idno key="{$versionedPage//tei:TEI/@xml:id}" type="page" version="{$versionedPage//tei:change[1]/tei:date/@n}">{concat('S.', substring-after(util:document-name($versionedPage), 'S.'))}</idno>,
                for $register in collection(concat($appRoot, $appName, '/xml/register/'))
                    return <idno key="{replace(util:document-name($register), '.xml', '')}" type="register" version="1">{util:document-name($register)}</idno>,
                for $letter in collection(concat($appRoot, $appName, '/xml/quellen/01.briefe/'))
                    return <idno key="{$letter//tei:TEI/@xml:id}" type="letter" version="{$letter//tei:change[1]/tei:date/@n}">{util:document-name($letter)}</idno>,
                for $versionedLetter in collection(concat($appRoot, $appName, '/xml/versionen/quellen/01.briefe/'))
                    return <idno key="{$versionedLetter//tei:TEI/@xml:id}" type="letter" version="{$versionedLetter//tei:change[1]/tei:date/@n}">{util:document-name($versionedLetter)}</idno>
            )}</files>
        else ()

    let $result :=
        if (not(exists($resource))) then
            response:set-status-code(404)
        else if ($format eq 'json') then
            if ($type eq 'letters') then
                sturm_serialize:Json(<root>{$resource//tei:item}</root>)
            else if ($type eq 'persons') then
                sturm_serialize:Json(<root>{$resource//tei:person}</root>)
            else if ($type eq 'places') then
                sturm_serialize:Json(<root>{$resource//tei:place}</root>)
            else if ($type eq 'works') then
                sturm_serialize:Json(<root>{$resource//tei:item}</root>)
            else if ($type eq 'files') then
                sturm_serialize:Json($resource)
            else ()
        else $resource

    return $result
};

declare function sturm_api:getResourceByIdentifier($identifier as xs:string, $type as xs:string, $format as xs:string) {

    let $processedFileIndex := doc(concat($appRoot, $appName, '/temp/processed.xml'))

    let $resource := 
        if ($type eq 'letter') then
            doc(concat($appRoot, $appName, '/xml/register/briefe.xml'))//tei:item[@xml:id = $identifier]
        else if ($type eq 'person') then
            doc(concat($appRoot, $appName, '/xml/register/personen.xml'))//tei:person[@xml:id = $identifier]
        else if ($type eq 'place') then
            doc(concat($appRoot, $appName, '/xml/register/orte.xml'))//tei:place[@xml:id = $identifier]
        else if ($type eq 'work') then
            doc(concat($appRoot, $appName, '/xml/register/werke.xml'))//tei:item[@xml:id = $identifier]
        else if ($type eq 'file') then
            if ($processedFileIndex//processed[@filekey = $identifier]) then
                doc($processedFileIndex//processed[@filekey = $identifier][1]/@source)
            else ()
        else ()

    let $result :=
        if (not(exists($resource))) then
            response:set-status-code(404)
        else if ($format eq 'json') then
            sturm_serialize:Json(<root>{$resource}</root>)
        else $resource

    return $result
};

declare function sturm_api:getSourcesFileIndex($path as xs:string) {
    for $artist in xmldb:get-child-collections(concat($appRoot, $appName, $path))
        let $yearItems :=
            for $year in xmldb:get-child-collections(concat($appRoot, $appName, $path, $artist, '/'))
                let $fileItems := 
                    for $file in collection(concat($appRoot, $appName, $path, $artist, '/', $year, '/'))
                        let $itemName := $file//tei:publicationStmt/tei:idno[@type = 'file']/text()
                    return <file id="{$itemName}" ref="{concat($appRoot, $appName, $path, $artist, '/', $year, '/', $itemName)}" />
             return $fileItems
    return $yearItems
};

(: ########## MAIN QUERY BODY ############################################################################################### :)

(: set request and response format :)
let $requestFormat := if (request:get-header('Accept') = 'application/json') then 'application/json' else 'application/xml'
let $format := functx:substring-after-last($requestFormat, '/')
let $responseFormat := response:set-header('Content-Type', concat($requestFormat, ' ', 'charset=UTF-8'))

(: analyse request path :)
let $requestPath := replace(request:get-uri(), '/exist/apps/sturm-edition/html/api/', '')
let $requestSegments := xs:integer(count(tokenize($requestPath, '/')))

(: generate response :)
let $response :=
    if ($requestSegments gt 2) then

        response:set-status-code(404)

    else if (matches($requestPath, '^letters$') or matches($requestPath, '^letters/')) then

        if ($requestSegments eq 2 and functx:substring-after-last($requestPath, '/') ne '') then
            sturm_api:getResourceByIdentifier(functx:substring-after-last($requestPath, '/'), 'letter', $format)
        else 
            sturm_api:getResourceCollection('letters', $format)

    else if (matches($requestPath, '^persons$') or matches($requestPath, '^persons/')) then

        if ($requestSegments eq 2 and functx:substring-after-last($requestPath, '/') ne '') then
            sturm_api:getResourceByIdentifier(functx:substring-after-last($requestPath, '/'), 'person', $format)
        else 
            sturm_api:getResourceCollection('persons', $format)

    else if (matches($requestPath, '^places$') or matches($requestPath, '^places/')) then

        if ($requestSegments eq 2 and functx:substring-after-last($requestPath, '/') ne '') then
            sturm_api:getResourceByIdentifier(functx:substring-after-last($requestPath, '/'), 'place', $format)
        else 
            sturm_api:getResourceCollection('places', $format)

    else if (matches($requestPath, '^works$') or matches($requestPath, '^works/')) then

        if ($requestSegments eq 2 and functx:substring-after-last($requestPath, '/') ne '') then
            sturm_api:getResourceByIdentifier(functx:substring-after-last($requestPath, '/'), 'work', $format)
        else 
            sturm_api:getResourceCollection('works', $format)

    else if (matches($requestPath, '^files$') or matches($requestPath, '^files/')) then

        if ($requestSegments eq 2 and functx:substring-after-last($requestPath, '/') ne '') then
            sturm_api:getResourceByIdentifier(functx:substring-after-last($requestPath, '/'), 'file', $format)
        else 
            sturm_api:getResourceCollection('files', $format)

    else response:set-status-code(404)

return $response