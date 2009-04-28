class Country < Sequel::Model(:countries)
  def to_s
    return self.country
  end
  
  def id_
    return id
  end
end
