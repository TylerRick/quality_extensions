#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# User notes:: Only changes done via []= are currenly propagated back to the parent matrix!
# History::
#++

require 'matrix'
require File.dirname(__FILE__) + "/indexable"

# Idea: could also hide this functionality in a module which is then included as needed
#class Matrix
#  module VectorsLinkedToParentMatrix
#  end
#end

#---------------------------------------------------------------------------------------------------
class Matrix
  MatrixDetails = Struct.new(:matrix, :i)

  #
  # Returns row vector number +i+ of the matrix as a Vector (starting at 0 like
  # an array).  When a block is given, the elements of that vector are iterated.
  #
  def row(i) # :yield: e
    if block_given?
      for e in @rows[i]
        yield e
      end
    else
      # Because an array of rows happens to be the native internal format of a matrix, the only thing changed was passing copy = false instead of copy = true. Then the rows are passed by reference instead of dup'd and any changes made to them will automatically be made in the matrix as well.
      Vector.elements(@rows[i], false)
    end
  end

  #
  # Returns column vector number +j+ of the matrix as a Vector (starting at 0
  # like an array).  When a block is given, the elements of that vector are
  # iterated.
  #
  def column(j) # :yield: e
    if block_given?
      0.upto(row_size - 1) do
        |i|
        yield @rows[i][j]
      end
    else
      col = (0 .. row_size - 1).collect {
        |i|
        @rows[i][j]
      }
      # With column vectors, it's a bit trickier to link changes so they propagate to the matrix. The matrix doesn't natively store an array of column arrays. The column array constructed here is already a copy. So we pass the matrix by reference and the column number so that we can later use Matrix#[]= to propagate changes to the vector back to the matrix.
      Vector.elements(col, false, MatrixDetails.new(self, j))
    end
  end
end

class Vector
  #
  # Creates a vector from an Array.  The optional second argument specifies
  # whether the array itself or a copy is used internally.
  #
  def Vector.elements(array, copy = true, matrix_details = nil)
    new(:init_elements, array, copy, matrix_details)
  end
  
  #
  # For internal use.
  #
  def initialize(method, array, copy, matrix_details = nil)
    self.send(method, array, copy)
    @matrix_details = matrix_details
  end

  #
  # Updates element number +i+ (starting at zero) of the vector.
  #
  # If this vector is linked with (a row or column of) a matrix, it changes the corresponding element of that matrix too.
  #
  def []=(i, new)
    @elements[i] = new

    # Update linked matrix too
    if @matrix_details.respond_to? :matrix
      #puts "@matrix_details.matrix[#{i}, #{@matrix_details.i}] = #{new.inspect}"
      @matrix_details.matrix[i, @matrix_details.i] = new
    end
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

describe 'Matrix' do
  it '#[]=' do
    m = Matrix[['a', 'b'], ['c', 'd']]
    m[0, 0] = 'new'
    m.should == Matrix[['new', 'b'], ['c', 'd']]
  end
end

describe 'Changing vector returned by Matrix#column/row by using Vector#[]=' do
  it '#[]=' do
    v = Vector[1, 2]
    v[0] = 10
    v.should == Vector[10, 2]
  end

  it '(column) *will* change the values in the linked Matrix' do
    m = Matrix[['a', 'b'], ['c', 'd']]

    v = m.column(0)
    v[0] = 'new'
    v.should           == Vector['new', 'c']
    m.column(0).should == Vector['new', 'c']
  end

  it '(row) *will* change the values in the linked Matrix' do
    m = Matrix[['a', 'b'], ['c', 'd']]

    v = m.row(0)
    v[0] = 'new'
    v.should           == Vector['new', 'b']
    m.row(0).should    == Vector['new', 'b']
  end
end
=end

