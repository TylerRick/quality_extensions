#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Not sure.
#++

# Depends on some niceties from ActiveSupport (which really should be in core Ruby but aren't)... Date.new(a, b, c)
require "rubygems"
require "active_support"

# Attempts in part to make the Date class do everything (or at least some of the things) that the Time class can do (ActiveSupport::CoreExtensions::Time::Calculations).
# Maybe that would be better accomplished with a method_missing() that calls to_time.send(:the_same_method) if Time.respond_to?(:that_method).
class Date

  # This is based on the implementation of Time.step. The main difference is that it uses 
  # >>= (increment by 1 month) instead of += (increment by 1 day).
  def month_step(max, step, &block)  # { |date| ...}
    time = self
    op = [:-,:<=,:>=][step<=>0]
    while time.__send__(op, max)
      block.call time
      time >>= step
    end
    self
  end

  # Step forward one month at a time until we reach max (inclusive), yielding each date as we go
  def months_upto(max, &block)  # { |date| ...}
    month_step(max, +1, &block)
  end

  def to_month
    Month.new(year, month)
  end

  def next_month
    # Uses http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Time/Calculations.html#M000336
    self.to_time.next_month
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

  #-------------------------------------------------------------------------------------------------
  # Ranges, step, and upto for *days*
  # (This is built-in behavior.)

  def test_step
    list = []
    collect_as_array = lambda do |date|
      list << date
    end

    list = []
    Date.new(2006, 6, 1).step(Date.new(2006, 6, 3), 1, &collect_as_array)
    assert_equal [
        Date.new(2006, 6, 1), 
        Date.new(2006, 6, 2), 
        Date.new(2006, 6, 3)
      ], 
      list
  end

  def test_range
    list = Date.new(2006, 6, 1)..Date.new(2006, 6, 3)
    assert_equal Range.new(Date.new(2006, 6, 1), Date.new(2006, 6, 3)), list
  end

  #-------------------------------------------------------------------------------------------------
  # Ranges, step, and upto for *months*
  
  def test_month_step
    list = []
    collect_as_array = lambda do |date|
      list << date
    end

    list = []
    Date.new(2006, 6, 1).month_step(Date.new(2006, 7, 1), 1, &collect_as_array)
    assert_equal [
        Date.new(2006, 6, 1), 
        Date.new(2006, 7, 1)
      ], 
      list

    # Test that it ignores days
    list = []
    Date.new(2006, 6, 1).month_step(Date.new(2006, 8, 31), 1, &collect_as_array)
    assert_equal [
        Date.new(2006, 6, 1), 
        Date.new(2006, 7, 1),
        Date.new(2006, 8, 1)
      ], 
      list
  end

  def test_months_upto
    list = []
    collect_as_array = lambda do |date|
      list << date
    end

    list = []
    Date.new(2006, 6, 1).months_upto(Date.new(2006, 7, 1), &collect_as_array)
    assert_equal [
        Date.new(2006, 6, 1), 
        Date.new(2006, 7, 1)
      ], 
      list
  end
end
=end

