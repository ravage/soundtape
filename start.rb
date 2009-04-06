require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
require 'gettext/cgi'
require 'digest/sha1'
include GetText
set_output_charset("UTF-8")
#DB = Sequel.sqlite('soundtape.db')
puts _('aaaaa')
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
