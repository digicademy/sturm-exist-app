'use strict';

$(document).ready(function() {

    $.ajax({
        headers: {
            Accept: "application/json"
        },
        dataType: "json",
        url: 'https://sturm-edition.de/api/v1/places',
        success: function(response) {
            for (let place of response.place) {
                let geo = place.location.geo.split(' ');
                let latitude = parseFloat(geo[0]);
                let longitude = parseFloat(geo[1]);
                let folios = '';
                if (place.linkGrp.ptr != null && typeof place.linkGrp.ptr[Symbol.iterator] === 'function') {
                    for (let ptr of place.linkGrp.ptr) {
                        folios += '<a href="../quellen/briefe/chronologie/'+ ptr['target'].replace('.xml', '.html') +'" style="display:block">'+ ptr['n'] +'</a>'
                    }
                } else {
                    folios += '<a href="../quellen/briefe/chronologie/briefe/'+ place.linkGrp.ptr['target'].replace('.xml', '.html') +'" style="display: block">'+ place.linkGrp.ptr['n'] +'</a>'
                }

console.log(place['placeName']['#text']);

                L.marker([latitude,longitude]).addTo(map).bindPopup('<a href="'+ place['source'] +'" style="display: block; font-size: larger; margin-bottom: 0.3em;">' + place['placeName']['#text'] + '</a>' + folios);
            }
        }
    });

    let map = L.map('map').setView([52.087319,10.4507191], 4);

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors'
    }).addTo(map);

});
