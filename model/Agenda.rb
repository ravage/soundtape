class Agenda < Sequel::Model(:agendas)
  one_to_many :events, :join_table => :events, :class => :Event
  many_to_one :user, :join_table => :users, :class => :User
  
  def prepare_update(params)
    update(
      :description => params[:description]
    )
  end
  
  def event(event_id)
    Event.filter({:agenda_id => id} & {:id => event_id, :slug => event_id}.sql_or).first
  end
  
  def id_
    return id
  end
end
