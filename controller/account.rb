class AccountController < Controller
  helper :utils, :user, :aspect
  
  def register(type)
    @title = _('Register')
    redirect r(:register, :user) unless valid_user_type(type)
    @type = get_klass(type).name.downcase
  end
  
  def create(type = nil)
    @title = _('Create')
    redirect :/ unless valid_user_type(type) && request.post?
    
    if request.post?
      klass = get_klass(type)
      klass = klass.new
      klass.prepare(request.params)
      request[:real_name].strip!
      if klass.valid?
        begin
          klass.save 
          Profile[:user_id => klass.id_].update(:real_name => request[:real_name])
        rescue Sequel::DatabaseError => e
          oops(r(:create, type), e)
        end
        send_activation_mail(klass)
        flash[:success] = _('successfully created account. A message containing information on how to 
        activate your account was sent to the email address you provided when registering.
        After the activation process is complete, you may login into your account.')
      else
        prepare_flash(:errors => klass.errors, :prefix => 'account')
        redirect_referer
      end
    end
  end
  
  def login
    @title = _('Login')
    if request.post?
      if !user_login(request.params)
        flash[:error] = true;
      else
        @profile = user.profile
        session[:user_id] = @profile.user_id
        session[:user_alias] = @profile.user_alias
        session[:user_name] = @profile.real_name
        redirect(ProfileController.r(:view, @profile.user_alias))
      end
    end
  end
  
  def logout
    @title = _('Logout')
    user_logout
    session.clear
    redirect :/
  end
  
  def update_password
    @title = _('Update Password')
    redirect_referer unless request.post? && logged_in?
    begin
      user.update_password(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_password), e)
    end
    
    if user.valid?
      flash['success'] = 'Password Saved!'
      redirect SettingsController.r(:password)
    else
      prepare_flash(:errors => user.errors, :prefix => 'account')
      redirect_referer
    end
  end

  def index
    @title = _('Account')
    redirect r(:login) unless logged_in?
    
    @user = user
  end
  
  def activate(key)
    @title = _('Activate')
    redirect :/ if key.nil? || key.empty?
    if ::User.activate(key)
      flash[:active] = true
    else
      flash[:active] = false
    end
  end
  
  def reset
    if request.post?
      @user = ::User.by_email(request[:email])
      unless @user.nil?
        @password = @user.reset
        if @user.valid?
          send_reset_email unless @user.nil?
          @user.save_changes
          flash[:message] = _('Check your e-mail for details about resetting the password.')
        else
          flash[:message] = _('There was a problem while resetting your passsword.')
        end
      else
        flash[:message] = _('E-Mail invalid, perhaps misspelled?')
      end
    end
  end
  
  private
  
  def send_activation_mail(userds)
    msg = _('Please activate your account')
    msg += "\nhttp://www.soundtape.net#{r(:activate)}/#{userds.activation_key}"
    Ramaze.defer do
      begin
        Ramaze::EmailHelper.send(userds.email, _('Account Activation'), msg)
      rescue Exception => e
        oops('user/send_activation_mail', e)
      end
    end
  end

  def send_reset_email
    msg = _("You or someone requested a new password.")
    msg += _("\n\nYour new password: ")
    msg += @password
    msg += "\n\nhttp://www.soundtape.net/account/login"
    Ramaze.defer do
      begin
        Ramaze::EmailHelper.send(@user.email, _('Password Reset'), msg)
      rescue Exception => e
        oops('user/send_reset_email', e)
      end
    end
  end

  def get_klass(type)
    return Kernel.const_get(SoundTape.options.Constant.user_types[type.to_sym])
  end
  
  def valid_user_type(type)
    return nil if type.nil?
    return !SoundTape.options.Constant.user_types.keys.index(type.to_sym).nil?
  end

  before(:activate, :login, :register) {redirect(ProfileController.r(:view, session[:user_alias])) if logged_in?}
end
