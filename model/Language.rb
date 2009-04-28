class Language < Sequel::Model(:languages)
  one_to_many :months, :class => :Month
  one_to_many :currencies, :clall => :Currency
  
  def id_
    return id
  end
end