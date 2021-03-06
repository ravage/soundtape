/**
* @name        SoundTape Google Maps Helper Classes
* @description Provide abstraction to Google Maps Geocoding and other functionality
* @author      Rui Miguel <ravage@fragmentized.net>
* @required    MooTools (http://mootools.net/)
* @web         http://www.fragmentized.net
*/

/**
* A wrapper around Google Maps geocoding capabilities.
* It allows easy integration of geocoding and reverse geocoding.
* There is some marker functionality and event attachment.
*/
var GoogleMapsHelper = new Class({
	Implements: [Events, Options],
	
	options: {
		draggable: false,
		icon: false
	},
	
	/**
	* @constructor
	* @param {String} mapHolder ID of the div containing the map
	*/
	initialize: function(mapHolder, options){
		this.setOptions(options);
		
		this.mapHolder = $(mapHolder);
		this.markers = new Array();
		
		//get map holder
		this.map = new GMap2(this.mapHolder);
		
		//initialize the geocoder
		this.geocoder = new GClientGeocoder();
		
		//give the map an initiali point
		this.map.setCenter(this.getCurrentLocation(), 8);
		
		this.markerManager = new GMarkerManager(this.map);
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
	geocode: function(address, icon) {
		//get all possible locations (will only care for one) and send result to addressToMap function
		this.geocoder.getLocations(address, function(response) {this.addressToMap(response, icon);}.bind(this));
	},

	/**
	* Function executes when this.geocoder gets called.
	* Clears the map overlay and checks the response state. If response is good add a Marker on the map
	* and trigger the event onMapInfo
	*
	* @param {Response} The response obtained from the GeoCoder
	*/
	addressToMap: function(response, icon) {
		//clear the map overlays
		this.map.clearOverlays();
		//check for a valid response
		if (!response || response.Status.code != 200) {
			alert("Sorry, we were unable to geocode that address");
			this.fireEvent('onGeocodeFail');
		} else {
			var place = response.Placemark[0];
			var marker = this.addMarker(this.getLatLngFromPoint(place.Point), icon);
			this.addClickEvent(marker, this.getPlaceMarkAddress(place));
			marker.openInfoWindowHtml(this.getPlaceMarkAddress(place));
			this.fireEvent('onMapInfo', [place, marker]);
		}
	},
	
	/**
	* Add a marker on the map
	*
	* @param {GLatLng} An object representing latitude and longitude
	* @param {Options} Options for the Google GMarker Class. Defaults to {draggable: false}
	* @returns The created marker instance
	* @type GMarker
	*/
	addMarker: function(point, icon) {
		var markerOptions = {draggable: this.options.draggable, icon: icon};
		var marker = new GMarker(point, markerOptions);
		//this.map.addOverlay(marker);
		this.markerManager.addMarker(marker, 8, 17);
		this.map.setCenter(point, 8);
		if(marker.draggable())
			this.addDragEvents(marker);
		this.markerManager.refresh();
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
			this.fireEvent('onGeocodeFail');
		} else {
			place = response.Placemark[2];
			this.addClickEvent(marker, this.getPlaceMarkAddress(place));
			marker.openInfoWindowHtml(this.getPlaceMarkAddress(place));
			this.fireEvent('onMapInfo', [place, marker]);
		}
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

/**
* A simple wrapper to glue together a Map and a Form.
* It expects a form with:
* 	search 		-> button
* 	location 	-> text
*	latitude 	-> text
* 	longitude	-> text
*	spinner		-> class
* 
* All the above parameters are configurable but if not given it will try to attach the defauls.
* 
* To ease on the map display of data it includes a getJSON to fetch data from a source and display it in the map.
* The return from the JSON request expects at least:
* 	latitude
* 	longitude
* 	location
*
* It relies in the Formatter to output proper html. The Formatter can be extended easily.
*/
var MapFormWrapper = new Class({
	Implements: Options,
	
	options: {
		search: 	null,
		location: 	null,
		latitude: 	null,
		longitude: 	null,
		spinner: 	null
	},
	
	/**
	* @param {String} bindForm Form to which we should attach
	* @param {String} mapWrapper div that will hold the map
	* @param {JSON} options Override the default form fields 
	* @constructor
	*/
	initialize: function(bindForm, mapWrapper,  options) {
		this.setOptions(options);
		this.bindForm = $(bindForm);
		this.mapHelper = new GoogleMapsHelper(mapWrapper, {draggable : true});
		this.bindFields();
		this.addEvents();
	},
	
	/**
	* Get the default field names or override with the given ones
	*/
	bindFields: function() {
		this.options.search 	= this.options.search || this.bindForm.getElement('input[name=search]');
		this.options.location 	= this.options.location || this.bindForm.getElement('input[name=location]');
		this.options.latitude 	= this.options.latitude || this.bindForm.getElement('input[name=latitude]');
		this.options.longitude 	= this.options.longitude || this.bindForm.getElement('input[name=longitude]');
		this.options.spinner	= this.options.spinner || 'spinner';
	},
	
	/**
	* Attach events for geocoding search
	*/
	addEvents: function() {
		this.mapHelper.addEvent('onMapInfo', this.onMapInfo.bind(this));
		this.mapHelper.addEvent('onGeocodeFail', this.onGeocodeFail.bind(this));
		this.options.search.addEvent('click', this.onSearch.bind(this));	
	},
	
	/**
	* Triggers when information from the map becomes available
	* 
	* @param {Placemark} info Information about a place. An element of Placemark
	* @param {GMarker} marker A marker at the position found by geocoding or where it got dropped
	*/
	onMapInfo: function(info, marker) {
		this.hideSpinner(this.options.search);
		this.options.location.value = info.address;
		this.options.latitude.value = marker.getLatLng().lat();
		this.options.longitude.value = marker.getLatLng().lng();
	},
	
	/**
	* Triggers when geocoding fails
	*/
	onGeocodeFail: function() {
		this.hideSpinner(this.options.search);
	},
	
	/**
	* Triggers when the search button gets clicked
	* 
	* @param {Event} Event object from the sender
	*/	
	onSearch: function(event) {
		event.stop();
		this.mapHelper.geocode(this.options.location.value);
		this.showSpinner(event.target);
	},
	
	/**
	* Just show the spinner so we know something is happening
	* 
	* @param {Element} Element that triggered the onSearch event.
	*/
	showSpinner: function(el) {
		el.addClass(this.options.spinner);
	},
	
	/**
	* Just hide the spinner after the work is done
	* 
	* @param {Element} An Element representing the search button
	*/
	hideSpinner: function(el) {
		el.removeClass(this.options.spinner);
	},
	
	/**
	* Provide a way to get information from a source and dump it directly in the map.
	*  
	* It expects the returned info to contain at least:
	* 	latitude
	* 	longitude
	* 	location
	* 
	* If there are any coordinates a marker will be added to the map, showing a popup
	* containing information returned by the Formatter.
	*
	* @param {String} url_ The url to where the request should be made.
	*/
	getJSON: function(url_) {
		var req = new Request.JSON({url: url_,
			onSuccess: function(info) {
				var latitude = null;
				var longitude = null;
				if(this.options.latitude.value && this.options.longitude.value) {
					latitude = this.options.latitude.value;
					longitude = this.options.longitude.value;
				}
				else if (info.latitude && info.longitude) {
					latitude = info.latitude;
					longitude = info.longitude;
				}
				if(longitude && latitude) {
					var marker = this.mapHelper.addMarker(this.mapHelper.getPoint(latitude, longitude));
					var html = Formatter.get(info);
					this.mapHelper.addClickEvent(marker, html);
					marker.openInfoWindowHtml(html);
				}
				else {
					this.mapHelper.geocode(info.location);
				}
			}.bind(this)
		}).get();
	}
});

/**
* Utility class to fill a map with the location of a user or events.
* Allows asynchronous calls to grab information abou locations, with the information,
* it draws the markers and links them with a click event to a element on the page
* FIXME: Event and Profile link could collide if they have same id
* FIXME: Maybe a little coupled with the task in hand. Could be more generic?
*/
var FillMap = new Class({
	Implements: Options,
	
	options: {

	},
	
	/**
	* @param {String} mapWrapper div that will hold the map
	* @param {JSON} options options Currently not used
	* @constructor
	*/
	initialize: function(mapWrapper, options) {
		this.setOptions(options);
		this.mapHelper = new GoogleMapsHelper(mapWrapper);
		
		this.icons = new Array();

		var profileIcon = new GIcon();
		profileIcon.image = '/imgs/gmap_icon_profile.png';
		profileIcon.iconAnchor = new GPoint(18, 37);
		profileIcon.infoWindowAnchor = new GPoint(18, 15);

		var eventIcon = new GIcon();
		eventIcon.image = '/imgs/gmap_icon_event.png';
		eventIcon.iconAnchor = new GPoint(18, 37);
		eventIcon.infoWindowAnchor = new GPoint(18, 15);

		this.icons['profile'] = profileIcon;
		this.icons['event'] = eventIcon;
		
	},
	
	/**
	* Make an asynchronous call expecting to grab location info.
	* 
	* @param {String} uri URI to where the request should be made
	*/
	mapProfile: function(uri) {
		var req = new Request.JSON({url: uri,
			onSuccess: function(profile) {
				if(profile.latitude && profile.longitude) {
					this.setMarkerAtLatLng(profile, this.icons['profile']);
				} else if(profile.location) {
					this.setMarkerAtGeocode(profile, this.icons['profile']);
				}
			}.bind(this)
		}).get();		
	},
	
	/**
	* Set a marker at a given latitude and longitude.
	*
	* The object passed to the function should contain latitude and longitude atributes.
	* 
	* @param {Object} info The object containing the latitude and longitude.
	*/
	setMarkerAtLatLng: function(info, icon) {
		var marker = this.mapHelper.addMarker(this.mapHelper.getPoint(info.latitude, info.longitude), icon);
		this.mapHelper.addClickEvent(marker, Formatter.get(info));
		this.linkMarker(marker, info);
	},
	
	/**
	* Uses geocoding to set a marker at a given address.
	*
	* The object passed to the function should contain a location attribute.
	* 
	* @param {Object} info The object containing the address to geocode.
	*/
	setMarkerAtGeocode: function(info, icon) {
		this.mapHelper.addEvent('onMapInfo', function(_info, marker){
			GEvent.clearListeners(marker);
			this.mapHelper.addClickEvent(marker, Formatter.get(info));
			this.linkMarker(marker, info);
			marker.closeInfoWindow();
		}.bind(this));
		this.mapHelper.geocode(info.location, icon);
	},

	/**
	* Make an asynchronous call expecting to grab location info.
	*
	* The function handles a single object or an array of objects.
	* 
	* @param {String} uri URI to where the request should be made.
	*/
	mapEvents: function(uri) {
		var req = new Request.JSON({url: uri,
			onSuccess: function(events) {
				if(events instanceof Array) {
					events.each(function(el){
						if(el.latitude && el.longitude) {
							this.setMarkerAtLatLng(el, this.icons['event']);
						} else if(el.location) {
							this.setMarkerAtGeocode(el, this.icons['event']);
						}

					}.bind(this));
				}
				else {
					if(events.latitude && events.longitude) {
						this.setMarkerAtLatLng(events, this.icons['event']);
					} else if(events.location) {
						this.setMarkerAtGeocode(events, this.icons['event']);
					}
				}
			}.bind(this)
		}).get();
	},
	
	/**
	* Helper function to attach a click event to a HTML element.
	* The element will be attached by a given id.
	* 
	* @param {GMarker} marker The marker to which the element will be linked.
	* @param {Object} info An object with an identifier to link with the HTML element.
	*/
	linkMarker: function(marker, info) {
		var link = $('link_' + info.id);
		if(link) {
			$('link_' + info.id).addEvent('click', function(e) {
				e.stop();
				this.mapHelper.map.setCenter(marker.getLatLng());
				marker.openInfoWindowHtml(Formatter.get(info));
			}.bind(this));
		}
	}
});

/**
* Helper class to handle a URI. Extracts domain and params from a given URI.
* 
* Example:
* <script type="text/javascript" src="/path/to/javascript.js?user=5&action=go"></script>
*/
var ParseUri = new Class();

/**
* Grabs the domain part of a given URI.
*
* @param {String} uri The uri from where to get the domain.
* @return A String containing the domain or domain:port
*/
ParseUri.getDomain = function(uri) {
	var uri = new URI(uri);
	return uri.get('port') ? uri.get('host') + ':' + uri.get('port') : uri.get('host');
};

/**
* Grabs the parameters from a given URI.
*
* @param {String} uri The uri from where to get the params.
* @return An object containing the params parsed.
*/
ParseUri.getParams = function(uri) {
	var params = uri.replace(/^[^\?]+\??/,'').parseQueryString();
	return params;
};

/**
* Just provides formatters with HTML content for a Google Maps Marker PopUp or whatever
*/
var Formatter = new Class();

/**
* Format for an /settings/event/#.json
*
* @return A HTML element
* @type Element
*/
Formatter.getEventMarkerPopUp = function(info) {
	var div = new Element('div');
	var name = new Element('p', {'text' : info.name});
	var description = new Element('p', {'text' : info.description});
	var location = new Element('p', {'text' : info.local});
	var when = new Element('p', {'text' : info.when});
	var price = new Element('p', {'text' : info.price});
	var flyer = new Element('img', {'src' : info.thumb, 'style' : 'float: left; border: 1px solid red;'});
	div.adopt(flyer, name, location, when, price);
	return div;
};

/**
* Format for a settings/location.json
*
* @return A HTML element
* @type Element
*/	
Formatter.getLocationMarkerPopUp = function(info) {
	var div = new Element('div');
	var photo = new Element('img', {'src' : info.photo, 'style' : 'float: left; border: 1px solid red;'});
	var name = new Element('p', {'text' : info.name});
	var link = new Element('a', {'href' : info.profile, 'text' : info.profile});
	var homepage = new Element('a', {'href' : info.homepage, 'text' : info.homepage});
	var location = new Element('p', {'text' : info.location});
	div.adopt(photo, name, homepage, location, link);
	return div;
};

/**
* Just decide which format to pass
*
* @param {JSON} info An object with the information to be formatted
*/
Formatter.get = function(info) {
	if(info.json_class == 'Event')
		return Formatter.getEventMarkerPopUp(info);
	else if(info.json_class == 'Profile')
		return Formatter.getLocationMarkerPopUp(info);
};