class ProfileController < Controller
  helper :user
  
  def view(userid)
     @user = User[:id => userid]
     pp @user
  end
  
  def edit(userid)
    redirect R(UserController, :login) unless logged_in?
    redirect Rs(:view, user.id) unless userid.to_i == user.id.to_i
    
    @user = user
  end
end