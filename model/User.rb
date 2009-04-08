class User < Sequel::Model(:users)
  raise_on_save_failure = false
  set_sti_key(:user_type)
  set_dataset(dataset.filter({:user_type => name}))
  
  one_to_many :profiles, :unique => true, :join_table => :profiles, :class => :Profile
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda
  
  validations.clear
  validates do
    uniqueness_of   :email
    presence_of     :email, :password
    format_of       :email, :with => /^[a-zA-Z]([.]?([[:alnum:]_-]+)*)?@([[:alnum:]\-_]+\.)+[a-zA-Z]{2,4}$/
    confirmation_of :password
  end
  
  attr_accessor :password_confirmation
  
  def self.prepare(values)
    user = self.new(
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
    
    return self[
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
  
  def self.factory(params)
    return Band[:id => params[:key]] if params[:type] == SoundTape::Constant.user_types[:band]
    return User[:id => params[:key]] if params[:type] == SoundTape::Constant.user_types[:user]
  end
end
