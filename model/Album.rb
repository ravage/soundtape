class Album < Sequel::Model
  one_to_many :categories, :one_to_one => true
  one_to_many :tracks
end
