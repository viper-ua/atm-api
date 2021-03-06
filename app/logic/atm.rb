require 'redis'

class ATM
  attr_reader :stack
  NOTES = [1, 2, 5, 10, 25, 50].freeze
  NOTES_REVERSED = [50, 25, 10, 5, 2, 1].freeze

  def initialize
    @redis = Redis.new
    @stack = { 1 => 0, 2 => 0, 5 => 0, 10 => 0, 25 => 0, 50 => 0 }
    return unless (atm_stack = @redis.hgetall('atm:stack'))
    load(atm_stack)
  end

  def load(load_stack = {})
    errors = {}
    load_stack.each do |k, v|
      k_, v_ = k.to_i, v.to_i
      if NOTES.include?(k_) && (v.is_a?(Integer) || v.is_a?(String)) && v_ > 0
        @stack[k_] += v_
      else
        errors.store(k, 'Invalid note')
      end
    end
    @redis.mapped_hmset('atm:stack', @stack)
    return { stack: @stack, status: errors } unless errors.empty?
    { stack: @stack, status: 'OK' }
  end

  def withdraw(amount)
    notes_all = NOTES_REVERSED.inject([]) { |arr, k| arr.concat(Array.new(@stack[k], k)) }
    proposal = withdrawal_queue(amount, notes_all) \
               .each_with_object(Hash.new(0)) { |v, hsh| hsh[v] += 1 }

    return { status: 'Not enough notes to withdraw' } if proposal.empty?
    @stack.merge!(proposal) { |_key, v1, v2| v1 - v2 }
    @redis.mapped_hmset('atm:stack', @stack)
    { status: 'OK', set: proposal }
  end

  def withdrawal_queue(amount, notes)
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
