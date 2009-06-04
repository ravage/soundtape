class Track < Sequel::Model(:tracks)
  include Ramaze::Helper::Utils
  many_to_one :album, :class => :Album
  
  def validate
    validates_presence      [:title, :album_id, :number]
    validates_length_range  3..255, :title
  end
  
  def prepare(params, user)
    pp params
    self.slug = slug_it(self.class, params[:title])
    self.title = params[:title]
    self.lyrics = params[:lyrics]
    self.album_id = params[:album] || params[:album_id]
    self.number = params[:number]
  end
  
  def id_
    return id
  end
end
