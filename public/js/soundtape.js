var GoogleMapsHelper = new Class({
	Implements: Events,
	
	/**
	* @constructor
	* @param {String} mapHolder ID of the div containing the map
	*/
	initialize: function(mapHolder){
		this.mapHolder = $(mapHolder);
		this.markers = new Array();
		
		//get map holder
		this.map = new GMap2(this.mapHolder);

		//initialize the geocoder
		this.geocoder = new GClientGeocoder();
		
		//give the map an initiali point
		this.map.setCenter(this.getCurrentLocation(), 8);
	},
	

	/**
	* Find a location from the current IP or set a default one
	* @returns A GLatLng object
	*/
	getCurrentLocation: function() {
		if(google.loader.ClientLocation) {
			var pos = new GLatLng(google.loader.ClientLocation.latitude, google.loader.ClientLocation.longitude);
		}
		else {
			return new GLatLng(41.434490, -8.300171);
		}
		return pos;
	},
	
	//geocode from an address
	//@address: a string to search as an address
	/**
	* Geocode from an address
	* @param {String} address A string representing an address
	*/
	geocode: function(address) {
		//get all possible locations (will only care for one) and send result to addressToMap function
		this.geocoder.getLocations(address, this.addressToMap.bind(this));
	},

	/**
	* Function executes when this.geocoder gets called.
	* Clears the map overlay and checks the response state. If response is good add a Marker on the map
	* and trigger the event onMapInfo
	*
	* @param {Response} The response obtained from the GeoCoder
	*/
	addressToMap: function(response) {
		//clear the map overlays
		this.map.clearOverlays();
		//check for a valid response
		if (!response || response.Status.code != 200) {
			alert("Sorry, we were unable to geocode that address");
		} else {
			var place = response.Placemark[0];
			var marker = this.addMarker(this.getLatLngFromPoint(place.Point), {draggable: true});
			this.addClickEvent(marker, this.getPlaceMarkAddress(place));
			marker.openInfoWindowHtml(this.getPlaceMarkAddress(place));
			this.fireEvent('onMapInfo', [place, marker]);
		}
		this.fireEvent('infoComplete', marker);
	},
	
	/**
	* Add a marker on the map
	*
	* @param {GLatLng} An object representing latitude and longitude
	* @param {Options} Options for the Google GMarker Class. Defaults to {draggable: false}
	* @returns The created marker instance
	* @type GMarker
	*/
	addMarker: function(point, options) {
		options = options || {draggable: false};
		
		var marker = new GMarker(point, options);
		this.map.addOverlay(marker);
		this.map.setCenter(point, 8);
		if(marker.draggable())
			this.addDragEvents(marker);
		return marker;
	},
	
	/**
	* Add and register Drag Events for a GMarker
	* @param {GMarker} The marker instance to attache the events
	*/
	addDragEvents: function(marker) {
		GEvent.addListener(marker, "dragstart", function() { 
			this.dragStart(marker); 
		}.bind(this));
		
		GEvent.addListener(marker, "dragend", function() { 
			this.dragEnd(marker); 
		}.bind(this));
	},
	
	/**
	* Callback for when the marker starts being dragged
	* @param {GMarker} The marker
	*/
	dragStart: function(marker) {
		marker.closeInfoWindow();
	},
	
	/**
	* Callback for when the marker gets dropped
	* @param {GMarker} The marker
	*/
	dragEnd: function(marker) {
		this.geocoder.getLocations(marker.getLatLng(), function(response) {
			this.addressFromMap(response, marker);
		}.bind(this));
	},
	
	/**
	* Create a GLatLng object from the respective latitude and longitude
	* @param {Placemark} Containing latitude and longitude coordinates
	* @return A GLatLng object
	* @type GLatLng
	*/
	getLatLngFromPoint: function(point) {
		return new GLatLng(point.coordinates[1], point.coordinates[0]);
	},
	

	/**
	* Reverse geocode from coordinates to address. If the response is successfull the event
	* onMapInfo gets triggered.
	*
	* @param {Response} The response obtained from the GeoCoder
	* @param {GMarker} The marker that generated the event
	*/
	addressFromMap: function(response, marker) {
		if (!response || response.Status.code != 200) {
			marker.openInfoWindowHtml("Sorry, we were unable to geocode that address");
		} else {
			place = response.Placemark[2];
			this.addClickEvent(marker, this.getPlaceMarkAddress(place));
			marker.openInfoWindowHtml(this.getPlaceMarkAddress(place));
			this.fireEvent('onMapInfo', [place, marker]);
		}
		this.fireEvent('infoComplete', marker);
	},
	
	addClickEvent: function(marker, info) {
		GEvent.addListener(marker, "click", function() {
			marker.openInfoWindowHtml(info);
		});
	},
	
	/**
	* Get the placemark address from a Placemark object
	* @param {Placemark} An object representing a placemark
	* @return The placemark address
	* @type String
	*/
	getPlaceMarkAddress: function(placemark) {
		return placemark.address;
	},
	
	/**
	* Create a GLatLng object from the respective latitude and longitude
	* @param {Float} lat The latitude
	* @param {Float} lng The longitude
	* @return A GLatLng object
	* @type GLatLng
	*/
	getPoint: function(lat, lng) {
		return new GLatLng(lat, lng);
	}

});