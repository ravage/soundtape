# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < Controller
  helper :user
  
  # the index action is called automatically when no other action is specified
  def index
    
  end
  
  def test
    %|
      <img src="#{Band.all.first.profile.avatar_small}" />
    |
     
  end
  
  def oops
    redirect :/ unless flash[:exception]
    _("An unexpected error ocurred please try again")
  end
  
  def method_missing(method, *args, &block)
    'something'
  end
end
