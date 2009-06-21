class ApiController < Controller
  provide(:json, :type => 'application/json') { |action, value| value.to_json }
  provide(:html, :type => 'text/html') { |action, value| '' }
  
  provide(:xspf, :type => 'application/xspf+xml', :engine => 'Erubis')
  layout('xspf'){ |path, wish| wish == 'xspf'}
  
  def get_user(user_id)
    profile = Profile[:user_id => user_id] unless user_id.nil?
    return profile unless profile.nil?
    'failure'
  end
  
  def get_events(user_id)
    events = Event.filter(:user_id => user_id).all unless user_id.nil?
    return  events unless events.nil?
    'failure'
  end
  
  def get_event(event_id) 
    event = Event[:id => event_id] unless event_id.nil?
    return event unless event.nil?
    'failure'
  end
  
  def get_tracks(band_id = nil)
    @tracks = Band[:id => band_id].tracks.all
    #@band = Band[:id => band_id]
  end
end