class Band < User
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda, :key => :user_id
  
  def agenda
     return agendas.first
  end
   
  def events
    return agenda.events
  end
  
  def discography
    return nil
  end
end