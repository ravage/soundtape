class Band < User
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda, :key => :user_id
  one_to_many :events, :join_table => :events, :class => :Event
  one_to_many :albums, :join_table => :albums, :class => :Album, :key => :user_id
  
  def agenda
     return agendas.first
  end
   
  def events
    return events
  end
  
  def album(album_id)
     return Album[:user_id => user_id, :id = album_id]
   end
end