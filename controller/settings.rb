class SettingsController < Controller
  helper :user, :utils, :aspect
  
  provide(:json, :type => 'application/json'){ |action, value| value.to_json }
  
  def index
    redirect r(:profile)
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
    @event
  end
  
  def discography
    @albums = user.albums
  end
  
  def album(album_id = nil)
    if album_id.nil?
      @action = 'create_album'
      @album = Album.new
    else
      @action = 'update_album'
      @album = user.album(album_id)
      redirect r(:discography) if @album.nil?
      @track = Track.new
    end
  end

  def track(track_id = nil)
    if track_id.nil?
      @action = 'create_track'
      @track = Track.new
    else
      @action = 'update_track'
      @track = user.track(track_id)
      
      redirect r(:discography) if @track.nil?
    end
  end
  
  def elements
    
  end
  
  def delete
  end
  
  def photos
    @photos = user.photos
  end
  
  def photo(photo_id = nil)
    redirect_referer if photo_id.nil?
    @photo = user.photo(photo_id)
    redirect_referer if @photo.nil?
  end
    
  before(:profile, :avatar, :password, :notifications, :url_alias, :location, 
    :photos, :delete, :discography, :elements, :agenda, :event, :index) { redirect_referer unless logged_in? }
    
  before(:discography, :elements, :agenda, :events) {redirect_referer unless user.kind_of?(Band)}
end