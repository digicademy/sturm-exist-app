xquery version "3.0";

(:
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : XQuery based URI Resolver. Resolvers URIs of type http://sturm-edition.de/id/###ID###
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)

module namespace sturm_resolver = 'https://sturm-edition.de/sturm_resolver';

import module namespace functx = 'http://www.functx.com';

declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare variable $sturm_resolver:appRoot := '/db/apps/';
declare variable $sturm_resolver:appName := 'sturm-edition';
declare variable $sturm_resolver:apiURL := 'api/';
declare variable $sturm_resolver:baseURL := 'https://sturm-edition.de/';

(: ########## FUNCTIONS ##################################################################################################### :)

declare function sturm_resolver:getUrlByIdentifier($identifier as xs:string, $version as xs:integer, $format as xs:string) {

    let $index := (
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/briefe.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/orte.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/personen.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/werke.xml'))
    )

    let $resource := $index//*[@xml:id = $identifier]

    let $processedVersion := doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/temp/processed.xml'))//processed[@source = $identifier and @version = $version][1]

    let $url := 
        if (name($resource) eq 'item' and $resource/@n eq 'letter' and exists($processedVersion)) then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'quellen/briefe/chronologie/', $processedVersion/text())
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'letters/', $resource/@xml:id)
        else if (name($resource) eq 'person' and exists($processedVersion)) then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/personen/', $processedVersion/text())
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'persons/', $resource/@xml:id)
        else if (name($resource) eq 'place' and exists($processedVersion)) then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/orte/', $processedVersion/text())
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'places/', $resource/@xml:id)
        else if (name($resource) eq 'item' and exists($resource/@n) and $resource/@n ne 'letter' and exists($processedVersion)) then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/werke/', $processedVersion/text())
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'works/', $resource/@xml:id)
        else (
            response:set-status-code(404),
            concat($sturm_resolver:baseURL, '404.html')
        )

    return $url
};

declare function sturm_resolver:getLatestVersionForIdentifier($identifier as xs:string) {
    let $processed := doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/temp/processed.xml'))

    let $versions :=
        for $entry in $processed//processed[@source = $identifier]
        order by $entry/@version descending
        return $entry

    let $version := $versions[1]/@version

    return if (exists($version)) then $version else 1
};

declare function sturm_resolver:resolveUri() {

    (: set request and response format :)
    let $requestFormat := 
        if (request:get-header('Accept') = 'application/json') then 'application/json' 
        else if (request:get-header('Accept') = 'application/xml') then 'application/xml'
        else 'text/html'
    let $format := functx:substring-after-last($requestFormat, '/')
    let $responseFormat := response:set-header('Content-Type', concat($requestFormat, ' ', 'charset=UTF-8'))

    (: analyse request path :)
    let $requestPath := replace(request:get-uri(), '/exist/apps/sturm-edition/html/id/', '')
    let $requestSegments := tokenize($requestPath, '/')
    let $requestSegmentCount := xs:integer(count(tokenize($requestPath, '/')))

    (: resolve url :)
    let $url :=
        if ($requestSegmentCount gt 2) then
            (
                response:set-status-code(404),
                concat($sturm_resolver:baseURL, '404.html')
            )
        else if ($requestSegmentCount eq 1) then
            sturm_resolver:getUrlByIdentifier($requestSegments[1], sturm_resolver:getLatestVersionForIdentifier($requestSegments[1]), $format)
        else if ($requestSegmentCount eq 2 and functx:is-a-number($requestSegments[2])) then
            sturm_resolver:getUrlByIdentifier($requestSegments[1], xs:integer($requestSegments[2]), $format)
        else 
            (
                response:set-status-code(404),
                concat($sturm_resolver:baseURL, '404.html')
            )

    return $url
};