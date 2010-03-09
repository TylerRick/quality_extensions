#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++

require 'matrix'

class Matrix
  #
  # Changes element (+i+,+j+) of the matrix. (That is: row +i+, column +j+.)
  #
  def []=(i, j, new)
    @rows[i][j] = new
  end
end

class Vector
  #
  # Changes element number +i+ (starting at zero) of the vector.
  #
  def []=(i, new)
    @elements[i] = new
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

describe 'Vector' do
  it '#[]=' do
    v = Vector[1, 2]
    v[0] = 10
    v.should == Vector[10, 2]
  end

  it 'Chanhing vector returned by Matrix#column by using Vector#[]= will not change the values in the Matrix' do
    m = Matrix[['a', 'b'], ['c', 'd']]

    v = m.column(0)
    v[1] = 'new'
    v.should           == Vector['a', 'new']
    m.column(0).should == Vector['a', 'c']   # []= only changes the vector

    m.column(0)[1].replace 'new'             # changes the string object itself, which both vector and matrix share
    m.column(0).should == Vector['a', 'new']
    m.column(0).should == Vector['a', 'new']
  end
end
=end

