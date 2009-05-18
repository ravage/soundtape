class ProfileController < Controller
  helper :user, :utils, :aspect
  
  #0 => user, 1 => 1st tab, 2 => 2nd tab
  #/someone/photos/fans
  def view(*args)
    @title = _('Profile')
    
    redirect ProfileController.r(:view, session[:user_alias], 'photos', 'fans') if args.empty?
  
    @user = Profile.by_id_or_alias(args[0])
    #TODO redirect to not found
    redirect_referer if @user.nil?
    
    flash[:user] = @user.alias
    
    case args[1]
    when 'photos'
      flash[:top_tab] = 'photos'
    when 'events'
      flash[:top_tab] = 'events'
    when 'discography'
      flash[:top_tab] = 'discography'
    when 'elements'
      flash[:top_tab] = 'elements'
    else
      flash[:top_tab] = 'elements'
    end
    
    case args[2]
    when 'fans'
      flash[:bottom_tab] = 'fans'
    when 'shouts'
      flash[:bottom_tab] = 'shouts'
    else
      flash[:bottom_tab] = 'shouts'
    end
    
    @agenda = @user.agenda if @user.respond_to?(:agenda)
    @albums = @user.albums if @user.respond_to?(:albums)
    @profile = @user.profile if @user.respond_to?(:profile)
    @photos = @user.photos
  end
  
  def update_profile
    @title = _('Update Profile')
    begin
      profile = user.profile
      profile.update_profile(request)
      user.update(:email => request[:email])
    rescue Sequel::DatabaseError => e
      oops(r(:update_profile), e)
    end
    
    unless profile.valid? && user.valid?
      prepare_flash(:errors => profile.errors.merge(user.errors), :prefix => 'profile')
      flash['error'] = 'There was a problem with your request!'
    else
      flash['success'] = 'Profile Settings Saves!'
    end
    redirect_referer
  end
  
  def update_avatar
    @title = _('Update Avatar')
    begin
      profile = user.profile
      profile.update_avatar(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_profile), e)
    end

    if profile.valid?
      flash['success'] = 'Avatar Updated'
      profile.delete_old_avatar if request[:photo_path]
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
      flash[:profile_use_gravatar] = 1 if request.params.has_key?('use_gravatar')
    end
    redirect_referer
  end
  
  def update_alias
    @title = _('Update Alias')
    begin
      profile = user.profile
      profile.update_alias(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_alias), e)
    end
    
    if profile.valid?
       flash['success'] = 'URL Alias updated!'
     else
       prepare_flash(:errors => profile.errors, :prefix => 'profile')
     end
     redirect_referer
  end
  
  def update_location
    @title = _('Update Location')
    begin
      profile = user.profile
      profile.update_location(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_location), e)
    end

    if profile.valid?
      flash[:success] = 'Location updated!'
    else
      prepare_flash(:errors => profile.errors, :prefix => 'profile')
    end
    redirect_referer
  end
  
  def upload_photo
    @title = _('Upload Photo')
    photo = Photo.new
    photo.prepare(request, user)

    if photo.valid?
      begin
        user.add_photo(photo)
      rescue Sequel::DatabaseError => e
        oops(r(:upload_photo), e)
      end
      flash[:success] = 'Photo uploaded'
    else
      prepare_flash(:errors => photo.errors, :prefix => 'profile')
    end
    redirect_referer
  end
  
  def update_photo
    @title = _('Update Photo')
    redirect_referer unless request.params.has_key?('photo_id')
    photo = user.photo(request[:photo_id])
    redirect_referer if photo.nil?
    begin
      photo.update_title(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_photo), e)
    end
    flash[:success] = 'Photo uploaded'
    redirect_referer
  end
  
  def delete_photo(photo_id)
    @title = _('Delete Photo')
    redirect_referer if photo_id.nil?
    photo = user.photo(photo_id)
    redirect_referer if photo.nil?
    photo.sane_delete unless photo.photo_path.nil?
    flash[:success] = 'Photo deleted'
    redirect_referer
  end
  
  before(:update_profile, :update_avatar, :update_alias, :update_location, :upload_photo) {redirect_referer unless request.post? && logged_in?}
end