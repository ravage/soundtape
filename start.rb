require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
require 'gettext/cgi'
require 'digest/sha1'
require 'ramaze/contrib/email'

include GetText
set_output_charset("UTF-8")

Ramaze::EmailHelper.trait(
  :smtp_server      => 'mail.git.fragmentized.net',
  :smtp_helo_domain => "git.fragmentized.net",
  :smtp_username    => 'ravage@git.fragmentized.net',
  :smtp_password    => 'teste00',
  :sender_address   => 'ravage@fragmentized.net',
  :sender_full      => "#{_('SoundTape Staff')} <no-reply@soundtape.net>",
  :subject_prefix   => "[SoundTape]"
)
#DB = Sequel.sqlite('soundtape.db')
DB = Sequel.mysql('soundtape', 
  :user => 'root', 
  :password => 'root', 
  :host => 'localhost', 
  :socket => '/Applications/MAMP/tmp/mysql/mysql.sock', 
  :charset => 'utf8')
  
DB.loggers << Logger.new($stdout)

#$db = DBI.connect("DBI:sqlite3:soundtape.db")

require 'data/countries'  
# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
#require 'model/User'
Ramaze::acquire 'model/*'
Ramaze.start :adapter => :webrick, :port => 7000
