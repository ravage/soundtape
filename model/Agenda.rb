class Agenda < Sequel::Model(:agendas)
  one_to_many :events, :join_table => :events, :class => :Event
  many_to_one :user, :join_table => :users, :class => :User
  
  def prepare_update(params)
    update(
      :description => params[:description]
    )
    Ramaze::Log.warn 'PREPARE UPDATE'
  end
  
  def event(event_id)
    Event.filter({:agenda_id => id, :id => event_id}).first
  end
end
