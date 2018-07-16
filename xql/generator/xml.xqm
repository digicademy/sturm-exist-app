xquery version "3.0";

(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : Module with functions for dynamically generating TEI/XML based registers
 : (letters, persons, places and works) out of the published XML source files.
 : The TEI/XML registers are stored in the '/xml/register/' folder and are the 
 : basis for the generation of the HTML registers.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)

module namespace sturm_xml = "https://sturm-edition.de/sturm_xml";

import module namespace functx = 'http://www.functx.com';

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function sturm_xml:Sources($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := concat($appRoot, $appName, $source)
    let $targetDir := concat($appRoot, $appName, $target)

    let $departments := xmldb:get-child-collections($sourceDir)

    let $registerContent :=
        for $department in $departments

            let $departmentDir := concat($sourceDir, $department, '/')
            let $sourcesInDepartment := collection($departmentDir)

            let $departmentRegister := <ab n="{substring-before($department, '.')}" xmlns="http://www.tei-c.org/ns/1.0">{
                if (count($sourcesInDepartment//tei:TEI) > 0) then

                    let $sourcesByChronology := <list rend="sourcelist" n="chronological" xmlns="http://www.tei-c.org/ns/1.0">{
                        for $source in $sourcesInDepartment//tei:TEI
                            let $sourceId := $source/@xml:id
                            let $title := $source//tei:titleStmt/tei:title/text()
                        order by $sourceId
                        return <item source="{$sourceId}" n="chronological" sortKey="{substring($sourceId, 6, 4)}" xmlns="http://www.tei-c.org/ns/1.0">{$title}</item>
                        }</list>

                    let $sourcesByArtistAndYear := <list n="artists" xmlns="http://www.tei-c.org/ns/1.0">{
                        for $year in xmldb:get-child-collections($departmentDir)
                            for $artist in xmldb:get-child-collections(concat($departmentDir, $year, '/'))
                                let $fileItems := <list n="{$artist}" xmlns="http://www.tei-c.org/ns/1.0">{
                                    for $source in collection(concat($departmentDir, $year, '/', $artist, '/'))//tei:TEI
                                        let $sourceId := $source/@xml:id
                                        let $title := $source//tei:titleStmt/tei:title/text()
                                    order by $sourceId
                                    return <item source="{$sourceId}" n="{$artist}" sortKey="{substring($sourceId, 6, 4)}" xmlns="http://www.tei-c.org/ns/1.0">{$title}</item>
                                    }</list>
                            order by $artist
                        order by $year
                        return $fileItems
                        }</list>

                    let $artists := distinct-values($sourcesByArtistAndYear//tei:list/@n)
                    let $sourcesByArtistAndChronology :=  <list n="artists" xmlns="http://www.tei-c.org/ns/1.0">{
                        for $artist in $artists
                        return 
                            <item xmlns="http://www.tei-c.org/ns/1.0">
                                <list n="{$artist}" rend="sourcelist">
                                    {$sourcesByArtistAndYear//tei:list[@n = $artist]//tei:item}
                                </list>
                            </item>
                        }</list>

                    return ($sourcesByChronology, $sourcesByArtistAndChronology)
                 else ()
             }</ab>
            order by $department
            return $departmentRegister

    let $transformationParameters := 
        <parameters>
            <param name="title" value="Quellenregister" />
            <param name="editorName" value="Marjam Trautmann" />
            <param name="editorEmail" value="Marjam.Trautmann@adwmainz.de" />
            <param name="file" value="quellen.xml" />
            <param name="date" value="{current-date()}" />
            <param name="description" value="Register aller publizierten Quellen sortiert nach Chronologie, Künstlern und Jahren" />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

    let $filename := 'quellen.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>
};

declare function sturm_xml:Letters($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := concat($appRoot, $appName, $source)
    let $targetDir := concat($appRoot, $appName, $target)

    let $lettersByArtistAndYear :=
        for $artist in xmldb:get-child-collections($sourceDir)
            let $yearItems :=
                for $year in xmldb:get-child-collections(concat($sourceDir, $artist, '/'))
                    let $fileItems := 
                        for $file in collection(concat($sourceDir, $artist, '/', $year, '/'))
                            let $itemName := $file//tei:publicationStmt/tei:idno[@type = 'file']/text()
                            let $placeName := 
                                if ($file//tei:correspAction[@type='sent']/tei:placeName/tei:placeName) then $file//tei:correspAction[@type='sent']/tei:placeName/tei:placeName
                                else $file//tei:correspAction[@type='sent']/tei:placeName
                            let $fileItem := 
                                <item xmlns="http://www.tei-c.org/ns/1.0" source="{data($file//tei:publicationStmt/tei:idno[@type='uri'])}" xml:id="{$file/tei:TEI/@xml:id}" n="letter">
                                    <ref target="{$itemName}"><time when="{data($file//tei:correspAction[@type='sent']/tei:date/@*)}">{data($file//tei:correspAction[@type='sent']/tei:date/@*)}</time>, <placeName>{data($placeName)}</placeName></ref>,<ref target="{data($file//tei:msIdentifier/tei:idno[@type='uri'])}">Sturm Archiv I, {data($file//tei:correspDesc/@key)}</ref>
                                </item>
                        order by $itemName
                        return $fileItem
                    let $yearItem := <list n="{$year}" xmlns="http://www.tei-c.org/ns/1.0">{$fileItems}</list>
                return $yearItem
            let $artistItem := <item n="{$artist}" xmlns="http://www.tei-c.org/ns/1.0">{$yearItems}</item>
        return $artistItem

    let $registerContent := <list n="letters" xmlns="http://www.tei-c.org/ns/1.0">{$lettersByArtistAndYear}</list>

    let $transformationParameters := 
        <parameters>
            <param name="title" value="Chronologische Liste der edierten Briefe" />
            <param name="editorName" value="Marjam Trautmann" />
            <param name="editorEmail" value="Marjam.Trautmann@adwmainz.de" />
            <param name="file" value="briefe.xml" />
            <param name="date" value="{current-date()}" />
            <param name="description" value="Register aller publizierten Briefe sortiert nach Künstlern und Jahren" />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

    let $filename := 'briefe.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>
};

declare function sturm_xml:Persons($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))

    let $personsInDocuments := 
        for $doc in $sourceDir//tei:TEI
            let $body := $doc//tei:body
            let $persons := 
                for $key in distinct-values($body//tei:persName/@key)
                return <person key="{$key}" folio="{$doc//tei:correspDesc/@key}" file="{$doc//tei:idno[@type = 'file']}" text="{$doc//tei:persName[@key = $key]/text()}" />
        return <personsInDocuments>{$persons}</personsInDocuments>

    let $personsAndFolios :=
        for $key in distinct-values($personsInDocuments//person/@key)
            let $name := $references//tei:person[@xml:id = $key]/tei:persName
            let $source := $references//tei:person[@xml:id = $key]/@source
            let $foliosAndIdnos :=
                for $person in $personsInDocuments//person[@key = $key]
                return <ptr xmlns="http://www.tei-c.org/ns/1.0" n="{$person/@folio}" target="{$person/@file}"/>
        return if (exists($source)) then
            <person xmlns="http://www.tei-c.org/ns/1.0" source="{$source}" xml:id="{$key}">{$name}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></person>
        else
            <person xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$key}">{$name}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></person>

    (: group by and order by cannot handle separate values within one FLOWR, therefore we need two :)

    let $alphabeticList :=
        for $person in $personsAndFolios
            let $persName := $person//tei:persName[1]/text()
        order by $persName
        return $person

    let $groupedAlphabeticList :=
        for $person in $alphabeticList
            let $firstLetter := substring($person//tei:persName[1]/text(), 1, 1)
        group by $firstLetter
        return <listPerson xmlns="http://www.tei-c.org/ns/1.0"><head>{upper-case($firstLetter)}</head>{$person}</listPerson>

    let $registerContent := <listPerson xmlns="http://www.tei-c.org/ns/1.0">{$groupedAlphabeticList}</listPerson>

    let $transformationParameters := 
        <parameters>
            <param name="title" value="Personenregister" />
            <param name="editorName" value="Marjam Trautmann" />
            <param name="editorEmail" value="Marjam.Trautmann@adwmainz.de" />
            <param name="file" value="personen.xml" />
            <param name="date" value="{current-date()}" />
            <param name="description" value="Alphabetisches Register aller Personen mit zugehörigen Folios und Dateien" />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

    let $filename := 'personen.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>
};

declare function sturm_xml:Places($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))

    let $placesInDocuments := 
        for $doc in $sourceDir//tei:TEI
            let $places := 
                for $key in distinct-values($doc//tei:placeName/@key)
                return <place key="{$key}" folio="{$doc//tei:correspDesc/@key}" file="{$doc//tei:idno[@type = 'file']}" text="{$doc//tei:placeName[@key = $key]/text()}" />
        return <placesInDocuments>{$places}</placesInDocuments>

    let $placesAndFolios :=
        for $key in distinct-values($placesInDocuments//place/@key)
            let $name := $references//tei:place[@xml:id = $key]/tei:placeName
            let $source := $references//tei:place[@xml:id = $key]/@source
            let $location := <location xmlns="http://www.tei-c.org/ns/1.0">{$references//tei:place[@xml:id = $key]/tei:location/tei:geo}</location>
            let $foliosAndIdnos :=
                for $place in $placesInDocuments//place[@key = $key]
                return <ptr xmlns="http://www.tei-c.org/ns/1.0" n="{$place/@folio}" target="{$place/@file}"/>
        return if (exists($source)) then
            <place xmlns="http://www.tei-c.org/ns/1.0" source="{$source}" xml:id="{$key}">{$name, $location}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></place>
        else 
            <place xmlns="http://www.tei-c.org/ns/1.0" xml:id="{$key}">{$name, $location}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></place>

    (: group by and order by cannot handle separate values within one FLOWR, therefore we need two :)

    let $alphabeticList :=
        for $place in $placesAndFolios
            let $placeName := $place//tei:placeName[1]/text()
        order by $placeName
        return $place

    let $groupedAlphabeticList :=
        for $place in $alphabeticList
            let $firstLetter := substring($place//tei:placeName[1]/text(), 1, 1)
        group by $firstLetter
        return <listPlace xmlns="http://www.tei-c.org/ns/1.0"><head>{upper-case($firstLetter)}</head>{$place}</listPlace>

    let $registerContent := <listPlace xmlns="http://www.tei-c.org/ns/1.0">{$groupedAlphabeticList}</listPlace>

    let $transformationParameters := 
        <parameters>
            <param name="title" value="Ortsregister" />
            <param name="editorName" value="Marjam Trautmann" />
            <param name="editorEmail" value="Marjam.Trautmann@adwmainz.de" />
            <param name="file" value="orte.xml" />
            <param name="date" value="{current-date()}" />
            <param name="description" value="Alphabetisches Register aller Orte mit zugehörigen Folios und Dateien" />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

    let $filename := 'orte.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>
};

declare function sturm_xml:Works($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := collection(concat($appRoot, $appName, $source))
    let $targetDir := concat($appRoot, $appName, $target)
    let $references := doc(concat($appRoot, $appName, '/xml/register/referenzen.xml'))

    let $worksInDocuments := 
        for $doc in $sourceDir//tei:TEI
            let $works := 
                for $key in distinct-values($doc//tei:term/@key)
                return <work key="{$key}" folio="{$doc//tei:correspDesc/@key}" file="{$doc//tei:publicationStmt/tei:idno[@type = 'file']}" />
        return <worksInDocuments>{$works}</worksInDocuments>

    let $worksAndFolios :=
        for $key in distinct-values($worksInDocuments//work/@key)
            let $item := $references//tei:list[@n = 'terms']/tei:item[@xml:id = $key]
            let $source := $references//tei:list[@n = 'terms']/tei:item[@xml:id = $key]/@source
            let $foliosAndIdnos :=
                for $work in $worksInDocuments//work[@key = $key]
                return <ptr xmlns="http://www.tei-c.org/ns/1.0" n="{$work/@folio}" target="{$work/@file}"/>
        return  if (exists($source)) then
            <item xmlns="http://www.tei-c.org/ns/1.0" source="{$source}" n="{$item/@n}" xml:id="{$key}">{$item/*}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></item>
        else 
            <item xmlns="http://www.tei-c.org/ns/1.0" n="{$item/@n}" xml:id="{$key}">{$item/*}<linkGrp type="files">{$foliosAndIdnos}</linkGrp></item>

    (: group by and order by cannot handle separate values within one FLOWR, therefore we need two :)

    let $alphabeticList :=
        for $work in $worksAndFolios
            let $prefName := lower-case(replace($work//tei:name[@type = 'pref']/text(), ' ', ''))
        order by $prefName
        return $work

    let $groupedAphabeticList :=
        for $work in $alphabeticList
            let $firstLetter := upper-case(substring($work//tei:name[@type = 'pref']/text(), 1, 1))
        group by $firstLetter
        return <list n="works" xmlns="http://www.tei-c.org/ns/1.0"><head>{upper-case($firstLetter)}</head>{$work}</list>

    let $registerContent := $groupedAphabeticList

    let $transformationParameters := 
        <parameters>
            <param name="title" value="Werkregister" />
            <param name="editorName" value="Marjam Trautmann" />
            <param name="editorEmail" value="Marjam.Trautmann@adwmainz.de" />
            <param name="file" value="werke.xml" />
            <param name="date" value="{current-date()}" />
            <param name="description" value="Alphabetisches Register aller Werke, Zeitungen, Journale und Bücher mit zugehörigen Folios und Dateien" />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($registerContent, $xsl, $transformationParameters)

    let $filename := 'werke.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>
};

declare function sturm_xml:Cmif($appRoot as xs:string, $appName as xs:string, $source as xs:string, $target as xs:string) {

    let $sourceDir := concat($appRoot, $appName, $source)
    let $targetDir := concat($appRoot, $appName, $target)

    let $letters := 
        for $correspDesc in collection($sourceDir)//tei:correspDesc
        return $correspDesc

    let $transformationParameters := 
        <parameters>
            <param name="type" value="cmif" />
            <param name="title" value="DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde. Abteilung I, Künstlerbriefe" />
            <param name="editorName" value="Torsten Schrade" />
            <param name="editorEmail" value="Torsten.Schrade@adwmainz.de" />
            <param name="url" value="https://sturm-edition.de/cmif/corresp.xml" />
            <param name="date" value="{current-date()}" />
            <param name="bibl" value="DER STURM. Digitale Quellenedition zur Geschichte der internationalen Avantgarde, erarbeitet und herausgegeben von Marjam Trautmann und Torsten Schrade. Akademie der Wissenschaften und der Literatur | Mainz, 2018." />
        </parameters>

    let $xsl := doc(concat($appRoot, $appName, '/xslt/tei.xsl'))
    let $xml := transform:transform($letters, $xsl, $transformationParameters)

    let $filename := 'corresp.xml'
    let $storeToDB := xmldb:store($targetDir, $filename, serialize($xml))

    return <processed timestamp="{current-dateTime()}">{$filename}</processed>

};
