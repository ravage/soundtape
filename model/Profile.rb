class Profile < Sequel::Model(:profiles)
  include Ramaze::Helper::Gravatar
  include Ramaze::Helper::Utils

  many_to_one :country, :join_table => :countries, :class => :Country
  many_to_one :user, :join_table => :users, :class => :User
  
  def validate
    validates_presence      [:real_name, :user_alias]
    validates_length_range  1..100, [:real_name, :user_alias]
    validates_unique        :user_alias
    validates_format        /^[\w\s]+$/, :real_name
    validates_format        /^[a-z0-9]+$/, :user_alias
    validates_format        /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/, :gravatar_email unless gravatar_email.empty?
    
    errors.add(:use_gravatar, 'need gravatar e-mail') if gravatar_email.empty? && use_gravatar
    errors.add(:photo_big, 'not an image') if photo_big == 'NAI'
    errors.add(:photo_small, 'not an image') if photo_small == 'NAI'
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
      avatar =  avatar(params[:photo_path]) 
      @old_avatar_big = photo_big
      @old_avatar_small = photo_small
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
      return gravatar(gravatar_email, :size => SoundTape.options.Constant.avatar_big_size, :default => 'identicon')
    else
      return link_path(photo_big) unless photo_big.nil? || photo_big.empty?
    end
    return default
  end
  
  def avatar_small
    default = SoundTape.options.Constant.avatar_default_small
    if use_gravatar
       return gravatar(gravatar_email, :size => SoundTape.options.Constant.avatar_small_size, :default => 'identicon')
     else
       return link_path(photo_small) unless photo_small.nil? || photo_small.empty?
     end
     return default
  end
  
  def link_path(file)
    #/uploads/5/avatar/
    return File.join(File::SEPARATOR, SoundTape.options.Constant.relative_path, user_id.to_s, SoundTape.options.Constant.avatar_path , file) unless file.nil?
  end
  
  def absolute_path(file)
    return File.join(File::SEPARATOR, SoundTape.options.Constant.upload_path, user_id.to_s, SoundTape.options.Constant.avatar_path, file) unless file.nil?
  end
  
  def delete_old_avatar
     SoundTape::Helper.remove_files(absolute_path(@old_avatar_big), absolute_path(@old_avatar_small))
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
