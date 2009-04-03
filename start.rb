require 'rubygems'
require 'ramaze'
require 'sequel'
require 'logger'
#DB = Sequel.sqlite('soundtape.db')

DB = Sequel.mysql('soundtape', :user => 'root', :password => 'root', :host => 'localhost')
DB.loggers << Logger.new($stdout)

require 'data/countries'  
# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
require 'controller/init'
require 'model/User'
Ramaze::acquire 'model/*'

Ramaze.start :adapter => :webrick, :port => 7000
