class Locale
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    FastGettext.text_domain = 'soundtape'
    FastGettext.available_locales = ['en', 'pt_PT']
    @app.call(env)
  end
end