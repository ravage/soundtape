class SettingsController < Controller
  helper :user, :utils, :aspect
  #layout '/mastersettings'
  
  def profile
    redirect R(AccountController, :login) unless logged_in?
    @user = user
    @profile = user.profile
  end
  
  def agenda
    redirect R(AccountController, :login) unless logged_in?
    
    @agenda = user.agenda if user.respond_to?(:agenda)
    
  end
  
  def update_profile
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
  
  before(:update_profile, :update_agenda, :create_event) {redirect_referer unless request.post? && logged_in?}
end