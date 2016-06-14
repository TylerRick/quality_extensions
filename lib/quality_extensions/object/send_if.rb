#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# * The name of this method maybe ought to be a little more specific. What does anyone else think?
#   * It should say something about the fact that it the message sending is conditional but the block execution is unconditional.
#   * always_execute_block_but_only_send_message_if ? Hmm... a bit too verbose, perhaps.
#   * conditional_passthrough ?
#   * passthrough_unless ?
#   * use_wrapper_method_if ?
#   * Or just leave it how it is because all the alternatives are too long...
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
gem 'facets'
require 'facets/kernel/with'       # returning

class Object
  # Sends +message+ to +self+ (including +block_to_always_execute+ if supplied) if +condition+ is met. If +condition+ is _not_ met,
  # +block_to_always_execute+ will still be called (if supplied), but we will _not_ pass the message. (If +condition+ is not met
  # and +block_to_always_execute+ is not supplied, it will simply return +self+.)
  #
  # In summary:
  # * +block+: _always_ executed
  # * +message+: only sent if +condition+
  #
  # If a block (+block_to_always_execute+) is supplied, it is passed on to the message if the condition is met; (otherwise it is
  # simply called without sending the message).
  #
  # This is useful if you want to wrap a block with some method but you only want the method itself to be used some of the time.
  # For example, if it's for benchmarking, you may only want to enable it during development but disable during production to save on some overhead.
  #
  # Note: this cannot be used to call methods that expect blocks (Ruby 1.9 maybe?)
  #
  def send_if(condition, message, *args, &block_to_always_execute)
      if condition
        self.__send__(message, *args, &block_to_always_execute)
      else
        if block_given?
          block_to_always_execute.call
        else
          self
        end
      end
  end

  # Opposite of send_if
  def send_unless(condition, *args, &block)
    self.send_if(!condition, *args, &block)
  end

  # Lets you reduce duplication a little bit. Can do this:
  #   @foo.send_if_true(color)
  # instead of this:
  #   @foo.send_if(color, color)
  #
  def send_if_true(condition, *args, &block)
    self.send_if(condition, condition, *args, &block)
  end
end







#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

class Foo
  attr_reader :called_benchmark
  def benchmark(&block)
    @called_benchmark = true
    yield
    sleep 0.1     # Simulate lots of overhead, which we may want to avoid if we can help it
  end
end
class String
  def pink
    "#{self} (in pink)"
  end
end

class TheTest < Test::Unit::TestCase
  def setup
    @foo = Foo.new
    @string = 'food'
  end

  def test_send_if_with_true_condition
    executed_block = false
    @foo.send_if(true, :benchmark) do
      executed_block = true
    end
    assert executed_block
    assert @foo.called_benchmark
  end

  def test_send_if_with_false_condition
    executed_block = false
    @foo.send_if(false, :benchmark) do
      executed_block = true
    end
    assert executed_block
    assert !@foo.called_benchmark
  end

  def test_send_if_with_no_block
    color = nil
    returned = @string.send_if(color, color)
    assert_equal 'food', @string
    assert_equal @string, returned

    color = :pink
    returned = @string.send_if(color, color)
    assert_equal 'food', @string    # @string itself should be unchanged, but the return value should be be a modified form of @string
    assert_equal "#{@string} (in pink)", returned
  end
  def test_send_if_true_with_no_block
    color = nil
    returned = @string.send_if_true(color)
    assert_equal 'food', @string
    assert_equal @string, returned

    color = :pink
    returned = @string.send_if_true(color)
    assert_equal 'food', @string
    assert_equal "#{@string} (in pink)", returned
  end

  def test_send_unless
    executed_block = false
    @foo.send_unless(false, :benchmark) do
      executed_block = true
    end
    assert executed_block
    assert @foo.called_benchmark
  end

end
=end

