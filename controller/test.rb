class Teste
  attr_accessor :number
  
  def initialize(number)
    @number = number
  end
end

t = Teste.new(10)
puts t.number