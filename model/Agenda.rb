class Agenda < Sequel::Model(:agenda)
  one_to_many :events
end