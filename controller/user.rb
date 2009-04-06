class UserController < Controller
  helper :utils, :user, :aspect
  

  def register  
    if request.post?

      userds = User.prepare(request.params)

      if userds.valid?
        begin
          userds.save
        rescue Sequel::Error => e
          oops('user/register', e)
          flash[:exception] = true
          redirect '/oops'
        end
        flash[:success] = _('successfully created account')
      else
        flash[:email] = request[:email]
      end
      
      pp userds.errors
    end
  end
  
  def login
    if request.post?
      user_login(request.params)
      flash[:login_failed] = true;
    end
  end
  
  def index
    send_activation_mail(User[:email => 'ravage@fragmentized.net'])
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
    ret = Thread.new { Ramaze::EmailHelper.send('ravage@fragmentized.net', _('Account Activation'), msg) }
  end
  
  before(:activate, :login, :register) {redirect Rs :/ if logged_in?}
end