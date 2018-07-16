xquery version "3.0";

(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Core module of the STURM website generator. Contains the HTML generation functions
 : for the website pages, the edition and the registers.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)

module namespace sturm_html = "https://sturm-edition.de/sturm_html";

import module namespace functx = 'http://www.functx.com';
import module namespace sturm_serialize = 'https://sturm-edition.de/sturm_serialize' at '../utilities/serializer.xqm';

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function sturm_html:Pages($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))

    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))
    let $letters := collection(concat($appRoot, $appName, '/xml/quellen/01.briefe/'))
    let $lettersCount := count($letters//tei:TEI)
    let $personsCount := count($references//tei:person)
    let $placesCount := count($references//tei:place)
    let $worksCount := count($references//tei:list[@n = 'terms']/tei:item)

    for $doc at $index in $sourceDir//tei:TEI

        let $sourceDocPath := util:collection-name($doc)
        let $docPathComponents := tokenize($sourceDocPath, '/')
        let $idno := $doc//tei:publicationStmt//tei:idno[@type = 'file']
        let $version := $doc//tei:change[1]/tei:date/@n

        let $relativeToAppBase :=
            if (count($docPathComponents) eq 7) then '../'
            else ()

        let $parentCollection := functx:substring-after-last($sourceDocPath, '/')
        let $containsSubNavigation := exists($doc//tei:ab[@type = 'subNavigation']/@n)

        let $subNavigationPath := 
            if ($containsSubNavigation and count($docPathComponents) eq 6) then
                concat($doc//tei:ab[@type = 'subNavigation']/@n, '/')
            else ()

        let $finalTargetDir := 
            if ($containsSubNavigation and $parentCollection ne 'seiten') then
                string(concat($targetDir, $doc//tei:ab[@type = 'subNavigation']/@n, '/'))
            else $targetDir

        let $subNavigationCollection := 
            if ($containsSubNavigation) then
                collection(concat($appRoot, $appName, $source, '/', $doc//tei:ab[@type = 'subNavigation']/@n, '/'))
             else ()

(: not possible because eXist doesn't allow to pass on node sets as parameters to stylesheets
        let $subNavigation := 
            if ($containsSubNavigation) then <list xmlns="http://www.tei-c.org/ns/1.0">{
                for $page in $subNavigationCollection
                order by util:document-name($page) ascending
                return
                    <item xmlns="http://www.tei-c.org/ns/1.0">
                        <ref xmlns="http://www.tei-c.org/ns/1.0" target="{$page//tei:publicationStmt/tei:idno[@type='file']}">
                            {$page//tei:title/text()}
                        </ref>
                    </item>
                }</list>
            else ()
:)

        let $subNavigation := 
            if ($containsSubNavigation) then <list xmlns="http://www.tei-c.org/ns/1.0">{
                for $page in $subNavigationCollection
                    let $navigationTitle :=
                        if ($page//tei:title[@type = 'navigation']/text()) then $page//tei:title[@type = 'navigation']/text()
                        else $page//tei:title/text()
                order by util:document-name($page) ascending
                return
                    concat($subNavigationPath, $page//tei:publicationStmt/tei:idno[@type = 'file'], ':', replace($navigationTitle, ' ', '#'))
                }</list>
            else ()

        let $files := 
            <processed source="{replace($idno, '.xml', '')}" version="{$version}" timestamp="{current-dateTime()}">{
            sturm_html:TransformAndStoreHtml(
                $xsl, 
                <parameters>
                    <param name="transformation" value="page" />
                    <param name="lettersCount" value="{$lettersCount}" />
                    <param name="placesCount" value="{$placesCount}" />
                    <param name="personsCount" value="{$personsCount}" />
                    <param name="worksCount" value="{$worksCount}" />
                    <param name="subNavigation" value="{$subNavigation}" />
                    <param name="relativeToAppBase" value="{$relativeToAppBase}"/>
                    <param name="sourceDocPath" value="{$sourceDocPath}"/>
                    <param name="idno" value="{$idno}"/>
                </parameters>, 
                $doc, 
                $finalTargetDir
            )
            }</processed>

    return $files
};

declare function sturm_html:Letters($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))
    let $sources := doc(concat($appRoot, $appName, '/xml/register/quellen.xml'))
    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))

    let $sourcesByChronology :=
        for $doc in $sources//tei:ab[@n = '01']/tei:list[@n = 'chronological']//tei:item
            let $source := $doc/@source
            let $sourceFile := concat($source, '.html')
            let $pagination := sturm_html:LetterPagination($doc, $sources//tei:ab[@n = '01']/tei:list[@n = 'chronological'], $sourceFile)
            let $finalTargetDir := concat($targetDir, 'chronologie/')
            let $relativeToAppBase := '../../../'
            let $letter := $sourceDir//tei:TEI[@xml:id = $source]
        return if (exists($letter)) then 
            sturm_html:LetterTransformation($letter, $references, $pagination, $xsl, $finalTargetDir, $relativeToAppBase)
        else ()

    let $sourcesByArtists :=
        for $artist in $sources//tei:ab[@n = '01']/tei:list[@n = 'artists']//tei:list
            for $doc in $artist//tei:item
                let $source := $doc/@source
                let $sourceFile := concat($source, '.html')
                let $pagination := sturm_html:LetterPagination($doc, $artist, $sourceFile)
                let $finalTargetDir := concat($targetDir, lower-case($artist/@n), '/')
                let $relativeToAppBase := '../../../'
                let $letter := $sourceDir//tei:TEI[@xml:id = $source]
        return if ($letter and not(contains($letter//tei:idno[@type = 'file'], 'v'))) then 
            sturm_html:LetterTransformation($letter, $references, $pagination, $xsl, $finalTargetDir, $relativeToAppBase)
        else ()

    return ($sourcesByChronology, $sourcesByArtists)
};

declare function sturm_html:LetterPagination($doc as node(), $fileIndex as node(), $sourceFile as xs:string) {

    let $first := concat($fileIndex/tei:item[1]/@source, '.html')
    let $last := concat($fileIndex/tei:item[last()]/@source, '.html')
    let $previous := 
        if ($sourceFile ne $first) then 
            concat($doc/preceding-sibling::*[1]/@source, '.html')
        else $first
    let $next := 
        if ($sourceFile ne $last) then 
            concat($doc/following-sibling::*[1]/@source, '.html')
        else $last
    let $pagination := 
        <list xmlns="http://www.tei-c.org/ns/1.0">
            <item type="first" source="{$first}"/>
            <item type="previous" source="{$previous}"/>
            <item type="next" source="{$next}"/>
            <item type="last" source="{$last}"/>
        </list>

    return $pagination
};

declare function sturm_html:LetterTransformation($doc as node(), $references as node(), $pagination as node(), $xsl as node(), $targetDir as xs:string, $relativeToAppBase as xs:string) {

    let $sourceDocPath := util:collection-name($doc)
    let $idno := $doc//tei:publicationStmt//tei:idno[@type = 'file']
    let $version := $doc//tei:change[1]/tei:date/@n
    let $metadata := $doc//tei:xenoData/text()

    let $sender := $doc//tei:correspAction[@type = 'sent']/tei:persName/text()
    let $senderKey := $doc//tei:correspAction[@type = 'sent']/tei:persName/@key
    let $senderPrefName := $references//tei:person[@xml:id = $senderKey]/tei:persName[@type = 'pref']
    let $sourcetype := $doc//tei:text/@type
    let $repository := $doc//tei:repository/text()
    let $folios := data($doc//tei:correspDesc/@key)
    let $uri := data($doc//tei:msIdentifier/tei:idno[@type = 'uri'])
    let $doi := data($doc//tei:text/tei:term/@ref)
    let $dateISO := 
        if ($doc//tei:dateline/tei:date/@when) then data($doc//tei:dateline/tei:date/@when)
        else if ($doc//tei:correspAction[@type='sent']/tei:date/@from) then data($doc//tei:correspAction[@type='sent']/tei:date/@from)
        else if ($doc//tei:correspAction[@type='sent']/tei:date/@notBefore) then data($doc//tei:correspAction[@type='sent']/tei:date/@notBefore)
        else if ($doc//tei:correspAction[@type='sent']/tei:date/@notAfter) then data($doc//tei:correspAction[@type='sent']/tei:date/@notAfter)
        else "YYYY-MM-TT"
    let $dateString := data($doc//tei:correspAction[@type='sent']/tei:date/@*)
    let $placeName := 
        if ($doc//tei:correspAction[@type='sent']/tei:placeName/tei:placeName) then $doc//tei:correspAction[@type='sent']/tei:placeName/tei:placeName
        else $doc//tei:correspAction[@type='sent']/tei:placeName
    let $placeRef := 
        if ($doc//tei:correspAction[@type='sent']/tei:placeName/tei:placeName/@ref) then $doc//tei:correspAction[@type='sent']/tei:placeName/tei:placeName/@ref
        else $doc//tei:correspAction[@type='sent']/tei:placeName/@ref

    let $first := $pagination//tei:item[@type = 'first']/@source
    let $previous := $pagination//tei:item[@type = 'previous']/@source
    let $next := $pagination//tei:item[@type = 'next']/@source
    let $last := $pagination//tei:item[@type = 'last']/@source

    let $file := 
        <processed source="{substring($idno, 1, 20)}" version="{$version}" timestamp="{current-dateTime()}">{
        sturm_html:TransformAndStoreHtml(
            $xsl, 
            <parameters>
                <param name="transformation" value="letter" />
                <param name="sender" value="{$sender}"/>
                <param name="senderKey" value="{$senderKey}"/>
                <param name="senderPrefName" value="{$senderPrefName}"/>
                <param name="sourcetype" value="{$sourcetype}"/>
                <param name="repository" value="{$repository}"/>
                <param name="folios" value="{$folios}"/>
                <param name="uri" value="{$uri}"/>
                <param name="dateISO" value="{$dateISO}"/>
                <param name="dateString" value="{$dateString}"/>
                <param name="placeName" value="{$placeName}"/>
                <param name="placeRef" value="{$placeRef}"/>
                <param name="first" value="{$first}"/>
                <param name="previous" value="{$previous}"/>
                <param name="next" value="{$next}"/>
                <param name="last" value="{$last}"/>
                <param name="metadata" value="{$metadata}"/>
                <param name="relativeToAppBase" value="{$relativeToAppBase}"/>
                <param name="sourceDocPath" value="{$sourceDocPath}"/>
                <param name="targetDir" value="{$targetDir}"/>
                <param name="idno" value="{$idno}"/>
            </parameters>,
            $doc, 
            $targetDir
        )
        }</processed>

    return $file
};

declare function sturm_html:Registers($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))

    let $files := 
        for $doc at $index in $sourceDir//tei:TEI

            let $sourceDocPath := util:collection-name($doc)
            let $idno := $doc//tei:publicationStmt//tei:idno[@type = 'file']

        return 
            if ($doc//tei:publicationStmt/tei:idno[@type = 'file'] eq 'personen.xml') then
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="personsRegister" />
                        <param name="relativeToAppBase" value="../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    $doc, 
                    $targetDir
                )
                }</processed>
            else if ($doc//tei:publicationStmt//tei:idno[@type = 'file'] eq 'orte.xml') then
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="placesRegister" />
                        <param name="relativeToAppBase" value="../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    $doc, 
                    $targetDir
                )
                }</processed>
            else if ($doc//tei:publicationStmt//tei:idno[@type = 'file'] eq 'werke.xml') then
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="worksRegister" />
                        <param name="relativeToAppBase" value="../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    $doc, 
                    $targetDir
                )
                }</processed>
            else ()

    return $files
};

declare function sturm_html:Persons($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $personRegister := doc(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))
    let $teiXsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))

    let $files := 
        for $person in $personRegister//tei:person

            let $sourceDocPath := concat($appRoot, $appName, $source)
            let $idno := concat($person/@xml:id, '.xml')

            let $alphabet := <list n="alphabet" xmlns="http://www.tei-c.org/ns/1.0">{
                for $letter in $personRegister//tei:head
                return <item>{$letter/text()}</item>
            }</list>

            let $doc := transform:transform(
                ($person, $alphabet), 
                $teiXsl, 
                <parameters>
                    <param name="title" value="{$person/tei:persName[@type = 'pref']}" />
                    <param name="file" value="{$idno}"/>
                </parameters>
            )

            let $file := 
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="person" />
                        <param name="relativeToAppBase" value="../../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    <TEI xmlns="http://www.tei-c.org/ns/1.0">{$doc/node()}</TEI>, 
                    $targetDir
                )
                }</processed>

        return $file

    return $files
};

declare function sturm_html:Places($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $placesRegister := doc(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))
    let $teiXsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))

    let $files := 
        for $place in $placesRegister//tei:place

            let $sourceDocPath := concat($appRoot, $appName, $source)
            let $idno := concat($place/@xml:id, '.xml')

            let $alphabet := <list n="alphabet" xmlns="http://www.tei-c.org/ns/1.0">{
                for $letter in $placesRegister//tei:head
                return <item>{$letter/text()}</item>
            }</list>

            let $doc := transform:transform(
                ($place, $alphabet), 
                $teiXsl, 
                <parameters>
                    <param name="title" value="{$place/tei:placeName[@type = 'pref']}" />
                    <param name="file" value="{$idno}"/>
                </parameters>
            )

            let $file := 
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="person" />
                        <param name="relativeToAppBase" value="../../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    <TEI xmlns="http://www.tei-c.org/ns/1.0">{$doc/node()}</TEI>, 
                    $targetDir
                )
                }</processed>

        return $file

    return $files
};

declare function sturm_html:Works($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $worksRegister := doc(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))
    let $teiXsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))

    let $files := 
        for $work in $worksRegister//tei:item

            let $sourceDocPath := concat($appRoot, $appName, $source)
            let $idno := concat($work/@xml:id, '.xml')

            let $alphabet := <list n="alphabet" xmlns="http://www.tei-c.org/ns/1.0">{
                for $letter in $worksRegister//tei:head
                return <item>{$letter/text()}</item>
            }</list>

            let $doc := transform:transform(
                ($work, $alphabet), 
                $teiXsl, 
                <parameters>
                    <param name="title" value="{$work/tei:name[@type = 'pref']}" />
                    <param name="file" value="{$idno}"/>
                </parameters>
            )

            let $file := 
                <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
                sturm_html:TransformAndStoreHtml(
                    $xsl, 
                    <parameters>
                        <param name="transformation" value="person" />
                        <param name="relativeToAppBase" value="../../"/>
                        <param name="sourceDocPath" value="{$sourceDocPath}"/>
                        <param name="idno" value="{$idno}"/>
                    </parameters>, 
                    <TEI xmlns="http://www.tei-c.org/ns/1.0">{$doc/node()}</TEI>, 
                    $targetDir
                )
                }</processed>

        return $file

    return $files
};

declare function sturm_html:Sources($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $template := doc(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $xsl := doc(concat($appRoot, $appName, '/xslt/main.xsl'))

    let $sources := doc(concat($appRoot, $appName, '/xml/register/quellen.xml'))
    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))

    let $artists := data($sources//tei:ab[@n = '01']/tei:list[@n = 'artists']/tei:item/tei:list/@n)
    
    let $templateItems := ('chronologie', $artists)

    for $templateItem in $templateItems

        let $sourceDocPath := concat('/quellen/briefe/', lower-case($templateItem), '.xml')
        let $idno := concat(lower-case($templateItem), '.xml')
        let $relativeToAppBase := '../../'

        let $subNavigationCollection := collection(concat($appRoot, $appName, '/xml/seiten/quellen/'))
        let $subNavigation := <list xmlns="http://www.tei-c.org/ns/1.0">{
            for $page in $subNavigationCollection
                let $navigationTitle :=
                    if ($page//tei:title[@type = 'navigation']/text()) then $page//tei:title[@type = 'navigation']/text()
                    else $page//tei:title/text()
            order by util:document-name($page) ascending
            return
                concat('../', $page//tei:publicationStmt/tei:idno[@type = 'file'], ':', replace($navigationTitle, ' ', '#'))
            }</list>

        let $title := 
            if ($references//tei:person[@n = $templateItem]) 
                then concat('Briefe von ', $references//tei:person[@n = $templateItem]/tei:persName[@type = 'fn']/text(), ' an Herwarth Walden')
            else 'Chronologische Übersicht der Briefe in Abteilung I'

        let $teiHeader := 
            <teiHeader xmlns="http://www.tei-c.org/ns/1.0">
                <fileDesc>
                    <titleStmt>
                        <title>{$title}</title>
                    </titleStmt>
                    <publicationStmt>
                        <idno type="file">{$idno}</idno>
                    </publicationStmt>
                </fileDesc>
            </teiHeader>

        let $sourceList :=
            if ($templateItem = 'chronologie') 
                then sturm_html:SplitByChronology($sources//tei:list[@n = 'chronological'])
            else sturm_html:SplitByChronology($sources//tei:list[@n = $templateItem])

        let $teiText := sturm_html:RenderContent($template//tei:text, $sourceList, $title)

        let $doc := 
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                {$teiHeader}
                {$teiText}
            </TEI>

         let $files := 
            <processed source="{replace($idno, '.xml', '')}" version="1" timestamp="{current-dateTime()}">{
            sturm_html:TransformAndStoreHtml(
                $xsl, 
                <parameters>
                    <param name="transformation" value="page" />
                    <param name="subNavigation" value="{$subNavigation}" />
                    <param name="relativeToAppBase" value="{$relativeToAppBase}"/>
                    <param name="sourceDocPath" value="{$sourceDocPath}"/>
                    <param name="idno" value="{$idno}"/>
                </parameters>, 
                $doc, 
                $targetDir
            )
            }</processed>

    return $files
};

declare function sturm_html:SplitByChronology($list as node()) {

    let $splittedList :=
        for $item in $list//tei:item
            let $year := $item/@sortKey
        group by $year
        order by $year
        return
            <list xmlns="http://www.tei-c.org/ns/1.0" source="{$year}" n="{$list/@n}" rend="{$list/@rend}">
                {$item}
            </list>

    return $splittedList
};

declare function sturm_html:RenderContent($element as element(), $content, $title as xs:string) {
    element {node-name($element)}
        { $element/@*,
            for $child in $element/node()
            return
                if ($child/@type = 'renderContent') 
                    then (
                        <ab rend="h3">{$title}</ab>, 
                        $content
                     )
                else if ($child instance of element())
                    then sturm_html:RenderContent($child, $content, $title)
                else $child
        }
};

declare function sturm_html:TransformAndStoreHtml($xsl as node(), $transformationParameters as node(), $doc as node(), $targetDir as xs:string) as xs:string {

    let $html := transform:transform($doc, $xsl, $transformationParameters)/node()
    let $targetFileName := replace($doc//tei:publicationStmt//tei:idno[@type = 'file']/text(), '.xml', '.html')
    let $storeToDB := xmldb:store($targetDir, $targetFileName, sturm_serialize:Html($html), 'html5')

    return $targetFileName
};
