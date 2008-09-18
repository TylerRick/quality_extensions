#--
# Author::    Lance Ivy
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Not sure.
#++

class Array
=begin rdoc
  Returns the value previous to the given value. The value previous to the first is the last. Returns nil if the given value is not in the array.

  Example:
       sequence = ['a', 'b', 'c']
       sequence.before('a')           => 'c'
       sequence.before('b')           => 'a'
       sequence.before('c')           => 'b'
       sequence.before('d')           => nil
=end
  def before(value)
    return nil unless include? value
    self[(index(value).to_i - 1) % length]
  end

=begin rdoc
  Returns the value after the given value. The value before the last is the first. Returns nil if the given value is not in the array.

  Example:
       sequence = ['a', 'b', 'c']
       sequence.after('a')           => 'b'
       sequence.after('b')           => 'c'
       sequence.after('c')           => 'a'
       sequence.after('d')           => nil
=end
  def after(value)
    return nil unless include? value
    self[(index(value).to_i + 1) % length]
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
    @sequence = ['a', 'b', 'c']
  end

  def test_before
    assert_equal 'c', @sequence.before('a')
    assert_equal 'a', @sequence.before('b')
    assert_equal 'b', @sequence.before('c')
    assert_equal nil, @sequence.before('d')
  end

  def test_after
    assert_equal 'b', @sequence.after('a')
    assert_equal 'c', @sequence.after('b')
    assert_equal 'a', @sequence.after('c')
    assert_equal nil, @sequence.after('d')
  end
end
=end
