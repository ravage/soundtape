class Event < Sequel::Model
  one_to_many :map_points, :one_to_one => true
  one_to_many :comments
end