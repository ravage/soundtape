class User < Sequel::Model(:users)
  self.raise_on_save_failure = false
  self.plugin(:validation_class_methods)
  self.plugin(:single_table_inheritance, :user_type)
  self.set_dataset(dataset.filter({:user_type => name}))

  one_to_many :profiles, :unique => true, :join_table => :profiles, :class => :Profile
  one_to_many :photos, :join_table => :photos, :class => :Photo

  validations.clear
  validates do
    uniqueness_of   :email
    presence_of     :email, :password
    format_of       :email, :with => /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/
  end

  attr_accessor :password_confirmation

  def self.prepare(values)

    user = self.new(
      :email                  => values['email'],
      :password               => encrypt(values['password']),
      :password_confirmation  => encrypt(values['password_confirmation']),
      :activation_key         => encrypt(values['email']).slice(1..64)
    )
    return user
  end
  
  def update_password
    #FIXME: should go into Model?
    if request[:password] != request[:password_confirmation]
      flash[:error_profile_password] = _('Passwords mismatch')
      redirect Rs(:password)
    elsif request[:password].strip.empty?
      flash[:error_profile_password] = _('Password required')
      redirect Rs(:password)
    elsif request[:password].length < 6
      flash[:error_profile_password] = _('Passwords too short')
      redirect Rs(:password)
    end

    begin
      user.update_password(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update_password), e)
    end

    if user.valid?
      redirect R(ProfileController, :view, user.alias)
    else
      prepare_flash(:errors => user.errors, :prefix => 'profile')
      redirect Rs(:password)
    end
  end

  def self.authenticate(credentials)
    return nil if credentials.nil? || credentials.empty?

    params = DB['SELECT id, user_type FROM users
      WHERE email = ? AND password = ? AND active = ?',
      credentials['login'],
      encrypt(credentials['password']),
      true].first

      return self.factory(:key => params[:id], :type => params[:user_type]) unless params.nil?
  end

  def self.encrypt(value)
    return Digest::SHA512.hexdigest(value)
  end

  def encrypt(value)
    return self.class.encrypt(value)
  end

  def self.activate(key)
    return DB["UPDATE users 
      SET active = ? 
      WHERE activation_key = ?
      AND active = ?",
      true, key, false].update(0) == 1
  end

  def self.factory(params)
    return Band[:id => params[:key]] if params[:type] == SoundTape.options.Constant.user_types[:band]
    return User[:id => params[:key]] if params[:type] == SoundTape.options.Constant.user_types[:user]
    return nil
  end

  def alias
    return profile.user_alias
  end

  def profile
    return profiles.first
  end
  
  def photo(photo_id)
    return Photo[:user_id => id, :id => photo_id]
  end
  
  def id_
    return id
  end
end
