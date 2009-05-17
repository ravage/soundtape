class SettingsController < Controller
  helper :user, :utils, :aspect
  
  provide(:json, :type => 'application/json'){ |action, value| value.to_json }
  
  def index
    @title = _('Settings')
    redirect r(:profile)
  end
  
  def profile
    @title = _('Profile')
    @user = user
    @profile = user.profile
  end
  
  def avatar
    @title = _('Avatar')
    @profile = user.profile
  end
  
  def password
    @title = _('Password')
    @profile = user.profile
  end
  
  def notifications
    @title = _('Notifications')
    @profile = user.profile
  end
  
  def url_alias
    @title = _('URL Alias')
    @profile = user.profile
  end
  
  def location
    @title = _('Location')
    @profile = user.profile
  end
  
  def agenda
    @title = _('Agenda')
    @agenda = user.agenda
    @events = user.agenda.events
  end
  
  def event(event_id = nil)
    @title = _('Event')
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
    @title = _('Discography')
    @albums = user.albums
  end
  
  def album(album_id = nil)
    @title = _('Album')
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
    @title = _('Track')
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
    @title = _('Elements')
  end
  
  def delete
    @title = _('Delete')
  end
  
  def photos
    @title = _('Photos')
    @photos = user.photos
  end
  
  def photo(photo_id)
    @title = _('Photo')
    redirect_referer if photo_id.nil?
    @photo = user.photo(photo_id)
    redirect_referer if @photo.nil?
  end
    
  before(:profile, :avatar, :password, :notifications, :url_alias, :location, 
    :photos, :delete, :discography, :elements, :agenda, :event, :index, :album, :track) { redirect_referer unless logged_in? }
    
  before(:discography, :elements, :agenda, :events) {redirect_referer unless user.kind_of?(Band)}
end