class ATM
  attr_reader :stack

  def initialize
    @stack = { 1 => 0, 2 => 0, 5 => 0, 10 => 0, 25 => 0, 50 => 0 }
  end

  def load(load_stack = {})
    errors = {}
    load_stack.each do |k, v|
      if @stack.keys.include?(k.to_i)
        @stack[k.to_i] += v
      else
        errors.store(k, 'Invalid note')
      end
    end
    return { stack: @stack, status: errors } unless errors.empty?
    { stack: @stack, status: 'OK' }
  end

  def withdraw(amount)
    proposed_sum = 0
    proposal = withdraw_from(amount, @stack)
    proposal.each { |k, v| proposed_sum += k * v }
    if proposed_sum == amount
      @stack.merge!(proposal) { |_key, v1, v2| v1 - v2 }
      return { status: 'OK', set: proposal }
    end
    { status: 'Not enough notes to withdraw', proposal: proposal }
  end

  def withdraw_from(amount, stack)
    withdraw_queue = {}
    return withdraw_queue if stack.empty?
    note = stack.keys.max
    can_get = stack[note].zero? ? 0 : [stack[note], amount / note].min
    stack_ = stack.reject { |k, _v| k == note }
    withdraw_queue.store(note, can_get) if can_get > 0
    amount_ = amount - note * can_get
    withdraw_queue.merge(withdraw_from(amount_, stack_))
  end
end
