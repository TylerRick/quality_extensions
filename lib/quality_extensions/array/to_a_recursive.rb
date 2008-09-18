#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

class Array
  
  # A lot like array.flatten, except that it will also "flatten" ranges (by converting range to range.to_a) and any other objects that respond to to_a contained in the array in addition to arrays contained in the array.
  # Compare with Array#expand_ranges
  def to_a_recursive
    map do |item|
      # Assume that all arrays contain only elements that do not respond to to_a_recursive or arrays.
      if item.respond_to? :to_a_recursive
        item.to_a_recursive
      else
        item.to_a
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
  def test_1
    assert_equal [[1, 2, 3], [5, 6, 7]], [1..3, 5..7].to_a_recursive
  end
  def test_2
    assert_equal [[1, 2, 3], [ [5, 6, 7], [9, 10] ] ], [1..3, [5..7, 9..10]].to_a_recursive
  end
end
=end

