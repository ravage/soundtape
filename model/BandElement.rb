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

  def id_
    return id
  end
end
