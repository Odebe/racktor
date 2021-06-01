require 'yaml'

r = Ractor.new do
  loop do
    a = Ractor.receive
    puts a.inspect
    puts YAML.load(a)
  end
end

class Actor < Ractor
  def self.new()
    super() do
      yield
    end
  end
end

class A
  def initialize
    @aaa = 1
    @aab = [1,2,3]
  end
end

a = A.new

begin
  puts "#send #{a}: "
  r.send(YAML.dump(a), move: true)
  puts 'done'
rescue => e
  puts e.message
end

puts "end"

sleep
