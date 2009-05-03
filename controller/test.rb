require 'rubygems'
require 'json/ext'

class Person
  attr_accessor :name, :age, :contact
  
  def to_json(*a)
    {
      'json_class'  => self.class.name,
      :name        => @name,
      'age'         => @contact
    }.to_json(*a)
  end
end

p = Person.new

p.name = "Rui"
p.age = 15
p.contact = "x@x.com"

puts p.to_json