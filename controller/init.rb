# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout :master
  map_layouts '/'
  engine :Erubis
  #layout(:master){|path, wish| wish !~ /rss|atom/ }
 
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/account'
require 'controller/profile'
require 'controller/settings'
require 'controller/agenda'
require 'controller/discography'
require 'controller/api'