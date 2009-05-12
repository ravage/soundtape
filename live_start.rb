require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
require 'gettext'
require 'digest/sha1'
require 'ramaze/contrib/email'
require 'image_science'
require 'json/ext'

include GetText
#bindtextdomain('soundtape', :path => 'locale')
#Locale.clear_all
#Locale.default = "en"
#puts Ramaze::Global.public_root
#pp Ramaze.options.roots
Ramaze.options.cache.default = Ramaze::Cache::MemCache
Ramaze.options.session.secure = true;
Ramaze.options.session.ttl = 86400;

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
#Ramaze.start :adapter => :webrick, :port => 7000

