google.load('maps' , '2');

/*
JavaScripts Params trhu src: http://feather.elektrum.org/book/src.html

var scripts = document.getElementsByTagName('script');
var myScript = scripts[ scripts.length - 1 ];

var queryString = myScript.src.replace(/^[^\?]+\??/,'');

var params = parseQuery( queryString );

function parseQuery ( query ) {
   var Params = new Object ();
   if ( ! query ) return Params; // return empty object
   var Pairs = query.split(/[;&]/);
   for ( var i = 0; i < Pairs.length; i++ ) {
      var KeyVal = Pairs[i].split('=');
      if ( ! KeyVal || KeyVal.length != 2 ) continue;
      var key = unescape( KeyVal[0] );
      var val = unescape( KeyVal[1] );
      val = val.replace(/\+/g, ' ');
      Params[key] = val;
   }
   return Params;
}

*/

function initialize() {
	$('event_scroller').addEvent('click', function(e){
		e.stop();
		$('event_scroller').morph({height: 300});
	});
	
	$('close_').addEvent('click', function(e){
		e.stop();
		$('event_scroller').morph({height: 20});
	});
	var g = new GoogleMapsHelper('map_wrapper'); 

	var url_ = "http://localhost:7000/api/get_events/2.json";
	var req = new Request.JSON({url: url_,
		onSuccess: function(info) {
			info.each(function(i) {
				console.debug(i);
				g.addMarker(g.getPoint(i.latitude, i.longitude));
			});
		}
	}).get();
	
	var url_ = "http://localhost:7000/api/get_user/2.json";
	var req = new Request.JSON({url: url_,
		onSuccess: function(info) {
			
				console.debug(info);
				g.addMarker(g.getPoint(info.latitude, info.longitude));
		}
	}).get();
}

window.addEvent('domready', function(){
	google.setOnLoadCallback(initialize);
});