require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
require 'gettext/cgi'
require 'digest/sha1'
require 'ramaze/contrib/email'

include GetText
set_output_charset("UTF-8")

require 'options'

DB = Sequel.mysql(SoundTape::Database.name, 
  :user     => SoundTape::Database.login, 
  :password => SoundTape::Database.password, 
  :host     => SoundTape::Database.host, 
  :socket   => SoundTape::Database.socket, 
  :charset  => SoundTape::Database.charset)
  
Ramaze::EmailHelper.trait(
  :smtp_server      => SoundTape::Email.host,
  :smtp_helo_domain => SoundTape::Email.hello,
  :smtp_username    => SoundTape::Email.user,
  :smtp_password    => SoundTape::Email.password,
  :sender_full      => SoundTape::Email.from,
  :subject_prefix   => SoundTape::Email.prefix)
  
DB.loggers << Logger.new($stdout)

require 'data/countries'

# Initialize controllers and models
require 'controller/init'
require 'model/User'
Ramaze::acquire 'model/*'

#match /user
#Ramaze::Route[%r{^(\w+)[^master|settings]$}] = "/profile/view/%s"
#match /user/agenda
#Ramaze::Route[%r{^/(.*)/agenda$}] = "/profile/agenda/%s"

# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

Ramaze.start :adapter => :webrick, :port => 7000
