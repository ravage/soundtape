class Profile < Sequel::Model(:profiles)
  many_to_one :country, :join_table => :countries, :class => :Country
  
  validates do 
    presence_of :real_name
  end
end
