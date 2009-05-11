class MainController < Controller
  helper :user, :gravatar, :utils
  
  def index
  end
  
  def oops
    redirect :/ unless flash[:exception]
    _("An unexpected error ocurred please try again")
  end
  
  def master
    
  end
end
