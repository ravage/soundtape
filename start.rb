require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
require 'fast_gettext'
require 'digest/sha1'
require 'ramaze/contrib/email'
require 'image_science'
require 'json/ext'
require 'vendor/rfc822'
require 'feedzirra'
require 'middleware/locale'

FastGettext.add_text_domain('soundtape', :path => 'locale')

FastGettext.text_domain = 'soundtape'
FastGettext.available_locales = ['en', 'pt_PT']

include FastGettext::Translation
#bindtextdomain('soundtape', :path => 'locale')
#Locale.clear_all
#Locale.default = "en"
#puts Ramaze::Global.public_root
#pp Ramaze.options.roots

#Ramaze.options.session.secure = true;
Ramaze.options.session.ttl = 86400;
#Ramaze.options.session.domain = 'soundtape.net'


require 'options'

DB = Sequel.mysql(SoundTape.options.Database.name, 
  :user     => SoundTape.options.Database.login, 
  :password => SoundTape.options.Database.password, 
  :host     => SoundTape.options.Database.host, 
  :socket   => SoundTape.options.Database.socket, 
  :charset  => SoundTape.options.Database.charset)

Ramaze::Log.warn SoundTape.options.Email.host
Ramaze::EmailHelper.trait(
  :smtp_server      => SoundTape.options.Email.host,
  :smtp_helo_domain => SoundTape.options.Email.hello,
  :smtp_username    => SoundTape.options.Email.user,
  :smtp_password    => SoundTape.options.Email.password,
  :sender_full      => SoundTape.options.Email.from,
  :subject_prefix   => SoundTape.options.Email.prefix)


Sequel::Model.raise_on_save_failure = false
Sequel::Model.plugin(:validation_helpers)
DB.loggers << Logger.new('sql.output')

require 'data/countries'
require 'data/languages'
require 'data/currencies'
require 'data/months'
require 'data/categories'
# Initialize controllers and models
require 'controller/init'
require 'model/User'
require 'model/Language'
Ramaze::acquire 'model/*'

#match /user
#Ramaze::Route[%r{^(\w+)[^master|settings]$}] = "/profile/view/%s"
#match /user/agenda
#Ramaze::Route[%r{^/(.*)/agenda$}] = "/profile/agenda/%s"

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

Ramaze.middleware! :dev do |m|
 m.use Rack::Lint
 m.use Rack::CommonLogger, Ramaze::Log
 m.use Rack::ShowExceptions
 m.use Rack::ShowStatus
 m.use Rack::RouteExceptions
 m.use Rack::ContentLength
 m.use Rack::ConditionalGet
 m.use Rack::ETag
 m.use Rack::Head
 m.use Ramaze::Reloader
 m.use Locale
 m.run Ramaze::AppMap
end




Rack::RouteExceptions.route(/.*/, '/lost') if Ramaze.options.mode == :live
Ramaze.start :adapter => :webrick, :port => 7000

