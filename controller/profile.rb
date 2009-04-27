class ProfileController < Controller
  helper :user, :utils, :aspect
  
  def view(userid = session[:user_alias])
    redirect :/ if userid.nil?
    @user = Profile.by_id_or_alias(userid)
    
    @agenda = @user.agenda if @user.respond_to?(:agenda)
    #TODO redirect to not found
    redirect :/ if @user.nil?
    
  end
  
  def update_profile
    begin
      profile = user.profile
      profile.update_profile(request)
      user.update(:email => request[:email])
    rescue Sequel::DatabaseError => e
      oops(r(:update_profile), e)
    end
    
    if profile.valid? && user.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors.merge(user.errors), :prefix => 'profile')
      redirect SettingsController.r(:profile)
    end
  end
  
  def update_avatar
    pp request
    begin
      profile = user.profile
      profile.update_avatar(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_profile), e)
    end

    if profile.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      flash[:profile_use_gravatar] = 1 if request.params.has_key?('use_gravatar')
      redirect SettingsController.r(:avatar)
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
      redirect SettingsController.r(:photos)
    end
    redirect Rs(:photos)
  end
  
  before(:update_profile, :update_avatar, :update_alias, :update_location, :upload_photo) {redirect_referer unless request.post? && logged_in?}
end