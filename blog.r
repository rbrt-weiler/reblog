#!/usr/bin/rebol -cs



REBOL [
	Title:    "REBlog"
	Date:     16-Aug-2003
	File:     %blog.r
	Version:  0.1.1
	Language: 'German

	Author:   "Robert Weiler"
	Owner:    "Robert Weiler"
	Rights:   "Copyright (C) 2003 Robert Weiler"
	License:  "GPL <http://www.gnu.org/licenses/gpl.html>"
	Home:     http://www.robwei.de/files/rebol/

	Purpose:  {
		REBlog somehow is a rewrite of the blogging software Bloxsom in
		REBOL. It can be used for simple content management.
	}

	Note:     {
		Currently REBlog is in Alpha stadium. Don't use it unless you
		know exactly what you're doing, it is not guaranteed that
		REBlog works as expected.
	}

	History:  [
		0.0.1 [
			16-Aug-2003 { Created the script, providing virtually no
			functionality. } "Robert Weiler"
		]
		0.1.0 [
			19-Aug-2003 { Added functionality. REBlog is now able to
			display the 15 most current posts. } "Robert Weiler"
		]
		0.1.1 [
			24-Aug-2003 { REBlog now works without an authors file. }
			"Robert Weiler"
		]
	]
]



; Schreibbarer Pfad um Konfiguration / Einträge / Kommentare abzuspeichern
data-dir: %"/path/to/data/"

; Automatische Konfiguration weiterer Dateien / Pfade
authors-file: join data-dir [ "authors" ]
meta-file: join data-dir [ "metadata" ]
post-dir: join data-dir [ "posts/" ]

; Sonstige Variablen
page-generator: join system/script/title [ "/" system/script/header/Version ]



; Funktion um aus einem REBOL-Datum etwas zu erstellen das man richtig sortieren kann
iso-date: func [
	reb-date [ date! ] "Das aktuelle Datum im REBOL-Format."
] [
	reb-time: reb-date/time
	year: to-string reb-date/year
	month: to-string reb-date/month
	day: to-string reb-date/day
	hour: to-string reb-time/hour
	minute: to-string reb-time/minute
	seconds: to-string reb-time/second

	if (length? month) < 2 [ insert month "0" ]
	if (length? day) < 2 [ insert day "0" ]
	if (length? hour) < 2 [ insert hour "0" ]
	if (length? minute) < 2 [ insert minute "0" ]
	if (length? seconds) < 2 [ insert seconds "0" ]

	fulldate: join year [ "-" month "-" day "T" hour ":" minute ":" seconds ]

	make object! compose [
		fulldate: (fulldate)
		year: (year)
		month: (month)
		day: (day)
		hour: (hour)
		minute: (minute)
		second: (seconds)
	]
]



; Funktion zum absteigendem sortieren
sort-descending: func [	a b ] [ a > b ]



; HTTP-Header - jetzt schon ausgeben wegen möglichen Fehlermeldungen
print "Content-Type: text/html; charset=ISO-8859-15"
print "Expires: 0"
print join "X-Powered-By: " [ page-generator " REBOL/" system/version ]
print ""



; Authors-Datei einlesen und parsen
either (exists? authors-file) [
	authors: make block! 50
	lines: read/lines authors-file

	foreach [ line ] lines [
		author: parse/all line {"}
		data: array 2
		data/1: author/1
		data/2: author
		append authors data
	]

	unset [ lines line author data ]
] [
	authors: make block! 1
]



; post-dir komplett auslesen, Einträge absteigend nach letzter Modifikation sortieren
postings: make block! 500

foreach entry read post-dir [
	file: join post-dir [ entry ]
	info: iso-date (modified? file)
	append postings info/fulldate
	append postings file
]

unset [ file info ]

sort/compare/skip postings :sort-descending 2



; Die maximal 15 aktuellsten Postings anzeigen
if (length? postings) > 30 [
	postings: copy/part postings 30
]

; HTML-Header
print {<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=ISO-8859-15">
		<title>REBlog devBlog</title>
		<meta name="robots" content="index,follow">
	</head>
	<body bgcolor="#ffffff" text="#000000" link="#0000ff" alink="#ff0000" vlink="#990099">
		<h1>REBlog devBlog</h1>
		<hr>}

; Postings durchgehen
foreach [ date file ] postings [
	lines: read/lines file
	count: 0
	entry: make string! 500
	foreach [ line ] lines [
		if (count == 0) [ author: line ]
		if (count == 1) [ title: line ]
		if (count > 1) [ append entry line ]
		count: count + 1
	]

	author-data: select authors author
	if (block? author-data) [
		if [ (not empty? author-data/3) ] [
			author: join {<a href="mailto:} [ author-data/3 {">} author-data/2 "</a>" ]
		]
		if [ (not empty? author-data/4) ] [
			author: join {<a href="} [ author-data/4 {">} author-data/2 "</a>" ]
		]
	]

	datetime: parse/all date "T"
	print join "<h2>" [ title "</h2>" ]
	print join "<p>" [ entry "</p>" ]
	print join "<div>" [ author " | " datetime/1 " | " datetime/2 "</div>" ]
]

unset [ date file lines count line author-data datetime author title entry ]

; HTML-Footer
print "		<hr>"
print join {		<div align="right">powered by } [ page-generator "</div>" ]
print {	</body>
</html>}
