#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2008, Tyler Rick
# License::   Ruby license
# Submit to Facets?::
# Developer notes::
# Changes::
#++

# A histogram in this sense is an array of [value, frequency] pairs
class Histogram < Array

  # Histogram.new([[1,1], [2,2], [3,5]).flatten
  # =>             [1,     2,2,   3,3,3,3,3]
  def flatten
    array = []
    each do |value, frequency|
      array.concat [value]*frequency
    end
    array
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
  def test_initialize
    assert_equal [[1,1], [2,2], [3,5]],
                 Histogram.new([[1,1], [2,2], [3,5]])
  end

  def test_flatten
    assert_equal [1, 2,2, 3,3,3,3,3],
                 Histogram.new([[1,1], [2,2], [3,5]]).flatten
  end

end
=end


