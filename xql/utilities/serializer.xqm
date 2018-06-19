xquery version "3.0";

(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : HTML and JSON serialization functions 
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)

module namespace sturm_serialize = "https://sturm-edition.de/sturm_serialize";

import module namespace functx = "http://www.functx.com";

declare function sturm_serialize:Html($html) as xs:string {

    let $serializationParameters := 
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">; 
            <output:omit-xml-declaration value="yes"/> 
            <output:method value="html5"/> 
            <output:media-type value="text/html"/> 
            <output:encoding value="utf-8"/> 
            <output:indent value="yes"/> 
        </output:serialization-parameters> 

    let $serializedHtml5 := functx:trim(serialize($html, $serializationParameters))

    let $from := ('(&lt;meta)(.*?)(&gt;)', '(&lt;link)(.*?)(&gt;)', '(&lt;img)(.*?)(&gt;)', '&lt;br&gt;')
    let $to :=  ('&lt;meta$2/&gt;', '&lt;link$2/&gt;', '&lt;img$2/&gt;', '&lt;br/&gt;')
    let $finalHtml := functx:replace-multi($serializedHtml5, $from, $to)

    return $finalHtml
};

declare function sturm_serialize:Json($xml) as xs:string {

    let $serializationParameters := 
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">; 
            <output:omit-xml-declaration value="yes"/> 
            <output:method value="json"/> 
            <output:media-type value="text/javascript"/> 
            <output:encoding value="utf-8"/> 
            <output:indent value="yes"/> 
        </output:serialization-parameters> 

    let $serializedJson := functx:trim(serialize($xml, $serializationParameters))

    let $finalJson := $serializedJson

    return $finalJson
};

declare function sturm_serialize:Txt($txt) as xs:string {

    let $serializationParameters := 
        <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">; 
            <output:omit-xml-declaration value="yes"/> 
            <output:method value="txt"/> 
            <output:media-type value="text"/> 
            <output:encoding value="utf-8"/> 
            <output:indent value="yes"/> 
        </output:serialization-parameters> 

    let $serializedTxt := functx:trim(serialize(string-join($txt), $serializationParameters))

    let $from := ('&lt;', '&gt;')
    let $to :=  ('<', '>')
    let $finalTxt := functx:replace-multi($serializedTxt, $from, $to)

    return $serializedTxt
};