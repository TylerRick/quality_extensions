#--
# Author::    vinterbleg <http://snippets.dzone.com/posts/show/5119>, Tyler Rick
# Copyright:: Copyright (c) Its authors.
# License::   Ruby License
# Submit to Facets?:: Yes. facets/enumerable/collect.rb only has non-in-place version (map_with_index).
# Developer notes::
# * No longer needed in Ruby 1.9.1:
#   a.to_enum(:map!).with_index
# Changes::
#++

module Enumerable
  def map_with_index!
    each_with_index do |e, i|
      self[i] = yield(e, i)
    end
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
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

class NonInPlaceTest < Test::Unit::TestCase
  def test_1
    array = ['a', 'b']
    after = array.map_with_index do |e, i|
      e.upcase + array[i+1].to_s
    end
    assert_equal ['Ab', 'B'], after
    assert_equal ['a', 'b'], array
  end
end

class InPlaceTest < Test::Unit::TestCase
  def test_1
    array = ['a', 'b']
    after = array.map_with_index! do |e, i|
      e.upcase + array[i+1].to_s
    end
    assert_equal ['Ab', 'B'], after
    assert_equal after, array
  end
end
=end


