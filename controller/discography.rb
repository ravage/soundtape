class DiscographyController < Controller
  helper :utils, :user
  def create_album
    album = Album.new
    album.prepare(request, user)
    if album.valid?
      begin
       user.add_album(album)
      rescue Sequel::DatabaseError => e
        oops(r(:create_album), e)
      end
    else
      prepare_flash(:errors => album.errors, :prefix => 'album')
    end
    redirect SettingsController.r(:album, album.id_)
  end
  
  def update_album
    redirect SettingsController.r(:discography) unless request.params.has_key?('album_id')
    album = user.album(request[:album_id])
    redirect SettingsController(:discography) if album.nil?
    album.prepare(request, user)
    if album.valid?
      begin
        album.save_changes
      rescue Sequel::DatabaseError => e
        oops(r(:update_album), e)
      end
    else
      prepare_flash(:errors => album.errors, :prefix => 'album')
    end
    redirect SettingsController.r(:album, album.id_)
  end
  
  def create_track
    track = Track.new
    track.prepare(request, user)
    if track.valid?
      begin
        album_id = request[:album_id] || request[:album]
        album = user.album(album_id)
        redirect SettingsController.r(:discography) if album.nil?
        album.add_track(track)
      rescue Sequel::DatabaseError => e
        oops(r(:create_track), e)
      end
    else
      prepare_flash(:errors => track.errors, :prefix => 'track')
    end
    redirect_referer
  end
  
  def update_track
    redirect SettingsController.r(:discography) unless request.params.has_key?('track_id')
    track = user.track(request[:track_id])
    redirect SettingsController(:discography) if track.nil?
    track.prepare(request, user)
    if track.valid?
      begin
        track.save_changes
      rescue Sequel::DatabaseError => e
        oops(r(:update_track), e)
      end
    else
      prepare_flash(:errors => track.errors, :prefix => 'track')
      redirect SettingsController.r(:track, track.id_)
    end
    redirect SettingsController.r(:discography)
  end
  
  def delete_track(track_id = nil)
    redirect SettingsController.r(:discography) if track_id.nil?
    track = user.track(track_id)
    track.delete
    redirect_referer
  end
  
  def delete_album(album_id = nil)
     redirect SettingsController.r(:discography) if album_id.nil?
     album = user.album(album_id)
     album.delete
     redirect_referer
   end
  
  before(:create_album, :create_track, :update_album, :update_track) { redirect :/ unless logged_in? && request.post?}
end