#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#   Wait, so Facets has mode (http://facets.rubyforge.org/src/doc/rdoc/classes/Enumerable.html#M001253) but it doesn't have mean/average?
#   Whether or not this Array#average is included, Facets ought to have an Enumerable#mean/average similar to mode that uses each iterator rather than Array#size. (Still might want to keep this version if it's more efficient for Arrays?)
#++

class Array
  # Calculates the arithmetic average (mean) of the elements in the array as a <tt>Float</tt>.
  #   irb -> [1, 3, 3].average
  #       => 2.33333333333333
  def mean
    if self.size == 0
      raise ZeroDivisionError
    end
    self.inject(0.0) do |sum, item|
      sum + item.to_f
    end / self.size
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
  def test_average
    assert_equal 2, [0, 4].average
    assert_equal Float, [0, 4].average.class

    assert_equal 2.5, [0, 5].average

    assert_raise ZeroDivisionError do
      [].average
    end
  end
end
=end
