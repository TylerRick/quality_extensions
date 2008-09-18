#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe. 
# Developer notes:
# * Name is too general? Name it something to do with 'tables'?
#   * group_table_by ?
# * Compare to Array#classify (quality_extensions), which aims to be more general, letting you classify arrays that are
#   *not* in "table" form (whose elements are *not* all arrays of equal size and might not even be *arrays*).
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
gem 'facets'
require 'facets/array/delete'
class Array

=begin rdoc
   Breaks an array into a hash of smaller arrays, making a new group for each unique value in the specified column.
   Each unique value becomes a key in the hash.

   Example:
        [
           ['a', 1],
           ['a', 2],
           ['b', 3],
           ['b', 4],
        ].group_by(0)
    =>  
        "a"=>[[1], [2]], 
        "b"=>[[3], [4]]

   Options:
   * <tt>delete_key</tt>: deletes the key from the corresponding array if true (default true)

   Example:
        [
           ['a', 1],
           ['a', 2],
           ['b', 3],
           ['b', 4],
        ].group_by(0, :delete_key => false)
    =>  
        "a"=>[['a', 1], ['a', 2]], 
        "b"=>[['b', 3], ['b', 4]]
   
   *Notes*:
   * <tt>self</tt> must be in the shape of a "table" (that is, a rectangular-shaped, two-dimensional array = an array of arrays,
     each member array being of the same size (the "width" of the table)).
   * This is different from the GROUP BY in SQL in that it doesn't apply an aggregate (like sum or average) to each group -- it just returns each group unmodified.

=end
  def group_by(column_index, *args)
    options = (if args.last.is_a?(Hash) then args.pop else {} end)
    hash = {}
    self.each do |row|
      row_to_keep = row.dup
      row_to_keep.delete_values_at(column_index) unless options[:delete_key] == false

      hash[row[column_index]] ||= []
      hash[row[column_index]] << row_to_keep
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
  def test_group_by
    assert_equal({ }, [ ].group_by(column_index = 0))

    assert_equal({
        "a"=>[[1], [2]], 
        "b"=>[[3], [4]]
      }, [
        ['a', 1],
        ['a', 2],
        ['b', 3],
        ['b', 4],
      ].group_by(column_index = 0)
    )



    assert_equal({
        "a"=>[['a', 1], ['a', 2]], 
        "b"=>[['b', 3], ['b', 4]]
      }, [
        ['a', 1],
        ['a', 2],
        ['b', 3],
        ['b', 4],
      ].group_by(column_index = 0, :delete_key => false)
    )
    assert_equal({
        "a" => Set[['a', 1], ['a', 2]], 
        "b" => Set[['b', 3], ['b', 4]]
      }, [
        ['a', 1],
        ['a', 2],
        ['b', 3],
        ['b', 4],
      ].to_set.classify {|o| o[0]}
    )


    input = [
      ['Bob', "Bottle of water", 1.00],
      ['Bob', "Expensive stapler", 50.00],
      ['Alice', "Dinner for 2", 100.00],
      ['Alice', "Bus ride to RubyConf", 50.00],
    ]
    assert_equal({
        "Alice"=>[["Dinner for 2", 100.0], ["Bus ride to RubyConf", 50.0]],
        "Bob"=>[["Bottle of water", 1.0], ["Expensive stapler", 50.0]]
      }, input.group_by(column_index = 0)
    )
    assert_equal({
        50.0=>[["Bob", "Expensive stapler"], ["Alice", "Bus ride to RubyConf"]],
        100.0=>[["Alice", "Dinner for 2"]],
        1.0=>[["Bob", "Bottle of water"]]
      }, input.group_by(column_index = 2)
    )
  end
end
=end
