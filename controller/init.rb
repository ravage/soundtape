# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '/master'
  helper :xhtml
  engine :Erubis
end

# Here go your requires for subclasses of Controller:
require 'controller/main'
require 'controller/account'
require 'controller/profile'