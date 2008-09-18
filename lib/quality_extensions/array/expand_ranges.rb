#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/kernel/silence'

class Array
  # Expands (calls +to_a+ on) all Ranges contained in this array, replacing the range with the list of *elements* that the range represents.
  #
  # This is especially useful when you want to have "discontiguous ranges" like [1..3, 5..7]...
  #
  #   [1..3, 5..7].expand_ranges
  #   => [1, 2, 3, 5, 6, 7]
  #
  def expand_ranges
    new_array = []
    each do |item|
      silence_warnings do             # Object.to_a: warning: default `to_a' will be obsolete
        if item.respond_to?(:to_a)
          new_array.concat item.to_a
        else
          new_array.concat [item]
        end
      end
    end
    new_array
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
    assert_equal [1, 2, 3], [1, 2, 3].expand_ranges
  end
  def test_2
    assert_equal [1, 2, 3], [1..3].expand_ranges
    assert_equal [1, 2, 3, 5, 6, 7], [1..3, 5..7].expand_ranges
  end
end
=end

