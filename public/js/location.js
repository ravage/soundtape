google.load('maps' , '2');

function initialize() {
	var gmaps = new GoogleMapsHelper('map_wrapper');
	
	gmaps.addEvent('onMapInfo', onMapInfo);
	gmaps.addEvent('infoComplete', infoComplete);
	
	$('geocode').getElement('input[name=search]').addEvent('click', onSearch);

	var req = new Request.JSON({url: location.href + '.json',
		onSuccess: function(info) {
			if(info.latitude && info.longitude) {
				var marker = gmaps.addMarker(gmaps.getPoint(info.latitude, info.longitude), {draggable : true});
				var div = new Element('div');
				var photo = new Element('img', {'src' : info.photo, 'style' : 'float: left; border: 1px solid red;'});
				var name = new Element('p', {'text' : info.name});
				var link = new Element('a', {'href' : info.profile, 'text' : info.profile});
				var homepage = new Element('a', {'href' : info.homepage, 'text' : info.homepage});
				var location = new Element('p', {'text' : info.location});
				div.adopt(photo, name, homepage, location, link);
				gmaps.addClickEvent(marker, div);
				marker.openInfoWindowHtml(div);
			}
			else {
				gmaps.geocode(info.location);
			}
		}
	}).get();
	
	function onMapInfo(info, marker) {
		var element = $('geocode');
		element.getElement('input[name=location]').value = info.address;
		element.getElement('input[name=latitude]').value = marker.getLatLng().lat();
		element.getElement('input[name=longitude]').value = marker.getLatLng().lng();
	}
		
	function onSearch(event) {
		event.stop();
		gmaps.geocode($('geocode').getElement('input[name=location]').value);
		showSpinner(this);
	}
	
	function infoComplete(marker) {
		hideSpinner($('geocode').getElement('input[name=search]'));
		$('geocode').getElement('input[name=latitude]').value = marker.getLatLng().lat();
		$('geocode').getElement('input[name=longitude]').value = marker.getLatLng().lng();
	}
	
	function showSpinner(el) {
		el.addClass('spinner');
	}
	
	function hideSpinner(el) {
		el.removeClass('spinner');	
	}
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});