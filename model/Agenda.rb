class Agenda < Sequel::Model(:agendas)
  one_to_many :events, :join_table => :events, :class => :Event

end
