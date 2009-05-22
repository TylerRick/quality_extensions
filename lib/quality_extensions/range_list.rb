#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++

require 'delegate'
require 'facets/kernel/silence'

module Kernel
  def RangeList(*args)
    RangeList.new(*args)
  end
end

# A RangeList is a mixed array of numbers and ranges.
#
# It can be used to to represent "discontiguous ranges" (something a single Range object cannot do, unfortunately), for example [1..3, 5, 7..9],
#
#   RangeList([1..3, 5, 7..9]).to_a
#   => [1, 2, 3, 5, 6, 7]
#
# A RangeList acts like a range:
# * iterators like each will yield each element from a range (expanding them to the array of elements they represent) rather than the range itself
#   RangeList([1..2, 4]).map {|e| e} # => [1, 2, 4]
# * to_a expands any ranges in the RangeList using expand_ranges and returns a simple array composed of its atomic elements and elements from the expanded ranges
#
# In every other respect, however, a RangeList behaves like a range.
#
class RangeList < DelegateClass(::Array)
  include Enumerable

  class FormatError < StandardError; end

  def initialize(*args)
    if args.size == 1 and args[0].is_a?(Range)
      super(@array = [args[0]])
    else
      super(@array = Array.new(*args))
    end
  end

  def self.superclass; Array; end
#  def ===(a)
#    p a.class
#  end

  def to_range_list
    self
  end

  # Converts to a normal array, expanding all Ranges contained in this array, replacing the range with the list of *elements* that the range represents (range.+to_a+) .
  #
  def expand_ranges
    new_array = []
    @array.each do |item|
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
  alias_method :to_a, :expand_ranges

  def each
    expand_ranges.each { |element| yield element }
  end
end


class String

  #Range_list_item_format = /(\d+)(-(\d+))?/  # if only - is allowed as delimiter within a range
  Range_list_item_format = /(\d+)((-|\.\.|\.\.\.)(\d+))?/
  Range_list_format = /^#{Range_list_item_format}(,#{Range_list_item_format})*$/

  # A "range list" is an array of numbers and ranges, for example [1..3, 5, 7..9], and is a way to represent "discontiguous ranges" (something a single Range object cannot do, unfortunately).
  #
  # See also: Array#expand_ranges
  #
  # Name: to_range_list? parse_range_list?
  #
  # To do:
  # * Allow other format styles besides a-b and a..b and a...b : (a,b), [a,b], [a,b)
  # * Allow indeterminate ranges like '7-' (7 to infinity)?
  #
  def to_range_list
    raise RangeList::FormatError unless match(Range_list_format)
    array = split(',')
    array.map! {|e|
      md = e.match(/^#{Range_list_item_format}$/)
      range_type = md[3]
      points = [md[1], md[4]].compact.map(&:to_i)
      case points.size
      when 1
        points[0]
      when 2
        case range_type
        when '...'
          points[0] ... points[1]
        when '-', '..'
          points[0] .. points[1]
        else
          raise "Unexpected range_type #{range_type}"
        end
      end
    }
    array.to_range_list
  end
end


class Array
  def to_range_list
    RangeList.new(self)
  end

  # Converts array to a RangeList and expands all Ranges contained in this array, replacing the range with the list of *elements* that the range represents (range.+to_a+) .
  #
  def expand_ranges
    to_range_list.expand_ranges
  end

#  def self.===(other)
#    other.is_a?(RangeList) || super
#  end
end





#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec'

describe RangeList do
  it 'thinks it is a subclass of Array' do
    RangeList.superclass.should == Array
    #(Array === RangeList.new).should == true
  end

  it 'you can use RangeList() as an alias for RangeList.new()' do
    RangeList([1,2..3]).to_a.should == [1,2,3]
  end

  it '#to_a expands ranges to their respective elements' do
    RangeList.new([1,2..3]). to_a.should == [1,2,3]
    RangeList.new([1,2...3]).to_a.should == [1,2]
  end

  it 'behaves like an Array: <<, concat, ...' do
    array = RangeList.new
    array << (1..2)
    array.concat [3..4]
    array.push 9
    array.should == [1..2, 3..4, 9]
  end

  it 'behaves like a Range: iterators yield elements from expanded ranges rather than ranges themselves' do
    RangeList(1..2).enum_for(:each).to_a.should == [1,2]

    RangeList([1..3, 5, 7..9]).enum_for(:each).to_a.should ==
    RangeList([1..3, 5, 7..9]).to_a

    RangeList(1..2).enum_for(:each).to_a.should == [1,2]

    RangeList([1..2, 4]).map {|e| e}.should == [1, 2, 4]
  end
end

describe 'String#to_range_list' do
  it 'works when you simply have a number' do
    "1".to_range_list.should == [1]
  end

  it 'works when you simply have a list of numbers' do
    "1,2".to_range_list.should == [1,2]
  end

  it 'works when you throw in a range' do
    "1,2-3".  to_range_list.should == [1,2..3]
    "1,2..3". to_range_list.should == [1,2..3]
    "1,2...3".to_range_list.should == [1,2...3]
  end

  it 'works even for the complicatedest range list you can think up' do
    "1..3,5,7...9,11-12".  to_range_list.should == [1..3,5,7...9,11..12]
  end
end

describe 'Array#to_range_list' do
  it 'works' do
    [].to_range_list.should be_instance_of(RangeList)
    [1..3,5,7...9,11..12].  to_range_list.should == [1..3,5,7...9,11..12]
    [1..3,5,7...9,11..12].  to_range_list.should be_instance_of RangeList
  end
end

describe 'Array#expand_ranges' do
  it 'works' do
    [].expand_ranges.should be_instance_of(Array)
    [1, 2, 3].     expand_ranges.should == [1, 2, 3]
    [1..3].        expand_ranges.should == [1, 2, 3]
    [1..3, 5..7].  expand_ranges.should == [1, 2, 3, 5, 6, 7]
  end
end

=end

