#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
#++


module Enumerable
  # Returns an array containing all _consecutive_ elements of +enum+ for which +block+ is not false, starting at the first element.
  # So it is very much like select, only it stops searching as soon as <tt>block</tt> ceases to be true. (That means it will stop searching immediately if the first element doesn't match.)
  #
  # This might be preferable to +select+, for example, if:
  # * you have a very large collection of elements
  # * the desired elements are expected to all be consecutively occuring and are all at the beginning of the collection
  # * it would be costly to continue iterating all the way to the very end
  #
  # This is probably only useful for collections that have some kind of predictable ordering (such as Arrays).
  #
  # AKA: select_top_elements_that_match
  #
  def select_until(inclusive = false, &block)
    selected = []
    inclusive ? (
      each do |item|
        selected << item
        break if block.call(item)
      end
    ) : (
      each do |item|
        break if block.call(item)
        selected << item
      end
    )
    selected
  end

  def select_while(&block)
    selected = []
    each do |item|
      break if !block.call(item)
      selected << item
    end
    selected
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
    assert_equal [1, 2], (1..4).select_while {|i| i <= 2}
    assert_equal [1, 2], (1..4).select_until {|i| i == 3}
  end

  def test_not_same_as_select
    # Ah, yes, it behaves the same as select in *this* simple case:
    assert_equal [1, 2], (1..4).select {|i| i <= 2}

    # But what about _this_ one... hmm?
    assert_equal [1, 2],       [1, 2, 3, 2, 1].select_while {|i| i <= 2}
    assert_equal [1, 2, 2, 1], [1, 2, 3, 2, 1].select {|i| i <= 2}          # Not the same! Keyword: _consecutive_.

    # Or _this_ one...
    assert_equal [1, 2, 1],  [1, 2, 1, 99, 2].select_while {|i| i <= 2}
    assert_equal [1, 2],     [1, 2, 1, 99, 2].select {|i| i <= 2}.uniq    # Even this isn't the same.
  end

  def test_inclusive_option
    assert_equal [
      'def cabbage',
      '  :cabbage',
    ], [
      'def cabbage',
      '  :cabbage',
      'end',
    ].select_until {|line| line =~ /end/}
    # Not far enough. We actually want to *include* that last element.

    assert_equal [
      'def cabbage',
      '  :cabbage',
      'end',
    ], [
      'def cabbage',
      '  :cabbage',
      'end',
      'def carrot',
      '  :carrot',
      'end',
    ].select_until(true) {|line| line =~ /end/}
  end
end
=end


