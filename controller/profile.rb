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
      @photos = @user.photos
    when 'events'
      flash[:top_tab] = 'events'
    when 'discography'
      flash[:top_tab] = 'discography'
      @albums = @user.albums if @user.respond_to?(:albums)
    when 'elements'
      flash[:top_tab] = 'elements'
      @elements = @user.elements
    else
      flash[:top_tab] = @user.is_a?(Band) ? 'elements' : 'photos'
      @elements = @user.elements if flash[:top_tab] == 'elements'
      @photos = @user.photos if flash[:top_tab] == 'photos'
    end
    
    case args[2]
    when 'fans'
      flash[:bottom_tab] = 'fans'
      @fans = @user.fans if @user.respond_to?(:fans)
    when 'shouts'
      flash[:bottom_tab] = 'shouts'
    else
      flash[:bottom_tab] = 'shouts'
    end
        
    @profile = @user.profile
    @events = Event.filter({:user_id => @user.id_} & (:when >= Time.now)).all if @user.respond_to?(:agenda)
    @fan_box = @user.is_a?(Band) && @user.id_ != session[:user_id] && logged_in?
    @shouts = @user.shouts
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
  
  def shout(action = nil, user_id = nil)
    redirect_referer if user_id.nil? || action !~ /add|delete/
    
    case request[:shout_to]
    when 'event'
      redirect_referer unless @item = Event.by_id_or_slug(request[:param])
      @shout = EventShout.new
    when 'album'
      redirect_referer unless @item = Album.by_id_or_slug(request[:param])
      @shout = AlbumShout.new
    when /view|shouts/
      redirect_referer unless @item = Profile.by_id_or_alias(user_id)
      @shout = UserShout.new
    else
      redirect_referer
    end
    
    case action
    when 'add'
      add_shout
    when 'delete'
      @user = Profile.by_id_or_alias(user_id)
      delete_shout
    end
    flash[:shout] = true
    redirect_referer
  end
  
  before(:shout, :update_profile, :update_avatar, :update_alias, :update_location, :upload_photo) {redirect_referer unless request.post? && logged_in?}
  
  private
  
  def add_shout
    @shout.prepare(request, user)
    if @shout.valid?
      begin
        @item.add_shout(@shout)
        flash[:message] = _('Shout added')
      rescue Sequel::DatabaseError => e
        oops(r(:shout), e)
      end
    else
      flash[:message] = _('Need something to shout about!')
      prepare_flash(:errors => @shout.errors, :prefix => 'shout')
    end
  end
  
  def delete_shout
    if @user.id_ != session[:user_id]
      shout = @item.shout(request[:shout], session[:user_id])
    else
      shout = @item.shout(request[:shout])
    end
    
    unless shout.nil?
      shout.delete
      flash[:message] = _('Shout deleted')
    else
      flash[:message] = _('Something went wrong while deleteing your shout')
    end
  end
  
  def is_fan?
    return UserFav[:band_id => @user.id_, :user_id => session[:user_id]].nil?
  end
end