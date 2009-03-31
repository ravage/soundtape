class UserController < Controller
  def register
    User.insert(
      :email => request['email'], 
      :password => request['password'], 
      :profile_id => Profile.insert())
  end
end