class User < Sequel::Model(:users)
  self.plugin(:single_table_inheritance, :user_type)
  self.set_dataset(dataset.filter({:user_type => name}))

  one_to_many :profiles, :unique => true, :join_table => :profiles, :class => :Profile
  one_to_many :photos, :join_table => :photos, :class => :Photo
  one_to_many :favs, :join_table => :user_favs, :class => :UserFav
  one_to_many :shouts, :join_table => :shout, :class => :Shout, :key => :post_to

  def validate
    if changed_columns.include?(:email) || new?
      validates_presence  [:email, :name]
      validates_format    /^[\w\s]+$/, :name
      errors.add(:email, 'is already taken') if DB['SELECT * FROM users WHERE email = ?', email].count == 1
      validates_format    RFC822::EmailAddress, :email
    end    
    
    if changed_columns.include?(:password) || new?
      errors.add(:password, 'is not present') if encrypt('') == password
      errors.add(:password, 'mismatch') if password_confirmation != password
    end
  end
  
  attr_accessor :password_confirmation, :name

  def prepare(values)
    self.email                  = values['email']
    self.password               = encrypt(values['password'])
    self.password_confirmation  = encrypt(values['password_confirmation'])
    self.activation_key         = encrypt(values['email']).slice(1..64)
    self.name                   = values['real_name']
  end
  
  def update_password(params)
    update(
      :password => encrypt(params[:password]), 
      :password_confirmation => encrypt(params[:password_confirmation])
    )
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
