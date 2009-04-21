class User < Sequel::Model(:users)
  self.raise_on_save_failure = false
  self.plugin(:validation_class_methods)
  self.plugin(:single_table_inheritance, :user_type)
  self.set_dataset(dataset.filter({:user_type => name}))

  one_to_many :profiles, :unique => true, :join_table => :profiles, :class => :Profile

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
        return Band[:id => params[:key]] if params[:type] == SoundTape::Constant.user_types[:band]
        return User[:id => params[:key]] if params[:type] == SoundTape::Constant.user_types[:user]
        return nil
      end

      def alias
        return profile.user_alias
      end

      def profile
        return profiles.first
      end
    end
