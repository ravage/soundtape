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
  
  def discography
    
  end
  
  def elements
    
  end
  
  def delete
  end
  
  def update_profile
    begin
      profile = user.profile
      profile.update_profile(request)
      user.update(:email => request[:email])
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_profile), e)
    end
    
    if profile.valid? && user.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors.merge(user.errors), :prefix => 'profile')
      redirect Rs(:profile)
    end
  end
  
  def update_avatar
    begin
      profile = user.profile
      profile.update_avatar(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_profile), e)
    end

    if profile.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      flash[:profile_use_gravatar] = 1 if request.params.has_key?('use_gravatar')
      redirect Rs(:avatar)
    end
  end
  
  def update_password
    #FIXME: should go into Model?
    if request[:password] != request[:password_confirmation]
      flash[:error_profile_password] = _('Passwords mismatch')
      redirect Rs(:password)
    elsif request[:password].strip.empty?
      flash[:error_profile_password] = _('Password required')
      redirect Rs(:password)
    elsif request[:password].length < 6
      flash[:error_profile_password] = _('Passwords too short')
      redirect Rs(:password)
    end

    begin
      user.update_password(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_password), e)
    end

    if user.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => user.errors, :prefix => 'profile')
      redirect Rs(:password)
    end
  end
  
  def update_alias
    begin
      profile = user.profile
      profile.update_alias(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_alias), e)
    end
    
    if profile.valid?
       redirect R(ProfileController, :view, user.alias)
     else
       prepare_flash(:errors => profile.errors, :prefix => 'profile')
       redirect Rs(:url_alias)
     end
  end
  
  def update_location
    begin
      profile = user.profile
      profile.update_location(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_location), e)
    end

    if profile.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      redirect Rs(:location)
    end
  end
  
  def update_agenda
    redirect :/ unless user.respond_to?(:agenda)
      
    agenda = user.agenda
    begin
      agenda.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_agenda), e)
    end
    
    if agenda.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(agenda.errors, 'agenda')
      redirect Rs(:agenda)
    end
  end
  
  def update_event
  end
  
  def create_event
    event = Event.prepare_insert(request)
    if event.valid?
      begin
        agenda = user.agenda
        agenda.add_event(event)
      rescue Sequel::DatabaseError => e
        oops(Rs(:create_event), e)
      end
    else
      prepare_flash(:errors => event.errors, :prefix => 'event')
      redirect Rs(:agenda)
    end
  end
  
  def upload_photo
    photo = Photo.prepare(request, user)

    if photo.valid?
      begin
        user.add_photo(photo)
      rescue Sequel::DatabaseError => e
        oops(Rs(:upload_photo), e)
      end
    else
      prepare_flash(:errors => photo.errors, :prefix => 'profile')
      redirect Rs(:photos)
    end
    redirect Rs(:photos)
  end
  
  def photos
    @photos = user.photos
  end
  
  before(:update_profile, :update_agenda, :create_event, :update_event, 
    :update_profile, :update_avatar, :update_password, :update_alias, 
    :update_location, :upload_photo) {redirect_referer unless request.post? && logged_in?}
    
  before(:profile, :avatar, :password, :notifications, :url_alias, :location, 
    :photos, :delete, :discography, :elements, :agenda) { redirect_referer unless logged_in? }
  
   before(:discography, :elements, :agenda) {redirect_referer unless user.respond_to?(:discography)}
end