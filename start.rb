require 'rubygems'
require 'ramaze'
require 'sequel'

DB = Sequel.sqlite('soundtape.db')
# Add directory start.rb is in to the load path, so you can run the app from
# any other working path
$LOAD_PATH.unshift(__DIR__)

# Initialize controllers and models
Ramaze::acquire 'controller/*'
require 'model/User.rb'
Ramaze::acquire 'model/*'

Ramaze.start :adapter => :webrick, :port => 7000
