class DiscographyController < Controller
  helper :utils, :user
  
  def album(user_id = nil, event_id = nil)
    @title = _('Album')
    redirect_referer if user_id.nil? || !@user = Profile.by_id_or_alias(user_id)
    redirect_referer unless @album = @user.album(event_id)
    @shouts = @album.shouts
    @profile = @user.profile
    @tracks = @album.tracks
  end
  
  def create_album
    @title = _('Create Album')
    album = Album.new
    album.prepare(request, user)
    if album.valid?
      begin
       user.add_album(album)
      rescue Sequel::DatabaseError => e
        oops(r(:create_album), e)
      end
      redirect SettingsController.r(:discography)
    else
      prepare_flash(:errors => album.errors, :prefix => 'album')
      redirect_referer
    end
  end
  
  def update_album
    @title = _('Update Album')
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
      redirect SettingsController.r(:discography)
    else
      prepare_flash(:errors => album.errors, :prefix => 'album')
      redirect_referer
    end
  end
  
  def create_track
    @title = _('Create Track')
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
      redirect SettingsController.r(:album, album.id_)
    else
      prepare_flash(:errors => track.errors, :prefix => 'track')
      redirect_referer
    end
  end
  
  def update_track
    @title = _('Update Track')
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
      redirect SettingsController.r(:discography)
    else
      prepare_flash(:errors => track.errors, :prefix => 'track')
      redirect_referer
    end
  end
  
  def delete_track(track_id)
    @title = _('Delete Track')
    redirect SettingsController.r(:discography) if track_id.nil?
    track = user.track(track_id)
    track.delete
    redirect_referer
  end
  
  def delete_album(album_id)
    @title = _('Delete Album')
     redirect SettingsController.r(:discography) if album_id.nil?
     album = user.album(album_id)
     album.delete
     redirect_referer
   end
  
  before(:create_album, :create_track, :update_album, :update_track) { redirect :/ unless logged_in? && request.post? && user.is_a?(Band)}
end