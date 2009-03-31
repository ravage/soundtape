class User < Sequel::Model(:users)
  one_to_many   :agendas, :one_to_one => true
  one_to_many   :profiles, :one_to_one => true
  one_to_many   :albuns
  one_to_many   :map_points, :one_to_one => true
  one_to_many   :comments
  one_to_many   :profiles, :one_to_one => true
  one_to_many   :user_favs
end