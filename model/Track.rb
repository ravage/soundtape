class Track < Sequel::Model(:tracks)
  
  def validate
    validates_presence      [:title, :album_id]
    validates_length_range  3..255, :title
  end
  
  def prepare(params, user)
    self.title = params[:title]
    self.lyrics = params[:lyrics]
    self.album_id = params[:album] || params[:album_id]
  end
  
  def id_
    return id
  end
end
