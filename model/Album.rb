class Album < Sequel::Model(:albums)
  one_to_many :categories, :one_to_one => true
  one_to_many :tracks
end
