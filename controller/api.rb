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
    events = Event.filter({:user_id => user_id} & (:when >= Time.now)).all unless user_id.nil?
    return  events unless events.nil?
    'failure'
  end
  
  def get_event(event_id) 
    event = Event[:id => event_id] unless event_id.nil?
    return event unless event.nil?
    'failure'
  end
  
  def get_tracks(band_id = nil)
    case band_id
    when 'random'
      @tracks = Track.random.all
    when %r{^[0-9]+}
      band = Band[:id => band_id]
      @tracks = band.tracks.all unless band.nil?
      @tracks = Track.random.all if @tracks.nil?
    end
    
  end
end