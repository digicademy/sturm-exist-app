xquery version "3.0";

(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Trautmann and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : XQuery based URI Resolver. Resolvers URIs of type http://sturm-edition.de/id/###ID###
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
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

    let $processedVersion := doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/temp/processed.xml'))//processed[@key = $identifier and @version = $version][1]

    let $htmlTargetPath := if (exists($processedVersion)) then
            concat($sturm_resolver:baseURL, replace($processedVersion/@target, concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/html/'), ''))
        else ''

    let $url := 
        if (exists($processedVersion) and $processedVersion/@type eq 'letter') then
            if ($format eq 'html') then $htmlTargetPath
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'letters/', $processedVersion/@key)
        else if (exists($processedVersion) and $processedVersion/@type eq 'person') then
            if ($format eq 'html') then $htmlTargetPath
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'persons/', $processedVersion/@key)
        else if (exists($processedVersion) and $processedVersion/@type eq 'place') then
            if ($format eq 'html') then $htmlTargetPath
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'places/', $processedVersion/@key)
        else if (exists($processedVersion) and $processedVersion/@type eq 'work') then
            if ($format eq 'html') then $htmlTargetPath
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'works/', $processedVersion/@key)
        else if (exists($processedVersion) and $processedVersion/@type eq 'page') then
            if ($format eq 'html') then $htmlTargetPath
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'files/', $processedVersion/@filekey)
        else (
            response:set-status-code(404),
            concat($sturm_resolver:baseURL, '404.html')
        )

    return $url
};

declare function sturm_resolver:getLatestVersionForIdentifier($identifier as xs:string) {
    let $processed := doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/temp/processed.xml'))

    let $versions :=
        for $entry in $processed//processed[@key = $identifier]
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