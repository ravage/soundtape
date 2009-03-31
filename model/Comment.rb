class Comment < Sequel::Model(:comments)
  many_to_one :parent
  one_to_many :children, :key => :parent_id
  many_to_one :user
end