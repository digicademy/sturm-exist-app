# DER STURM - Web Application

This software package provides the digital edition environment of the project
<a href="https://sturm-edition.de/">"DER STURM. A Digital Edition of Sources from the International Avantgarde"</a>
of the <a href="http://www.adwmainz.de/">Academy of Sciences and Literature | Mainz</a>.

The package is developed as an encapsulated web application for the <a href="http://exist-db.org/">eXist XML database</a>
and contains everything - the code, the research data and the presentation layer of the digital edition. The eXist
implementation is inspired by current developments in the field of static site generators like 
<a href="https://jekyllrb.com/">Jekyll</a>, <a href="https://gohugo.io/">Hugo</a> and <a href="https://getgrav.org/">Grav</a>.

The following diagramm gives an overview over the software architecture:

![Diagramm of the eXist application](https://sturm-edition.de/images/sturm-exist-app.png "Diagramm of the STURM eXist application")

Further details can be read in the <a href="https://sturm-edition.de/ressourcen/software.html">software documentation</a>.

### Download & Installation

All releases of the software can be downloaded from the <a href="https://github.com/digicademy/sturm-exist-app/releases">release page</a>.

Each release contains a precompiled XAR file that can be conveniently installed
in an eXist instance with the eXist package manager. Once installed the presentation
layer of the digital edition can be found in the _html_ folder of the installation. The
research data is contained in the _xml_ folder, all XQuery and XSLT scripts
are kept in the _xql_ and _xslt_ folders respectively.

### License

The design and the research data of the STURM edition are licensed under the terms 
of the <a href="https://creativecommons.org/licenses/by/4.0/">CC-BY 4.0 license</a>.

The software is published under the terms of the MIT license. 

### Research Software Engineering and Development

Copyright 2018 <a href="https://orcid.org/0000-0002-0953-2818">Torsten Schrade</a>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
