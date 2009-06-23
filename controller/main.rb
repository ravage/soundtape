class MainController < Controller
  helper :user, :gravatar, :utils
  
  def index()
    @title = _('Home')
    @feed = Feedzirra::Feed.fetch_and_parse("http://www.frequenciamaxima.com/feed/atom/")
    @entries = @feed.entries
    #@feed_events = Feedzirra::Feed.fetch_and_parse("http://palcoprincipal.sapo.pt/eventosBandas/RSS")
    #@generic_events = @feed_events.entries
    @events = Event.eager_graph(:agenda => :user).filter(:when >= Time.now).limit(3).all
    @albums = Album.eager_graph(:band).limit(3).all
  end
  
  def oops
    @title = _('Unexpected Error')
    redirect :/ unless flash[:exception]
    _("An unexpected error ocurred please try again")
  end
  
  def feedback
    @title = _('Feedback')
    @user = user
    @profile = user.profile
    if request.post?
      msg = %|#{h(request[:name])} - #{h(request[:email])} says:
      #{h(request[:feedback])}|
      Ramaze.defer do
        begin
          Ramaze::EmailHelper.send(SoundTape.options.Constant.feedback_email, '[SoundTape]: Feedback', msg)
        rescue Exception => e
          oops(r(:feedback), e)
        end
      end
      flash[:success] = _('Thank you for taking the time to give us some feedback!')
    end
  end
end
