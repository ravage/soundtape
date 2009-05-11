class AccountController < Controller
  helper :utils, :user, :aspect
  
  def register(type = nil)
    redirect r(:register, :user) unless valid_user_type(type)
    @type = get_klass(type).name.downcase
  end
  
  def create(type = nil)
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
          oops(r(:create), e)
        end
        send_activation_mail(klass)
        flash[:success] = _('successfully created account')
      else
        prepare_flash(:errors => klass.errors, :prefix => 'account')
        redirect_referer
      end
    end
  end
  
  def login
    if request.post?
      if !user_login(request.params)
        flash[:error] = true;
      else
        session[:user_id] = user.id_
        session[:user_alias] = user.profile.user_alias
        redirect ProfileController.r(:view, user.profile.user_alias)
      end
    end
  end
  
  def logout
    user_logout
    session.clear
    redirect :/
  end
  
  def update_password
    redirect_referer unless request.post? && logged_in?
    begin
      user.update_password(request)
    rescue Sequel::DatabaseError => e
      oops(r(:update_password), e)
    end
    
    if user.valid?
      redirect ProfileController.r(:view, user.alias)
    else
      prepare_flash(:errors => user.errors, :prefix => 'account')
      redirect_referer
    end
  end

  def index
    redirect r(:login) unless logged_in?
    
    @user = user
  end
  
  def activate(key = nil)
    redirect :/ if key.nil? || key.empty?
    if ::User.activate(key)
      flash[:active] = true
    else
      flash[:active] = false
    end
  end
  
  private
  
  def send_activation_mail(userds)
    msg = _('Please activate your account')
    msg += "\nhttp://localhost:7000#{r(:activate)}/#{userds.activation_key}"
    Ramaze.defer do
      begin
        Ramaze::EmailHelper.send(userds.email, _('Account Activation'), msg)
      rescue Exception => e
        oops('user/send_activation_mail', e)
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

  before(:activate, :login, :register) {redirect r(:/) if logged_in?}
end
