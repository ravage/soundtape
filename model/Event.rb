class Event < Sequel::Model(:events)
  include Ramaze::Helper::Utils
  many_to_one :agenda, :join_table => :agendas, :class => :Agenda
  
  def validate
    validates_presence      [:name, :local, :building, :when]
    validates_numeric       :price
    validates_length_range  3..100, [:name, :local, :building]
    
    errors.add(:flyer_path, 'not an image') if flyer_path == 'NAI'
    errors.add(:when, 'should be in the future') unless self.when > Time.now 
  end
  
  
  def prepare(params, user)
    @user = user
    
    date_time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:#{params[:minute]}:00"
  
    if(params[:flyer])
      flyer = upload(params[:flyer], @user)
      if(flyer.respond_to?(:map!))
        flyer.map! { |file| file = File.basename(file) }
        original, thumb =  *flyer
      else
        original = thumb = flyer
      end
    end

    self.name         = params[:name]
    self.description  = params[:description]
    self.local        = params[:location]
    self.latitude     = params[:latitude]
    self.longitude    = params[:longitude]
    self.building     = params[:building]
    self.when         = date_time
    self.price        = params[:price]
    self.flyer_path   = original || nil
    self.flyer_thumb  = thumb || nil
    self.currency_id  = params[:currency]
    self.user_id      = user.id_
  end
  
  def upload(file_info, user)
    upload = SoundTape::Helper::Upload.new(file_info)

    return nil unless upload.is_uploaded?

    begin
      return 'NAI' unless upload.is_image?
      original = upload.move_to(File.join(get_or_create_event_dir(user.id_), "#{Time.now.to_i}#{upload.extension}"))
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
  
  def day
    return self.when.day unless self.when.nil?
  end
  
  def month
    return self.when.month unless self.when.nil?
  end
  
  def year
    return self.when.year unless self.when.nil?
  end
  
  def hour
    return self.when.hour unless self.when.nil?
  end
  
  def minutes
    return self.when.min unless self.when.nil?
  end
  
  def sane_delete
    SoundTape::Helper.remove_files(absolute_path(flyer_path), absolute_path(flyer_thumb))
    delete
  end
  
  def absolute_path(file)
      return File.join(File::SEPARATOR, SoundTape.options.Constant.upload_path, user_id.to_s, SoundTape.options.Constant.events_path, file)
    end
  
  def link_path(file)
    return SoundTape.options.Constant.event_default_small if file.nil?
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, user_id.to_s, SoundTape.options.Constant.events_path , file)
  end
  
  def thumbnail
    return link_path(flyer_thumb)
  end
  
  def id_
    return id
  end
  
  def to_json
    return {
      :json_class   => self.class.name,
      :name         => name,
      :description  => description,
      :location     => local,
      :longitude    => longitude,
      :latitude     => latitude,
      :when         => self.when,
      :price        => price,
      :thumb        => thumb
    }.to_json
  end
end