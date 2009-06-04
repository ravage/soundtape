google.load('maps' , '2');

function initialize() {
	var mfw = new MapFormWrapper('geocode', 'map_wrapper');
	
	if(ParseUri.getParams($('location_js').src).grab == 'yes') {
		mfw.getJSON(location.href + '.json');
	}	
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});