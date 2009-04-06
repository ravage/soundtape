class Country < Sequel::Model(:countries)
  def to_s
    return self.country
  end
end
