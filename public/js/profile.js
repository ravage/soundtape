google.load('maps' , '2');

function initialize() {
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
	
	var param = ParseUri.getParams($('profile_js').src).user;
	fillMap.mapEvents('http://' + ParseUri.getDomain(location.href) + '/api/get_events/' + param + '.json');
	fillMap.mapProfile('http://' + ParseUri.getDomain(location.href) + '/api/get_user/' + param + '.json');
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});