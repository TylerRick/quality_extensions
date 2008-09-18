#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
#++

require 'enumerator'
module Enumerable

  # The core Enumerable module provides the following enumerator methods;
  # * <tt>enum_cons()</tt>
  # * <tt>enum_slice()</tt>
  # * <tt>enum_with_index()</tt>
  # but for some reason they didn't provide a generic <tt>enum()</tt> method for the cases they didn't think of!
  #
  # +enum+ lets you turn *any* iterator into a general-purpose <tt>Enumerator</tt>, which, according to the RDocs, is 
  # "A class which provides a method `<tt>each</tt>' to be used as an <tt>Enumerable</tt> object."
  #
  # This lets you turn any '<tt>each'-type</tt> iterator (<tt>each_byte</tt>, <tt>each_line</tt>, ...) into a
  # '<tt>map</tt>'-type iterator (one that returns a collection), or into an array, etc.
  #
  # So if an object responds to <tt>:each_line</tt> but not to <tt>:map_lines</tt> or <tt>:lines</tt>, you could just do:
  #   object.enum(:each_line).map { block }
  #   object.enum(:each_line).min
  #   object.enum(:each_line).grep /pattern/
  #   lines = object.enum(:each_line).to_a
  #
  # If no iterator is specified, <tt>:each</tt> is assumed:
  #   object.enum.map { block }
  #
  # More examples:
  #   Dir.new('.').enum.to_a
  #   #=> ['file1', 'file2']
  #
  #   "abc".enum(:each_byte).map{|byte| byte.chr.upcase}
  #   #=> ["A", "B", "C"]
  #   
  def enum(iterator = :each)
    Enumerable::Enumerator.new(self, iterator)
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
#    @options.enum(:each).map { |key, value|
#      values = [value].flatten
#      key +
#        (values.empty? ? " #{flatten.join(' ')}" : '')
#    }.join(' ')

    # Yes we could use the built-in Array#map method, but...not every class that provides iterators (each, ...) provides a map().
    assert_equal ['A', 'B', 'C'], ['a', 'b', 'c'].enum(:each).map {|v| v.upcase}
  end
  def test_2
    assert Dir.new('.').enum.to_a.size > 0
  end
end
=end
