#--
# Author::    Nolan Cafferky
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

require 'thread'
class Mutex
  # Acts like synchronize, except that if the lock cannot be acquired immediately,
  # the program continues without executing the given block.
  #
  # ==Example:
  #
  #   mutex = Mutex.new
  #   # ...
  #   mutex.if_available do
  #     # Some process that we only want one thread to be running at a time,
  #     # and we don't mind skipping if some other thread is already doing it.
  #     loop do
  #       notify_mechanics if danger_to_teh_manifold!
  #       sleep 60
  #     end
  #   end
  def if_available
    if try_lock
      begin
        yield
      ensure
        unlock
      end
    end
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

class TheTest < Test::Unit::TestCase
  def setup
    @semaphore = Mutex.new
  end

  def teardown
  end

  def test_executes_if_lock_is_available
    i_ran = nil

    @semaphore.if_available do
      i_ran = true
    end

    assert i_ran
  end

  def test_continues_if_lock_is_unavailable
    i_ran = nil

    @semaphore.lock
    @semaphore.if_available do
      i_ran = true
    end
    @semaphore.unlock

    assert_nil i_ran
  end
end
=end
