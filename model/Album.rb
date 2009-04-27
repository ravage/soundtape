class Album < Sequel::Model(:albums)
  one_to_many :tracks, :join_table => :tracks, :class => :Track
  self.plugin(:validation_class_methods)
  
  validations.clear
  validates do
    presence_of :title
  end
  
  def to_s
    return title
  end
end
