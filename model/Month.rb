class Month < Sequel::Model(:months)
  
  def to_s
    return month
  end
  
  def self.from_now
    Month.filter({:language_id => 2} & (:ref_id >=  Time.now.month))
  end
end