class Profile < Sequel::Model(:profiles)
  Profile.raise_on_save_failure = false
  many_to_one :country, :join_table => :countries, :class => :Country
  
  validations.clear
  validates do 
    presence_of     :real_name, :user_alias
    length_of       :real_name, :user_alias, :within => 3..100
    uniqueness_of   :user_alias
  end
end
