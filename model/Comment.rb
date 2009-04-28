class Comment < Sequel::Model(:comments)

  def id_
    return id
  end
end
