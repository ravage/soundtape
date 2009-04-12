class Agenda < Sequel::Model(:agendas)
  one_to_many :events, :join_table => :events, :class => :Event
  
  def prepare_update(params)
    update(
      :description => params[:description]
    )
    Ramaze::Log.warn 'PREPARE UPDATE'
  end
end
