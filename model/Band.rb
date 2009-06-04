class Band < User
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda, :key => :user_id
  one_to_many :events, :join_table => :events, :class => :Event, :key => :user_id
  one_to_many :albums, :join_table => :albums, :class => :Album, :key => :user_id
  one_to_many :elements, :join_table => :band_elements, :class => :BandElement, :key => :user_id
  
  def album(album_id)
    return Album.filter({:user_id => id} & {:id => album_id, :slug => album_id}.sql_or).first
  end
  
  def agenda
     return agendas.first
  end
   
  def track(track_id)
    return Track.join(:albums, :id => :album_id).filter(:albums__user_id => id_).select(:tracks.*).first
  end
  
  def fans
    Profile.join(:user_favs, :user_id => :user_id).filter(:user_favs__band_id => id)
  end
  
  def element(element_id)
    return BandElement.filter(:id => element_id, :user_id => id_).first
  end
  
  def possible_elements(search)
    profiles = Array.new
    DB["SELECT DISTINCT p.* 
      FROM profiles p
      JOIN users u ON p.user_id = u.id
      WHERE (
        p.real_name LIKE  ?
        OR u.email LIKE  ?
      )
      AND u.user_type =  ?
      AND u.id NOT IN (
        SELECT element_id
        FROM band_elements
        WHERE user_id = ?
        AND element_id IS NOT NULL
    ) 
    ORDER BY p.real_name LIMIT ?", "%#{search}%", "%#{search}%", 'User', id, 5].each { |row| profiles << Profile.load(row) }
    return profiles
  end
end