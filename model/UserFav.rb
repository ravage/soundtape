class UserFav < Sequel::Model(:user_favs)
  def validate
    validates_unique([:user_id, :band_id])
  end
  
  def prepare(user, band)
    self.user_id = user.id_
    self.band_id = band.id_
  end
end
