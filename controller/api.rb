class ApiController < Controller
  helper :user
  def getuser(user_id = nil)
    profile = Profile.filter({:user_id => user_id}).first unless user_id.nil?
    profile = user.profile if user_id.nil?
    respond profile.to_json unless profile.nil?
    respond "failure"
  end
  
  def getevent(event_if = nil)
    Ramaze::Log.warn 'WEEEEEEEEEEEEEEEEEEEEE!'
  end
end