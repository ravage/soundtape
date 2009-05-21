class UserController < Controller
  helper :aspect, :user, :utils
  
  def fan_of(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless band = Band[:id => band_id]
    fav = UserFav.new
    fav.prepare(user, band)
    if fav.valid?
      begin
        fav.save
      rescue Sequel::DatabaseError => e
        oops(r(:fan_of, e))
      end
    end
    redirect_referer
  end
  
  def not_fan_of(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless band = Band[:id => band_id]
    if fav = UserFav[:user_id => session[:user_id], :band_id => band_id]
      fav.delete
    end
    redirect_referer
  end
  
  def albums(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless @user = Profile.by_id_or_alias(band_id)
    redirect_referer unless @user.respond_to?(:albums)
    @albums = @user.albums
  end

  def elements(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless @user = Profile.by_id_or_alias(band_id)
    redirect_referer unless @user.respond_to?(:elements)
    @elements = @user.elements
  end

  def events(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless @user = Profile.by_id_or_alias(band_id)
    redirect_referer unless @user.respond_to?(:events)
    @events = @user.events
  end

  def photos(user_id = nil)
    redirect_referer if user_id.nil?
    redirect_referer unless @user = Profile.by_id_or_alias(user_id)
    redirect_referer unless @user.respond_to?(:photos)
    @photos = @user.photos
  end
  
  def fans(band_id = nil)
    redirect_referer if band_id.nil?
    redirect_referer unless @user = Profile.by_id_or_alias(band_id)
    redirect_referer unless @user.respond_to?(:fans)
    @fans = @user.fans
  end
  
  before(:fan_of, :not_fan_of) {redirect_referer unless logged_in?}
end