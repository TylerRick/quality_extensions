#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Not sure. Who really cares about Months anyway?
# Developer notes::
# * Compare with http://rubyforge.org/projects/dateutils/. Merge/abandon?
#++

require "rubygems"
require "active_support"
require File.dirname(__FILE__) + "/date/all"

class Month
  include Comparable
  attr_reader :year, :month

  def initialize(year, month)
    @year = year
    @month = month
  end

  def succ
    (to_date >> 1).to_month
  end

  def to_date
    Date.new(year, month)
  end

  def <=>(other)
    #puts "#{self.inspect} <=> #{other.inspect}"
    return self.to_date <=> other.to_date
  end

  def inspect
    "#{@year}-#{@month}"
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
  def test_months_range
    range = Month.new(2006, 6)..Month.new(2006, 9)
    assert_equal Range.new(Month.new(2006, 6), Month.new(2006, 9)), range

    range = Date.new(2006, 6, 1).to_month..Date.new(2006, 9, 3).to_month
    assert_equal Range.new(Month.new(2006, 6), Month.new(2006, 9)), range

    assert_equal [
        Month.new(2006, 6), 
        Month.new(2006, 7), 
        Month.new(2006, 8), 
        Month.new(2006, 9)
      ], 
      range.to_a
  end
end
=end
