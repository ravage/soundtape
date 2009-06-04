class Album < Sequel::Model(:albums)
  include Ramaze::Helper::Utils
  one_to_many :tracks, :join_table => :tracks, :class => :Track
  many_to_one :band, :join_table => :users, :class => :Band
  one_to_many :shouts, :join_table => :album_shouts, :class => :AlbumShout, :key => :post_to, :order => :created_at.desc
  
  def validate
    validates_presence [:title]
    validates_length_range 3..255, :title
    errors.add(:cover, 'not an image') if cover == 'NAI'
  end

  def prepare(params, user)
    self.title = params[:title]
    self.slug = slug_it(self.class, params[:title])
    self.year = params[:year]
    self.label = params[:label]
    self.tags = params[:tags]

    if(params[:cover])
      temp_cover = upload(params[:cover], user)

      if(temp_cover.respond_to?(:map!))
        temp_cover.map! { |cover| cover = File.basename(cover) }
        original, thumb = *temp_cover
      else
        original = thumb = temp_cover
      end
    end

    self.cover = original || cover
    self.cover_thumb = thumb || cover_thumb
  end
  
  def number_of_tracks
    return Track.filter(:album_id => id_).count
  end

  def shout(shout_id, poster_id = nil)
    return AlbumShout[:post_to => id_, :post_by => poster_id, :id => shout_id] unless poster_id.nil?
    return AlbumShout[:post_to => id_, :id => shout_id]
  end

  #FIXME make it DRY... it's over many models
  def upload(file_info, user)
    upload = SoundTape::Helper::Upload.new(file_info)

    return nil unless upload.is_uploaded?

    begin
      return 'NAI' unless upload.is_image?
      original = upload.move_to(File.join(get_or_create_album_dir(user.id_), "#{Time.now.to_i}#{upload.extension}"))
    rescue SoundTape::UploadException => e
      return nil
    end
    
    thumb = create_thumbnail(original)

    return [original, thumb]
  end

  def create_thumbnail(path)
    thumb = SoundTape::Helper::ImageResize.new(path)
    thumb.extend(SoundTape::Helper::ImageResize::ImageScience)

    begin      
      path = thumb.crop(SoundTape.options.Constant::thumbnail_size)
    rescue SoundTape::ImageResizeException => e
      return nil
    end

    return path
  end
  
  def self.by_id_or_slug(id)
    return Album.filter({:id => id, :slug => id}.sql_or).first
  end
  
  def to_s
    return title
  end
  
  def id_
    return id
  end
  
  def thumbnail
    return link_path(cover_thumb)
  end
  
  def link_path(file)
    return SoundTape.options.Constant.album_default_small if file.nil?
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, user_id.to_s, SoundTape.options.Constant.albums_path , file)
  end
end
