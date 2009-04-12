class Month < Sequel::Model(:months)
  
  def to_s
    return month
  end
  
end