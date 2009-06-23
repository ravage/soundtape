# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  helper :aspect
  layout :master
  map_layouts '/'
  engine :Erubis
  

  def self.action_missing(path)
    try_resolve('/lost')
  end
  
  def lost
    render_view(action.name){|action| action.view = 'view/lost.rhtml' }
  end
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/account'
require 'controller/profile'
require 'controller/settings'
require 'controller/agenda'
require 'controller/discography'
require 'controller/api'
require 'controller/user'
require 'controller/band'