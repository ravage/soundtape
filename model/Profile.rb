class Profile < Sequel::Model(:profiles)
  include Ramaze::Helper::Gravatar
  
  self.raise_on_save_failure = false
  self.plugin(:validation_class_methods)
  many_to_one :country, :join_table => :countries, :class => :Country
  
  validations.clear
  validates do 
    presence_of     :real_name, :user_alias
    length_of       :real_name, :within => 3..100
    uniqueness_of   :user_alias
    
    each :photo_path do |validation, field, value|
      validation.errors[field] << 'not an image' if value == 'NAI'
    end
    
    each :gravatar_email, :allow_blank => true do |validation, field, value|
       validation.errors[field] << 'invalid e-mail' unless value =~ /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/ 
    end
     
    each :use_gravatar do |validation, field, value|
      validation.errors[field] << 'need gravatar e-mail' if validation.values[:gravatar_email].empty? && value
    end
  end
  
  def prepare_update(params)
    
    avatar ||= avatar(params[:photo_path])
    avatar.gsub!(/public/, '') unless avatar.nil?
    
    update(
       :photo_path      => avatar || photo_path,
       :homepage        => params[:preferences],
       :bio             => params[:bio],
       :user_alias      => params[:user_alias],
       :real_name       => params[:real_name],
       :homepage        => params[:homepage],
       :location        => params[:location],
       :use_gravatar    => params.params.has_key?('use_gravatar') ? true : false,
       :gravatar_email  => params[:gravatar_email]
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
      new_path = upload.move_to("#{SoundTape::Constant.upload_path}/#{Time.now.to_i}#{upload.extension}")
    rescue SoundTape::UploadException => e
      return nil
    end
    
    return new_path unless resize_avatar(new_path).nil?
  end
  
  def resize_avatar(path)
    resizer = SoundTape::Helper::ImageResize.new(path)
    resizer.extend(SoundTape::Helper::ImageResize::ImageScience)
    big_size = SoundTape::Constant.avatar_big_size
    small_size = SoundTape::Constant.avatar_small_size
    big_suffix = SoundTape::Constant.avatar_big_suffix
    small_suffix = SoundTape::Constant.avatar_small_suffix
    
    pp resizer.class
    begin      
      resizer.resize(big_suffix, big_size, big_size)
      resizer.resize(small_suffix, small_size, small_size)
      resizer.cleanup
    rescue SoundTape::ImageResizeException => e
      return nil
    end
    
    return true
  end
  
  def avatar_big
    default = SoundTape::Constant.avatar_default_big
    if use_gravatar
      return gravatar(gravatar_email, SoundTape::Constant.avatar_big_size, default)
    else
      return photo_path.gsub('.', "#{SoundTape::Constant.avatar_big_suffix}.") unless photo_path.nil? || photo_path.empty?
    end
    return default
  end
  
  def avatar_small
    default = SoundTape::Constant.avatar_default_small
    if use_gravatar
       return gravatar(gravatar_email, SoundTape::Constant.avatar_small_size, default)
     else
       return photo_path.gsub('.', "#{SoundTape::Constant.avatar_small_suffix}.") unless photo_path.nil? || photo_path.empty?
     end
     return default
  end
  
  def no_gravatar_email
    gravatar_email.empty?
  end
end
