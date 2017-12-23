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
    notes_all = @stack.keys.sort { |x, y| y <=> x } \
                      .inject([]) { |arr, k| arr + [k] * @stack[k] }
    proposal = withdrawal_queue(amount, notes_all) \
               .each_with_object(Hash.new(0)) { |v, hsh| hsh[v] += 1 }

    return { status: 'Not enough notes to withdraw' } if proposal.empty?
    @stack.merge!(proposal) { |_key, v1, v2| v1 - v2 }
    { status: 'OK', set: proposal }
  end

  def withdrawal_queue(amount, notes)
    #puts "Need:#{amount.to_s} Have:#{notes.sum} => #{notes.to_s}"
    return [] if notes.sum < amount
      notes.each_with_index do |note, i|
        amount_ = amount - note
        return [note] if amount_.zero?
        next if amount_ < 0
        stack_ = notes.values_at(0...i, (i + 1)..-1)
        notes_ = [note] + withdrawal_queue(amount_, stack_)
        return notes_ if notes_.sum == amount
      end
  end
end
