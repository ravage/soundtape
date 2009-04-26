# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < Controller
  helper :user, :gravatar, :utils
  
  # the index action is called automatically when no other action is specified
  def index
    #Locale.current = 'pt_PT.UTF-8' if request[:lang] = 'pt'
    #session[:LOCALE] = 'pt_PT'
  end
  
  def test
    @gravatar_thumbnail_src = gravatar('ravage@fragmentized.net', 60)
    %{
      <img src="#{Band.first.profile.avatar_big}" />
    }
  end
  
  def oops
    redirect :/ unless flash[:exception]
    _("An unexpected error ocurred please try again")
  end
  
  def method_missing(method, *args, &block)
    'something'
  end
  
  def master
    
  end

end
