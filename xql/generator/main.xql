xquery version "3.0";

(:
 : DER STURM
 : A Digital Edition of Sources from the International Avantgarde
 :
 : Edited and developed by Marjam Mahmoodzada and Torsten Schrade
 : Academy of Sciences and Literature | Mainz
 :
 : The main query of the STURM website generator.
 :
 : @author Torsten Schrade
 : @email <Torsten.Schrade@adwmainz.de>
 : @licence MIT
:)

import module namespace sturm_xml = 'https://sturm-edition.de/sturm_xml' at 'xml.xqm';
import module namespace sturm_json = 'https://sturm-edition.de/sturm_json' at 'json.xqm';
import module namespace sturm_html = 'https://sturm-edition.de/sturm_html' at 'html.xqm';
import module namespace sturm_txt = 'https://sturm-edition.de/sturm_txt' at 'txt.xqm';

declare variable $appRoot := '/db/apps/';
declare variable $appName := 'sturm-edition';

let $xmlFiles := (
    sturm_xml:Sources($appRoot, $appName, '/xml/quellen/', '/xml/register/'),
    sturm_xml:Letters($appRoot, $appName, '/xml/quellen/01.briefe/', '/xml/register/'),
    sturm_xml:Persons($appRoot, $appName, '/xml/quellen/01.briefe/', '/xml/register/'),
    sturm_xml:Places($appRoot, $appName, '/xml/quellen/01.briefe/', '/xml/register/'),
    sturm_xml:Works($appRoot, $appName, '/xml/quellen/01.briefe/', '/xml/register/'),
    sturm_xml:Cmif($appRoot, $appName, '/xml/quellen/01.briefe/', '/html/cmif/')
)

let $jsonFiles := (
    sturm_json:Registers($appRoot, $appName, '/xml/register/', '/json/')
)

let $txtFiles := (
    sturm_txt:Beacon($appRoot, $appName, '/xml/register/', '/html/beacon/')
)

let $htmlFiles := (
    sturm_html:Pages($appRoot, $appName, '/xml/seiten/', '/html/'),
    sturm_html:Letters($appRoot, $appName, '/xml/quellen/01.briefe/', '/html/quellen/briefe/'),
    sturm_html:Letters($appRoot, $appName, '/xml/versionen/quellen/01.briefe/', '/html/quellen/briefe/'),
    sturm_html:Registers($appRoot, $appName, '/xml/register/', '/html/register/'),
    sturm_html:Sources($appRoot, $appName, '/xml/vorlagen/briefe.xml', '/html/quellen/briefe/'),
    sturm_html:Persons($appRoot, $appName, '/xml/register/personen.xml', '/html/register/personen/'),
    sturm_html:Places($appRoot, $appName, '/xml/register/orte.xml', '/html/register/orte/'),
    sturm_html:Works($appRoot, $appName, '/xml/register/werke.xml', '/html/register/werke/')
)

let $storeFileIndexToDB := xmldb:store(concat($appRoot, $appName, '/temp/'), 'processed.xml', serialize(<files>{$htmlFiles}</files>))

return <files>{$xmlFiles, $jsonFiles, $txtFiles, $htmlFiles}</files>
