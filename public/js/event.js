google.load('maps' , '2');

function initialize() {
	var fillMap = new FillMap('map_wrapper');
	fillMap.mapEvents('http://' + ParseUri.getDomain(location.href) + '/api/get_event/' + ParseUri.getParams($('event_js').src).event + '.json');
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});