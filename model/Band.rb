class Band < User
  many_to_many  :users, :join_table => :band_elements
  one_to_many   :discographies, :one_to_one => true
  one_to_many   :agendas, :one_to_one => true
  one_to_many   :mailing_lists, :one_to_one => true
end