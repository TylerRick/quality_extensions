#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#   Wait, so Facets has mode (http://facets.rubyforge.org/src/doc/rdoc/classes/Enumerable.html#M001253) but it doesn't have mean/average?
#   Whether or not this Array#average is included, Facets ought to have an Enumerable#mean/average similar to mode that uses each iterator rather than Array#size. (Still might want to keep this version if it's more efficient for Arrays?)
#++

class Array
  def sum
    inject( nil ) { |sum,x| sum ? sum+x : x }
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
  def test_sum
    assert_equal 5, [2, 3].sum
  end
end
=end
