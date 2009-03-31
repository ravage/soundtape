class Block < Sequel::Model(:blocks)
  many_to_one :parent
  one_to_many :children, :key=>:parent_id
end