class UserController < Controller
  helper :utils, :user, :aspect
  

  def register  
    if request.post?

      userds = User.prepare(request.params)
      
      if userds.valid? && !request[:real_name].empty?
        begin
          userds.save
        rescue Sequel::Error => e
          oops('user/register', e)
          flash[:exception] = true
          redirect '/oops'
        end
        userds.profiles_dataset.update(:real_name => h(request[:real_name]))
        send_activation_mail(userds)
        flash[:success] = _('successfully created account')
      else
        flash[:email]     = request[:email]
        flash[:real_name] = request[:real_name]
      end
      
      pp userds.errors
    end
  end
  
  def login
    if request.post?
      if !user_login(request.params)
        flash[:error] = true;
      else
        redirect Rs(:/)
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
  
  before(:activate, :login, :register) {redirect Rs(:/) if logged_in?}
end