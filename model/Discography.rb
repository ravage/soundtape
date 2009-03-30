class Discography < Sequel::Model
  one_to_many :albuns
end