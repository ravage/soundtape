class ApiController < Controller
  
  def getuser(user_id)
    profile = Profile.filter({:user_id => user_id} & ~{:latitude => nil}).first
    Ramaze::Log.warn profile
    respond profile.to_json unless profile.nil?
    respond "failure"
  end
end