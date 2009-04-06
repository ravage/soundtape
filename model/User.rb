class User < Sequel::Model(:users)
  one_to_many :profiles, :unique => true, :join_table => :profiles
  
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
        :password               => values['password'],
        :password_confirmation  => values['password_confirmation']
      }
    )
    return user
  end
  
end
