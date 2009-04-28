class Photo < Sequel::Model(:user_photos)
  include Ramaze::Helper::Utils
  
  self.raise_on_save_failure = false
  self.plugin(:validation_class_methods)
  
  many_to_one :user, :join_table => :users, :class => :User
  
  validations.clear
  validates do
    presence_of :photo_path, :thumb_path
    each :photo_path do |validation, field, value|
      validation.errors[field] << 'not an image' if value == 'NAI' || value.nil?
    end
  end
  
  def prepare(params, user)
    if(params[:photo_path])
      new_photo = upload(params[:photo_path], user)
      
      if(new_photo.respond_to?(:map!))
        new_photo.map! { |photo| photo = File.basename(photo) }
        original, thumb = *new_photo
      else
        original = thumb = new_photo
      end
    end
    
    self.photo_path = original || photo_path || 'NAI'
    self.thumb_path = thumb || thumb_path || 'NAI'
    self.title      = params[:title]
  end
  
  def update_title(params)
    update(:title => params[:title])
  end

  def upload(file_info, user)
    upload = SoundTape::Helper::Upload.new(file_info)

    return nil unless upload.is_uploaded?

    begin
      return 'NAI' unless upload.is_image?
      original = upload.move_to(File.join(get_or_create_photo_dir(user.id_), "#{Time.now.to_i}#{upload.extension}"))
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

  def thumbnail
    return link_path(thumb_path)
  end
  
  def photo
    return link_path(photo_path)
  end
  
  def sane_delete
    SoundTape::Helper.remove_files(absolute_path(photo_path), absolute_path(thumb_path))
    delete
  end
  
  def link_path(file)
    #/uploads/5/photos/
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, user_id.to_s, SoundTape.options.Constant.photos_path , file)
  end
  
  def absolute_path(file)
     return File.join(File::SEPARATOR, SoundTape.options.Constant.upload_path, user_id.to_s, SoundTape.options.Constant.photos_path, file)
   end
  
  def to_s
    return photo_path
  end
  
  def id_
    return id
  end
end