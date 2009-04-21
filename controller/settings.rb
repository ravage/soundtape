class SettingsController < Controller
  helper :user, :utils, :aspect
  #layout '/mastersettings'
  
  def profile
    redirect R(AccountController, :login) unless logged_in?
    @user = user
    @profile = user.profile
    
    @class_profile = 'class="first current"'
  end
  
  def avatar
    redirect R(AccountController, :login) unless logged_in?
    @profile = user.profile
    
    @class_avatar = 'class="current"'
  end
  
  def password
    redirect R(AccountController, :login) unless logged_in?
    @profile = user.profile
    
    @class_password = 'class="current"'
  end
  
  def notifications
    @profile = user.profile
    
    @class_notifications = 'class="current"'
  end
  
  def url_alias
    redirect R(AccountController, :login) unless logged_in?
    @profile = user.profile
    
    @class_urlalias = 'class="current"'
  end
  
  def location
    @profile = user.profile
    
    @class_location = 'class="current"'
  end
  
  def delete
    
    @class_delete = 'class="current"'
  end
  
  def update_profile
    pp request
    begin
      profile = user.profile
      profile.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update), e)
    end
    
    if profile.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      flash[:profile_use_gravatar] = 1 if request.params.has_key?('use_gravatar')
      redirect Rs(:profile)
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

  
  #TODO: eventually change to before_all
  before(:update_profile, :update_agenda, :create_event) {redirect_referer unless request.post? && logged_in?}
  before(:profile, :avatar, :password, :notifications, :url_alias, :location, :delete) do
    redirect_referer unless logged_in?
    @show_settings_block = true
  end
end