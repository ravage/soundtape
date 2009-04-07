class User < Sequel::Model(:users)
  
  one_to_many :profiles, :unique => true, :join_table => :profiles, :class => :Profile
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda
  
  User.raise_on_save_failure = false
  
  validations.clear
  validates do
    uniqueness_of   :email
    presence_of     :email, :password
    format_of       :email, :with => /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/
    confirmation_of :password
  end
  
  attr_accessor :password_confirmation
  
  def self.prepare(values)
    user = User.new(
      {
        :email                  => values['email'],
        :password               => encrypt(values['password']),
        :password_confirmation  => encrypt(values['password_confirmation']),
        :activation_key         => encrypt(values['email']).slice(1..64),
      }
    )
    return user
  end
  
  def self.authenticate(credentials)
    return nil if credentials.nil? || credentials.empty?
    
    return User[
      :email    => credentials['login'],
      :password => encrypt(credentials['password']),
      :active   => true
    ]
  end
  
  def self.encrypt(value)
    return Digest::SHA512.hexdigest(value)
  end
  
  def self.activate(key)
    return self.filter(:activation_key => key, :active => false).update(:active => true) == 1
  end
  
  def self.by_id_or_alias(value
    if Profile.filter(:user_alias => value).count == 1
      user_id = Profile.select(:user_id).where(:user_alias => value)
      return User[:id => user_id]
    elsif User.filter(:id => value).count == 1
      return User[:id => value]
    else
      return nil
    end
  end
  
end
