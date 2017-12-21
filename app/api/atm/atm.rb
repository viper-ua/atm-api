class ATM
	attr_reader :stack

  def initialize
    @stack = { 1 => 0 , 2 => 0, 5 => 0, 10 => 0, 25 => 0, 50 => 0 }
  end

  def load(load_stack = {})
    errors = {}
    load_stack.each do |k, v|
      if @stack.keys.include?(k.to_i)
        @stack[k.to_i] += v
      else
        errors.store(k, "Invalid note")
      end
    end
    return {stack: @stack, status: errors} if errors.size > 0
    {stack: @stack, status: 'OK'} 
  end

  def withdraw(amount)
    sum = 0
    proposal = withdraw_from(amount, @stack)
    proposal.each {|k,v| sum += k * v}
    if sum == amount
      @stack.merge!(proposal) { |key, v1, v2| v1 - v2 }
      return {status: 'OK', set: proposal}
    end 
    {status: "Not enough notes to withdraw", proposal: proposal}
  end

  def withdraw_from(amount, stack)
    withdraw_queue = {}
    if stack.length > 0 
      amount = amount.to_i
      note = stack.keys.max
      can_get = stack[note] > 0 ? amount / note : 0
      can_get = [stack[note], can_get].min
      stack_ = stack.reject {|k,v| k == note}
      withdraw_queue.store(note, can_get) if can_get > 0
      amount_ = amount - note * can_get
      withdraw_queue = withdraw_queue.merge(withdraw_from(amount_, stack_))
    end
    return withdraw_queue
  end
end
     