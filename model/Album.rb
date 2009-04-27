class Album < Sequel::Model(:albums)
  one_to_many :tracks, :join_table => :tracks, :class => :Track
end
