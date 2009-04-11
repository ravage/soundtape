class ProfileController < Controller
  helper :user, :utils
  
  def view(userid = nil)
    redirect :/ if userid.nil?
    @user = Profile.by_id_or_alias(userid)
    
    @agenda = @user.agenda if @user.respond_to?(:agenda)
    #TODO redirect to not found
    redirect :/ if @user.nil?
    
  end
end