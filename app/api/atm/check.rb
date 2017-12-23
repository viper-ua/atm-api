require_relative 'atm'

a = ATM.new
puts a.load(25 => 4, 50 => 3)
puts a.stack
puts a.withdraw(200)
puts a.stack
