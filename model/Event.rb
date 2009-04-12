class Event < Sequel::Model(:events)
  self.plugin(:validation_class_methods)
  
  validations.clear
  validates do
    presence_of     :name, :description, :local, :building
    numericality_of :price
    length_of       :name, :local, :building, :within => 3..100
    
    each :when do |validation, field, value|
      validation.errors[field] << 'should be in the future' unless value > Time.now
    end
  end
    
  def self.prepare_insert(params)
    date_time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:#{params[:minute]}:00"
    
    event = self.new(
      :name         => params[:name],
      :description  => params[:description],
      :local        => params[:local],
      :building     => params[:building],
      :when         => date_time,
      :price        => params[:price].to_f,
      :flyer_path   => params[:flyer_path],
      :currency_id  => params[:currency]
    )
    
    return event
  end
end