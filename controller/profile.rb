class ProfileController < Controller
  helper :user, :utils
  
  def view(userid = nil)
    redirect :/ if userid.nil?
      
    get_user_or_redirect(userid)
  end
  
  def edit(userid = nil)
    redirect R(AccountController, :login) unless logged_in?
    redirect Rs(:view, user.id) unless userid.to_i == user.id.to_i || userid.nil?
    
    get_user_or_redirect(userid)
  end
  
  def update
    redirect_referer unless request.post? && logged_in?
    
    begin
      profile = user.profiles.first
      profile.prepare_update(request)
    rescue Sequel::DatabaseError => e
      oops(Rs(:update), e)
    end
    
    if(profile.valid?)
      redirect Rs(:view, user.id)
    else
      flash[:error] = true
      profile.errors.each do |key, message|
        flash["error_#{key.to_s}".to_sym] = message
      end

      request.params.each do |key, value|
        flash[key.to_sym] = value
      end
      redirect Rs(:edit, user.id)
    end
  end
  
  private
  
  def get_user_or_redirect(userid)
    @user = Profile.by_id_or_alias(userid)
    redirect :/ if @user.nil?
    return @user
  end
end