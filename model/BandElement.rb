class BandElement < Sequel::Model(:band_elements)

  def validate
    validates_presence [:instruments, :real_name] if element_id.nil?
    validates_presence :instruments unless element_id.nil?
  end
  
  def prepare(params, user)
    self.instruments = params[:instruments]
    self.real_name = params[:name]
    self.user_id = user.id_
    self.element_id = params[:user_id]
  end
  
  def name
    return (real_name.nil?) ?  self.profile.real_name : real_name
  end
  
  def avatar
    return (real_name.nil?) ? self.profile.avatar_small : SoundTape.options.Constant.avatar_default_small
  end
  
  def location
    return (real_name.nil?) ? self.profile.location : nil
  end
  
  def profile
    return @profile || @profile = Profile[:user_id => element_id]
  end
  
  def update_element(params)
    if real_name.nil?
      update(:instruments => params[:instruments])
    else
      update(
        :instruments => params[:instruments] || instruments,
        :real_name => params[:name] || real_name
      )
    end
  end
  
  def id_
    return id
  end
end
