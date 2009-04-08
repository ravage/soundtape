class Profile < Sequel::Model(:profiles)
  raise_on_save_failure = false
  many_to_one :country, :join_table => :countries, :class => :Country
  
  validations.clear
  validates do 
    presence_of     :real_name, :user_alias
    length_of       :real_name, :within => 3..100
    uniqueness_of   :user_alias
  end
  
  def prepare_update(values)
    update(
       :photo_path   => values['photo_path'],
       :homepage     => values['preferences'],
       :country_id   => values['country'],
       :bio          => values['bio'],
       :user_alias   => values['user_alias'],
       :real_name    => values['real_name'],
       :map_point_id => values['map_point_id']
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
