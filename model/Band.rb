class Band < User
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda, :key => :user_id
  one_to_many :events, :join_table => :events, :class => :Event
  
  def agenda
     return agendas.first
  end
   
  def events
    return events
  end
  
  def discography
    return nil
  end

end