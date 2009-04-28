class Event < Sequel::Model(:events)
  extend Ramaze::Helper::Utils
  self.raise_on_save_failure = false
  many_to_one :agenda, :join_table => :agendas, :class => :Agenda
  self.plugin(:validation_class_methods)
  
  validations.clear
  validates do
    presence_of     :name, :description, :local, :building, :when
    numericality_of :price
    length_of       :name, :local, :building, :within => 3..100
    
    each :flyer_path do |validation, field, value|
      validation.errors[field] << 'not an image' if value == 'NAI'
    end
    
    each :when do |validation, field, value|
      validation.errors[field] << 'should be in the future' unless value > Time.now
    end
  end
  
  def self.prepare_insert(params, user)
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

    event = self.new(
      :name         => params[:name],
      :description  => params[:description],
      :local        => params[:local],
      :building     => params[:building],
      :when         => date_time,
      :price        => params[:price],
      :flyer_path   => original || nil,
      :flyer_thumb  => thumb || nil,
      :currency_id  => params[:currency],
      :user_id      => user.id_)
    
    return event
  end
  
  def prepare_update(params, user)
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

    update(
      :name         => params[:name],
      :description  => params[:description],
      :local        => params[:local],
      :building     => params[:building],
      :when         => date_time,
      :price        => params[:price],
      :flyer_path   => original || flyer_path,
      :flyer_thumb  => thumb || flyer_thumb,
      :currency_id  => params[:currency])
  end
  
  def upload(file_info, user)
    self.class.upload(file_info, user)
  end
  
  def self.upload(file_info, user)
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

  def self.create_thumbnail(path)
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
  
  def id_
    return id
  end
end