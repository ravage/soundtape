class Track < Sequel::Model(:tracks)
  include Ramaze::Helper::Utils
  many_to_one :album, :class => :Album
  
  def validate
    validates_presence      [:title, :album_id, :number]
    validates_length_range  3..255, :title
  end
  
  def prepare(params, user)
    if params[:track]
      @file_info = params[:track]
      @user = user
      self.track_path = File.basename(upload)
    end 
    
    self.slug = slug_it(self.class, params[:title]) if new?
    self.title = params[:title]
    self.lyrics = params[:lyrics]
    self.album_id = params[:album] || params[:album_id]
    self.number = params[:number]
  end
  
  def upload
    upload = SoundTape::Helper::Upload.new(@file_info)
    return nil unless upload.is_uploaded?
    begin
      path = upload.move_to(File.join(get_or_create_track_dir(@user.id_), "#{Time.now.to_i}#{upload.extension}"))
    rescue SoundTape::UploadException => e
      return nil
    end

    return path
  end
  
  def track
    return link_path(track_path) unless track_path.nil? || track_path.empty?
  end
  
  def self.random(max = 10)
    Track.eager_graph(:album => :band).order('RAND()'.lit).limit(max)
  end
  
  def sane_delete
    SoundTape::Helper.remove_files(absolute_path(track_path))
    delete
  end
  
  def link_path(file)
    pp album
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, album.user_id.to_s, SoundTape.options.Constant.tracks_path, file)
  end
  
  def absolute_path(file)
    return File.join(File::SEPARATOR, SoundTape.options.Constant.upload_path, album.user_id.to_s, SoundTape.options.Constant.tracks_path, file)
  end

  
  def id_
    return id
  end
end
