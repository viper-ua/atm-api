require_relative 'atm'

  a = ATM.new
  puts a.load( 1 => 7, 2 => 50, 10 => 7, 25 => 3, 50 => 1 )
  puts a.withdraw(300)

