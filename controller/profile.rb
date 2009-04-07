class ProfileController < Controller
  helper :user, :utils
  
  def view(userid = nil)
    redirect :/ if userid.nil?
    
    #FIXME better redirect on id or alias
    @user = User.by_id_or_alias(userid)
    
    redirect :/ if @user.nil?
  end
  
  def edit(userid = nil)
    redirect R(UserController, :login) unless logged_in?
    redirect Rs(:view, user.id) unless userid.to_i == user.id.to_i || userid.nil?
    
    @user = user
  end
  
  def update
    redirect_referer unless request.post? && logged_in?

    begin
      profile = user.profiles.first  
      profile.update(
         :photo_path   => request[:photo_path],
         :homepage     => request[:preferences],
         :country_id   => request[:country],
         :bio          => request[:bio],
         :user_alias   => request[:user_alias],
         :real_name    => request[:real_name],
         :map_point_id => request[:map_point_id]
       )
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
end