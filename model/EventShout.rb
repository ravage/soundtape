class EventShout < Sequel::Model(:event_shouts)
  def validate
    validates_presence [:content, :post_by]
  end

  def poster
    return @profile || @profile = Profile[:user_id => post_by]
  end

  def prepare(params, user)
    self.content = params[:shout_box]
    self.post_by = user.id_
  end
  
  def created
    created_at.strftime("%d/%m/%Y")
  end
  
  def id_
    return id
  end
end
