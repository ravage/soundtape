class AccountController < Controller
  helper :utils, :user, :aspect
  
  def register(type = nil)
    redirect Rs(:register, :user) unless valid_user_type(type)
    @type = get_klass(type).name.downcase
  end
  
  def create(type = nil)
    redirect R(:/) unless valid_user_type(type) && request.post?
  
    if request.post?
       klass = get_klass(type)
       klass = klass.prepare(request.params)
       request[:real_name].strip!
       if klass.valid? && !request[:real_name].empty? && request[:real_name].length > 3 && request[:real_name].length < 100
         begin
           klass.save 
           Profile[:user_id => klass.id].update(:real_name => request[:real_name])
         rescue Sequel::DatabaseError => e
           oops(Rs(:create), e)
         end
         send_activation_mail(klass)
         flash[:success] = _('successfully created account')
       else
         flash[:email]     = request[:email]
         flash[:real_name] = request[:real_name]
       end
     end
  end
  
  def login
    if request.post?
      if !user_login(request.params)
        flash[:error] = true;
      else
        redirect Rs(:index)
      end
    end
  end

  def index
    redirect Rs(:login) unless logged_in?
    
    @user = user
  end
  
  def activate(key = nil)
    redirect :/ if key.nil? || key.empty?
    if User.activate(key)
      flash[:active] = true
    else
      flash[:active] = false
    end
  end
  
  private
  
  def send_activation_mail(userds)
    msg = _('Please activate your account')
    msg += "\nhttp://localhost:7000#{Rs(:activate)}/#{userds.activation_key}"
    ret = Thread.new do
      begin
        Ramaze::EmailHelper.send(userds.email, _('Account Activation'), msg)
      rescue Exception => e
        oops('user/send_activation_mail', e)
      end
    end
  end
  
  def get_klass(type)
    return Kernel.const_get(SoundTape::Constant.user_types[type.to_sym])
  end
  
  def valid_user_type(type)
    return nil if type.nil?
    return !SoundTape::Constant.user_types.keys.index(type.to_sym).nil?
  end
  
  before(:activate, :login, :register) {redirect Rs(:/) if logged_in?}
end