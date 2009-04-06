class ProfileController < Controller
  def view(userid)
     @user = User[:id => userid]#.eager_graph(:profile, :agenda).filter('users.id'.lit => userid.to_i).first
     pp @user
   end
end