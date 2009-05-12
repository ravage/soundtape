class MainController < Controller
  helper :user, :gravatar, :utils
  
  def index
    @title = _('Home')
  end
  
  def oops
    @title = _('Unexpected Error')
    redirect :/ unless flash[:exception]
    _("An unexpected error ocurred please try again")
  end
  
  def feedback
    @title = _('Feedback')
    @user = user
    @profile = user.profile
    if request.post?
      msg = %|#{request[:name]} - #{request[:email]} says:
      #{request[:feedback]}|
      Ramaze.defer do
        begin
          Ramaze::EmailHelper.send(request[:email], '[SoundTape]: Feedback', msg)
        rescue Exception => e
          oops(r(:feedback), e)
        end
      end
      flash[:success] = _('Thank you for taking the time to give us some feedback!')
    end
  end
end
