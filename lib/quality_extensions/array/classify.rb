#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes:
# * This is the analog in Array to Set#classify (core).
# * Compare to Array#group_by (quality_extensions), which assumes all elements are arrays (making a "table") and only
#   allows you to do simple classification by the value of a "column". On the other hand, it adds the option to delete that
#   column from the array, which can be nice, since the classification key in the hash makes it somewhat redundant.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
gem 'facets'
require 'facets/to_hash'
class Array

=begin rdoc
   Classifies the array by the return value of the given block and returns a hash of {value => array of elements} pairs.
   The block is called once for each element of the array, passing the element as parameter.

   Breaks an array into a hash of smaller arrays, making a new group for each unique value returned by the block. Each unique value becomes a key in the hash.

   Example:
      [
        ['a', 1],
        ['a', 2],
        ['b', 3],
        ['b', 4],
      ].classify {|o| o[0]}
    =>  
      {
        "a" => [['a', 1], ['a', 2]], 
        "b" => [['b', 3], ['b', 4]]
      }
=end
  def classify(&block)
    hash = {}
    each do |element|
      classification = yield(element)
      (hash[classification] ||= []) << element
    end
    hash
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
require 'set'

class TheTest < Test::Unit::TestCase
  def test_classify
    input = [
      ['a', 1],
      ['a', 2],
      ['b', 3],
      ['b', 4],
    ]
    assert_equal({
        "a" => [['a', 1], ['a', 2]], 
        "b" => [['b', 3], ['b', 4]]
      }, input.classify {|o| o[0]}
    )
    # For comparison:
    assert_equal({
        "a" => Set[['a', 1], ['a', 2]], 
        "b" => Set[['b', 3], ['b', 4]]
      }, input.to_set.classify {|o| o[0]}
    )


    input = [
      ['Bob', "Bottle of water", 1.00],
      ['Bob', "Expensive stapler", 50.00],
      ['Alice', "Dinner for 2", 100.00],
      ['Alice', "Bus ride to RubyConf", 50.00],
    ]
    assert_equal({
        "Alice" => [['Alice',"Dinner for 2", 100.0], ['Alice', "Bus ride to RubyConf", 50.0]],
        "Bob"   => [['Bob', "Bottle of water", 1.0], ['Bob', "Expensive stapler", 50.0]]
      }, input.classify {|o| o[0]}
    )
    assert_equal({
        50.0  => [["Bob", "Expensive stapler", 50.00], ["Alice", "Bus ride to RubyConf", 50.00]],
        100.0 => [["Alice", "Dinner for 2", 100.00]],
        1.0   => [["Bob", "Bottle of water", 1.00]]
      }, input.classify {|o| o[2]}
    )
  end
end
=end

