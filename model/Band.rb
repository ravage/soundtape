class Band < User
  one_to_many :agendas, :unique => true, :join_table => :agendas, :class => :Agenda, :key => :user_id
  one_to_many :events, :join_table => :events, :class => :Event, :key => :user_id
  one_to_many :albums, :join_table => :albums, :class => :Album, :key => :user_id
  
  def agenda
     return agendas.first
  end
   
  def album(album_id)
    return Album[:user_id => id, :id => album_id]
  end
   
  def track(track_id)
    return Track[track_id] if Band.eager_graph(:albums => :tracks).where(:tracks__id => track_id.to_i).count == 1
  end
  
  def fans
    Profile.join(:user_favs, :user_id => :user_id).filter(:user_favs__band_id => id)
  end
end