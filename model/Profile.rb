class Profile < Sequel::Model(:profiles)
  self.raise_on_save_failure = false
  many_to_one :country, :join_table => :countries, :class => :Country
  
  validations.clear
  validates do 
    presence_of     :real_name, :user_alias
    length_of       :real_name, :within => 3..100
    uniqueness_of   :user_alias
  end
  
  def prepare_update(params)
    update(
       :photo_path  => params[:photo_path],
       :homepage    => params[:preferences],
       :bio         => params[:bio],
       :user_alias  => params[:user_alias],
       :real_name   => params[:real_name],
       :homepage    => params[:homepage],
       :location    => params[:location]
     )
  end
  
  def self.by_id_or_alias(value)
    profile = Profile.select(:user_id).where(
      {:user_id => value.to_i} | {:user_alias => value}).first
      
    if !profile.nil?
      type = DB['SELECT user_type FROM users WHERE id = ?', profile.user_id].first[:user_type]
      return User.factory(:key => profile.user_id, :type => type)  
    end
    return nil
  end
end
