google.load('maps' , '2');

function initialize() {
	var g = new GoogleMapsHelper('map_wrapper'); 
	var overlay = $('overlay');
	
	if(overlay) {
		$('toggle').addEvent('click', function(e){
			e.stop();
			if(overlay.getHeight() <= 31) {
				overlay.morph({height: $('overlay_events').getHeight() + 2});
			}
			else {
				overlay.morph({height: 31});
			}
		});
	}
	
	var fillMap = new FillMap('map_wrapper');
	fillMap.mapEvents('http://' + ParseUri.getDomain(location.href) + '/api/get_events/' + ParseUri.getParams($('profile_js').src).user + '.json');
	fillMap.mapProfile('http://' + ParseUri.getDomain(location.href) + '/api/get_user/' + ParseUri.getParams($('profile_js').src).user + '.json');
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});