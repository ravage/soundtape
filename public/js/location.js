google.load('maps' , '2');

function initialize() {
	var mfw = new MapFormWrapper('geocode', 'map_wrapper');
	mfw.getJSON(location.href + '.json');
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});