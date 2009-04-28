class Currency < Sequel::Model(:currencies)
  def to_s
    return self.currency
  end
  
  def id_
    return id
  end
end