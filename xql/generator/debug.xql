xquery version "3.0";

(:~
 : Der STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada, Thomas Kollatz and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : The main query of the STURM website generator.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @version 1.0.0 
 : @licence MIT
:)

import module namespace sturm_xml = 'https://sturm-edition.de/sturm_xml' at 'xml.xqm';
import module namespace sturm_json = 'https://sturm-edition.de/sturm_json' at 'json.xqm';
import module namespace sturm_html = 'https://sturm-edition.de/sturm_html' at 'html.xqm';
import module namespace sturm_txt = 'https://sturm-edition.de/sturm_txt' at 'txt.xqm';


declare variable $appRoot := '/db/apps/';
declare variable $appName := 'sturm-edition';

(:
let $xmlFiles := (
    sturm_xml:Cmif($appRoot, $appName, '/xml/quellen/01.briefe/', '/html/cmif/')
)
:)

let $htmlFiles := (
    sturm_html:Versions($appRoot, $appName, '/xml/versionen/01.briefe/', '/html/quellen/briefe/')
)

return <files>{$htmlFiles}</files>
