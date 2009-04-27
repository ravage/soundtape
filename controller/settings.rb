class SettingsController < Controller
  helper :user, :utils, :aspect
  #layout '/mastersettings'
  
  def index
    redirect Rs(:profile)
  end
  
  def profile
    @user = user
    @profile = user.profile
  end
  
  def avatar
    @profile = user.profile
  end
  
  def password
    @profile = user.profile
  end
  
  def notifications
    @profile = user.profile
  end
  
  def url_alias
    @profile = user.profile
  end
  
  def location
    @profile = user.profile
  end
  
  def agenda
    @agenda = user.agenda
    @events = user.agenda.events
  end
  
  def event(event_id = nil)
    if event_id.nil?
      @action = 'create_event'
      @event = Event.new
    else
      @action = 'update_event' unless event_id.nil?
      @event = user.agenda.event(event_id)
      
      flash[:event_not_found] = 'The event you are looking for doesn\'t exist!' if @event.nil?
    end
  end
  
  def discography
    @albums = user.albums
  end
  
  def elements
    
  end
  
  def delete
  end
  
  def photos
    @photos = user.photos
  end
    
  before(:profile, :avatar, :password, :notifications, :url_alias, :location, 
    :photos, :delete, :discography, :elements, :agenda, :event, :index) { redirect_referer unless logged_in? }
    
  before(:discography, :elements, :agenda, :events) {redirect_referer unless user.kind_of?(Band)}
end