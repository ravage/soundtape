class SettingsController < Controller
  helper :user, :utils
  #layout '/mastersettings'
  
  def index
    redirect R(AccountController, :login) unless logged_in?
    @user = user
    @profile = user.profile
  end
  
  def agenda
    redirect R(AccountController, :login) unless logged_in?
    
    @agenda = user.agenda if user.respond_to?(:agenda)
    
  end
  
  def update
    redirect_referer unless request.post? && logged_in?
    
    begin
      profile = user.profiles.first
      profile.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update), e)
    end
    
    if(profile.valid?)
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(profile.errors)
      redirect Rs(:/)
    end
  end
  
  
end