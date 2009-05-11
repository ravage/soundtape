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
end
