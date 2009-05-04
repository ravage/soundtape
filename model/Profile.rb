class Profile < Sequel::Model(:profiles)
  include Ramaze::Helper::Gravatar
  include Ramaze::Helper::Utils
  
  self.raise_on_save_failure = false
  self.plugin(:validation_class_methods)
  many_to_one :country, :join_table => :countries, :class => :Country
  many_to_one :user, :join_table => :users, :class => :User
  
  validations.clear
  validates do 
    presence_of     :real_name, :user_alias
    length_of       :real_name, :user_alias, :within => 3..100
    uniqueness_of   :user_alias
    format_of       :real_name, :with => /^[\w\s]+$/
    format_of       :user_alias, :with => /^[a-z0-9]+$/
    
    each :photo_big, :photo_small do |validation, field, value|
      validation.errors[field] << 'not an image' if value == 'NAI'
    end
    
    each :gravatar_email, :allow_blank => true do |validation, field, value|
       validation.errors[field] << 'invalid e-mail' unless value =~ /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/ 
    end

    each :use_gravatar do |validation, field, value|
      validation.errors[field] << 'need gravatar e-mail' if validation.values[:gravatar_email].empty? && value
    end
  end
  
  def update_profile(params)
    update(
      :real_name       => params[:real_name],
      :homepage        => params[:homepage],
      :bio             => params[:bio]
    )
  end
  
  def update_avatar(params)
    if(params[:photo_path])
      SoundTape::Helper.remove_files(absolute_path(photo_big), absolute_path(photo_small)) unless photo_big.nil?
      avatar =  avatar(params[:photo_path]) 
      
      if(avatar.respond_to?(:map!))
        avatar.map! { |val| val = File.basename(val) }
        big, small = *avatar
      else
        big = small = avatar
      end
    end
    
    update(
      :photo_big      => big || photo_big,
      :photo_small    => small || photo_small,
      :use_gravatar   => params.params.has_key?('use_gravatar') ? true : false,
      :gravatar_email => params[:gravatar_email]
    )
  end
  
  def update_alias(params)
    update(:user_alias => params[:user_alias])
  end
  
  def update_location(params)
    update(
      :location   => params[:location],
      :longitude  => params[:longitude],
      :latitude   => params[:latitude]
    )
  end
   
  def self.by_id_or_alias(value)
    profile = Profile.select(:user_id).where(
      {:user_id => value.to_i} | {:user_alias => value}).first
      
    if !profile.nil?
      type = DB['SELECT user_type FROM users WHERE id = ?', profile.user_id].first[:user_type]
      return User.factory(:key => profile.user_id, :type => type)  
    end
    return nil
  end
  
  def avatar(file_info)
    upload = SoundTape::Helper::Upload.new(file_info)
    
    return nil unless upload.is_uploaded?
    
    begin
      return 'NAI' unless upload.is_image?
      new_path = upload.move_to(File.join(get_or_create_avatar_dir(user_id),"#{Time.now.to_i}#{upload.extension}"))
    rescue SoundTape::UploadException => e
      return nil
    end
    
    return resize_avatar(new_path)
  end
  
  def resize_avatar(path)
    resizer = SoundTape::Helper::ImageResize.new(path)
    resizer.extend(SoundTape::Helper::ImageResize::ImageScience)
    big_size = SoundTape.options.Constant.avatar_big_size
    small_size = SoundTape.options.Constant.avatar_small_size
    big_suffix = SoundTape.options.Constant.avatar_big_suffix
    small_suffix = SoundTape.options.Constant.avatar_small_suffix
    
    begin      
      big_path = resizer.resize(big_size, big_size)
      small_path = resizer.resize(small_size, small_size)
      resizer.cleanup
    rescue SoundTape::ImageResizeException => e
      return nil
    end
    
    return [big_path, small_path]
  end
  
  def avatar_big
    default = SoundTape.options.Constant.avatar_default_big
    if use_gravatar
      return gravatar(gravatar_email, :size => SoundTape.options.Constant.avatar_big_size, :default => default)
    else
      return link_path(photo_big) unless photo_big.nil? || photo_big.empty?
    end
    return default
  end
  
  def avatar_small
    default = SoundTape.options.Constant.avatar_default_small
    if use_gravatar
       return gravatar(gravatar_email, :size => SoundTape.options.Constant.avatar_small_size, :default => default)
     else
       return link_path(photo_small) unless photo_small.nil? || photo_small.empty?
     end
     return default
  end
  
  def link_path(file)
    #/uploads/5/avatar/
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, user_id.to_s, SoundTape.options.Constant.avatar_path , file)
  end
  
  def absolute_path(file)
    return File.join(File::SEPARATOR, SoundTape.options.Constant.upload_path, user_id.to_s, SoundTape.options.Constant.avatar_path, file)
  end
  
  def id_
    return id
  end
  
  def to_json
    return {
      :json_class => self.class.name,
      :photo      => avatar_small,
      :location   => location,
      :profile    => ProfileController.r(:view, user_alias),
      :name       => real_name,
      :homepage   => homepage,
      :longitude  => longitude,
      :latitude   => latitude
    }.to_json
  end
end
