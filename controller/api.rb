class ApiController < Controller
  provide(:json, :type => 'application/json') { |action, value| value.to_json }
  provide(:html, :type => 'text/html') { |action, value| '' }
  
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
end