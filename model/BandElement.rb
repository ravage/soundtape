class BandElement < Sequel::Model
  many_to_one :band
  many_to_one :user
end