class Event < Sequel::Model(:events)
  validates do
    presence_of :name, :description, :local, :building
  end
  
  
  def self.prepare(params)
    event = self.new(
      :name         => params[:name].strip,
      :description  => params[:description].strip,
      :local        => params[:local].strip,
      :building     => params[:buildding].strip
    )
    return event
  end
end
