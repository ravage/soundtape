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
  before(:fan_of, :not_fan_of) {redirect_referer unless logged_in?}
end