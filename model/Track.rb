class Track < Sequel::Model(:tracks)
  self.plugin(:validation_class_methods)

  validations.clear
  validates do
    presence_of :title
    length_of   :title, :within => 3..255
    #each :cover do |validation, field, value|
    #  validation.errors[field] << 'not an image' if value == 'NAI'
    #end
  end
  
  def prepare(params, user)
    self.title = params[:title]
    self.lyrics = params[:lyrics]
  end
end
