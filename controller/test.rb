
require 'rubygems'
#require '../helper/exceptions'
require '../helper/image_resize'

module Teste
  OPT = 10
  opt =10
end

class Person
  include Teste
  def output
    puts OPT
  end
end

#t = Person.new
#t.output

#puts Teste.constants

#puts Teste.opt
#r = SoundTape::Helper::ImageResize.new('/home')
#r.extend(SoundTape::Helper::ImageResize::ImageScience)
#r.resize('dede', 1, 1

puts "rui"[/^[a-z0-9]+$/]