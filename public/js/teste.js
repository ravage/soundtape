google.load('maps' , '2');

function initialize() {
	var g = new GoogleMapsHelper('map_wrapper'); 
	var overlay = $('overlay');
	$('toggle').addEvent('click', function(e){
		e.stop();
		if(overlay.getHeight() <= 30) {
			overlay.morph({height: 300});
		}
		else {
			overlay.morph({height: 20});
		}
	});
	
	var fillMap = new FillMap('map_wrapper');
	fillMap.mapEvents('http://' + ParseUri.getDomain(location.href) + '/api/get_events/' + ParseUri.getParams($('profile_js').src).user + '.json');
	fillMap.mapProfile('http://' + ParseUri.getDomain(location.href) + '/api/get_user/' + ParseUri.getParams($('profile_js').src).user + '.json');
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});