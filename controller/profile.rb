class ProfileController < Controller
  helper :user, :utils, :aspect
  
  def view(userid = session[:user_alias])
    redirect :/ if userid.nil?
    @user = Profile.by_id_or_alias(userid)
    @agenda = @user.agenda if @user.respond_to?(:agenda)
    @albums = @user.albums if @user.respond_to?(:albums)
    @profile = @user.profile if @user.respond_to?(:profile)
    @photos = @user.photos
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
      redirect ProfileController.r(:view, user.alias)
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
      redirect ProfileController.r(:view, user.alias)
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
      oops(r(:update_alias), e)
    end
    
    if profile.valid?
       redirect ProfileController.r(:view, user.alias)
     else
       prepare_flash(:errors => profile.errors, :prefix => 'profile')
       redirect_referer
     end
  end
  
  def update_location
    begin
      profile = user.profile
      profile.update_location(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_location), e)
    end

    if profile.valid?
      redirect ProfileController.r(:view, user.alias)
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      redirect r(:location)
    end
  end
  
  def upload_photo
    photo = Photo.new
    photo.prepare(request, user)

    if photo.valid?
      begin
        user.add_photo(photo)
      rescue Sequel::DatabaseError => e
        oops(r(:upload_photo), e)
      end
    else
      prepare_flash(:errors => photo.errors, :prefix => 'profile')
      redirect_referer
    end
    redirect SettingsController.r(:photos)
  end
  
  def update_photo
    redirect_referer unless request.params.has_key?('photo_id')
    photo = user.photo(request[:photo_id])
    redirect_referer if photo.nil?
    begin
      photo.update_title(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_photo), e)
    end
    redirect_referer
  end
  
  def delete_photo(photo_id = nil)
    redirect_referer if photo_id.nil?
    photo = user.photo(photo_id)
    redirect_referer if photo.nil?
    photo.sane_delete unless photo.photo_path.nil?
    redirect_referer
  end
  
  before(:update_profile, :update_avatar, :update_alias, :update_location, :upload_photo) {redirect_referer unless request.post? && logged_in?}
end