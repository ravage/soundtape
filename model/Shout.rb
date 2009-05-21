class Shout < Sequel::Model(:shouts)
  many_to_one :poster, :join_table => :users, :class => :User, :key => :post_to
  
  def validate
    validates_presence [:content, :post_by]
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
