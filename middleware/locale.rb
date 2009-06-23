class Locale
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    FastGettext.text_domain = 'soundtape'
    FastGettext.available_locales = ['en', 'pt_PT']
    session = env['rack.session']
    session[:locale] = request[:locale] if request[:locale]
    if session.key?(:locale)
      FastGettext.locale = session[:locale] 
    else
      session[:locale] = FastGettext.locale
    end
    @app.call(env)
  end
end