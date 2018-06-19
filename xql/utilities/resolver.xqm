xquery version "3.0";

(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
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
declare variable $sturm_resolver:apiURL := 'api/v1/';
declare variable $sturm_resolver:baseURL := 'https://sturm-edition.de/';

(: ########## FUNCTIONS ##################################################################################################### :)

declare function sturm_resolver:getUrlByIdentifier($identifier as xs:string, $format as xs:string) {

    let $index := (
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/briefe.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/orte.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/personen.xml')),
        doc(concat($sturm_resolver:appRoot, $sturm_resolver:appName, '/xml/register/werke.xml'))
    )

    let $resource := $index//*[@xml:id = $identifier]

    let $url := 
        if (name($resource) eq 'item' and $resource/@n eq 'letter') then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'quellen/briefe/chronologie/', replace($resource//tei:ref[1]/@target, '.xml', '.html'))
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'letters/', $resource/@xml:id)
        else if (name($resource) eq 'person') then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/personen/', $resource/@xml:id, '.html')
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'persons/', $resource/@xml:id)
        else if (name($resource) eq 'place') then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/orte/', $resource/@xml:id, '.html')
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'places/', $resource/@xml:id)
        else if (name($resource) eq 'item' and exists($resource/@n) and $resource/@n ne 'letter') then
            if ($format eq 'html') then
                concat($sturm_resolver:baseURL, 'register/werke/', $resource/@xml:id, '.html')
            else concat($sturm_resolver:baseURL, $sturm_resolver:apiURL, 'works/', $resource/@xml:id)
        else (
            response:set-status-code(404),
            concat($sturm_resolver:baseURL, '404.html')
        )

    return $url
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
    let $requestSegments := xs:integer(count(tokenize($requestPath, '/')))
    
    (: resolve url :)
    let $url :=
        if ($requestSegments gt 1) then
            (
                response:set-status-code(404),
                concat($sturm_resolver:baseURL, '404.html')
            )
        else if ($requestSegments eq 1) then
            sturm_resolver:getUrlByIdentifier(functx:substring-after-last($requestPath,'/'), $format)
        else 
            (
                response:set-status-code(404),
                concat($sturm_resolver:baseURL, '404.html')
            )

    return $url
};