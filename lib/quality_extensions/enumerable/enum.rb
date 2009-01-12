#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Changes::
# * 2009-01-11 (Tyler):
#   * Changed Enumerable#enum so that it accepts any number of args and passes them on to Enumerator.new
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
  def enum(iterator = :each, *args)
    Enumerable::Enumerator.new(self, iterator, *args)
  end

end

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec'
require 'facets/kernel/require_local'
require_local 'every'

describe Enumerable do
  it "enum(:each) simple case" do
    # Yes we could use the built-in Array#map method in this case, but not every class that provides iterators (each, ...) provides a map().
    ['a', 'b', 'c'].enum(:each).map {|v| v.upcase}.should == ['A', 'B', 'C']
  end

  it "using enum on a Dir object" do
    Dir.new('.').enum.to_a.size.should > 0
  end

  it "can be used with iterator methods that require arguments" do
    (1..6).enum(:every, 2).map(&:to_s).should == %w[1 3 5]
  end
end
=end
