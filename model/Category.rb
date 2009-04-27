class Category < Sequel::Model(:categories)
  
  def to_s
    return description
  end
end
