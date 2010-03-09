#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby license
# Submit to Facets?::
# Developer notes::
#   This was started back when I was under the impression that Matrix wouldn't work with 
#   non-numerical elements. I was prepared to fork Matrix to make it work better with
#   strings and such. But it seems like Matrix works fine with string elements.
#
#   I added matrix/indexable.rb and matrix/linked_vectors.rb to make working with Matrixes
#   more enjoyable. And now it looks like I won't have to create a Table class to compete
#   with Matrix after all!
# Changes::
#++

=begin notes
 > Matrix[['a', 'b'], ['c', 'd']].column(0)
=> Vector["a", "c"]

 > Matrix[['a', 'b'], ['c', 'd']].t.row(0)
=> Vector["a", "c"]

 > Matrix[['a', 'b'], ['c', 'd']].row(0)
=> Vector["a", "b"]



NArray has nice slice and pretty print features that are worth copying.

 > NArray[['a', 'b'], ['c', 'd']][0..1,0..1]
=> NArray.object(2,2): 
[ [ "a", "b" ], 
  [ "c", "d" ] ]

 > NArray[['a', 'b'], ['c', 'd']][0..1,1]
=> NArray.object(2): 
[ "c", "d" ]

 > NArray[['a', 'b'], ['c', 'd']].transpose
=> NArray.object(2,2): 
[ [ "a", "b" ], 
  [ "c", "d" ] ]
=end


require 'delegate'

# A table is...
class Table < DelegateClass(::Array)
  include Enumerable

  def self.[](*args)
    Table.new(*args)
  end

  # See /usr/lib/ruby/1.8/matrix.rb
  # Creates a table using rows as an array of row arrays. 
  def self.rows(rows)
  end

  # Creates a table using columns as an array of column arrays. 
  def self.columns(columns)
  end

  def self.superclass; Array; end

  def initialize(*args)
    pp args
    @rows = super(args)
    #super(@rows = Array.new(*args))
  end

  def +(other)
    # should work for tables of strings too
  end

end

#module Kernel
#  def Table(*args)
#    Table.new(*args)
#  end
#end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec'
require 'pp'

describe Table do
  it 'thinks it is a subclass of Array' do
    Table.superclass.should == Array
    #(Array === Table.new).should == true
  end

  describe 'initialization' do
    it '' do
      Table[[1,2],[3,4]].to_a.should == [[1,2],[3,4]]
    end
    it '' do
      Table.new([1,2],[3,4]).to_a.should == [[1,2],[3,4]]
      #Table.new([[1,2],[3,4]]).to_a.should == [[1,2],[3,4]]
    end
  end

end
=end


