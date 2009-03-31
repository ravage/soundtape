class BandElement < Sequel::Model(:band_elements)
  many_to_one :band
  many_to_one :user
end