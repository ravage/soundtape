class Block < Sequel::Model
  many_to_one :parent
  one_to_many :children, :key=>:parent_id
end