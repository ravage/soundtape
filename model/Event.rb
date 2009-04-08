class Event < Sequel::Model(:events)
  validates do
    presence_of :name, :description
  end
  
  
  def self.prepare(params)
    event = self.new(
      :name         => params[:name].strip,
      :description  => params[:description].strip
    )
    return event
  end
end
