begin
  require 'rere'
rescue LoadError => e
  puts 'Erro!'
end

require 'rubygems'
#require '../helper/exceptions'
require '../helper/image_resize'

#r = SoundTape::Helper::ImageResize.factory('/home', :library => 'rmagick')

#puts r.class

#r.resize('a', 1, 1)

#r.resize('dede', 10, 10)

def teste(a, opts = {})
  #puts opts.empty?
  puts :a
  require 'teste'
end


class Person
  protected
  
  def walk
    puts 'Person walking'
  end
end

class Man < Person
  
end

man = Man.new

puts man.walk