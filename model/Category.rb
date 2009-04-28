class Category < Sequel::Model(:categories)
  one_to_many :albums, :join_table => :albums, :class => :Album
  
  def to_s
    return description
  end
  
  def id_
    return id
  end
end
