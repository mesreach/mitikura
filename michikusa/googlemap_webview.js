function initMap() {
    var map;
    var infoWindow;
    var defaultLat = 35.658581;
    var defaultLng = 139.745433;
    var options = {
        center: { lat: defaultLat, lng: defaultLng },
        zoom: 14
    }
    var pos;
    map = new google.maps.Map(document.getElementById('map'), options);
    infoWindow = new google.maps.InfoWindow({map: map});
    
    /*
    if(navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position){
            pos = {
                lat: position.coords.latitude,
                lng: position.coords.longitude
            };
            infoWindow.setPosition(pos);
            infoWindow.setContent("Locaton Found");
            //map.setCenter(pos);
        }, function(){
            handleLocationError(true, infoWindow, map.getCenter());
        });
    } else {
        handleLocationError(false, infoWindow, map.getCenter());
    }
    */

    var DS = new google.maps.DirectionsService();
    var DR = new google.maps.DirectionsRenderer();
    var latlng1 = new google.maps.LatLng(defaultLat, defaultLng);
    var latlng2 = new google.maps.LatLng(35.705469, 139.649610);

    var request = {
        origin: latlng1, 
        destination: latlng2, 
        travelMode: google.maps.DirectionsTravelMode.DRIVING
    };

    DS.route(request, function(result, status) {
        DR.setDirections(result); 
        DR.setMap(map); 
    });
}

function handleLocationError(browserHasGeolocation, infoWindow, pos) {
    infoWindow.setPosition(pos);
    infoWindow.setContent(browserHasGeolocation ?
                          'Error: The Geolocation service failed.' :
                          'Error: Your browser doesn\'t support geolocation.');
}
