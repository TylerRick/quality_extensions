#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
# To do::
#++

require 'rubygems'
require 'facets/kernel/deep_copy'
require File.dirname(__FILE__) + '/../vector/enumerable'
require File.dirname(__FILE__) + '/../matrix/linked_vectors'

class Array
  # In each column of a table (2-dimensional array) of strings, pads the string with +padstr+ (using ljust) so that all strings in that column have the same length.
  #
  #    [['a',   'bb'],
  #     ['aaa', 'b' ]].ljust_columns
  # => [['a  ', 'bb'],
  #     ['aaa', 'b ']]
  #
  # The new values in the table will be strings even if they were not originally (1 might turn into '1 ', for example).
  #
  def ljust_columns(padstr = ' ')
    new = self.deep_copy
    new.ljust_columns!(padstr)
    new
  end

  # Original version without using Matrix:
#  def ljust_columns!(padstr = ' ')
#    self[0].each_index do |c| 
#      max_length_in_col = max_by { |row|
#        row[c].to_s.length 
#      }[c].to_s.length
#      each { |row| 
#        row[c] = row[c].to_s.ljust(max_length_in_col, padstr)
#      }
#    end
#    self
#  end

  # In-place version of ljust_columns.
  #
  def ljust_columns!(padstr = ' ')
    matrix = Matrix[*self]
    matrix.column_vectors.each do |column| 
      max_length_in_col = column.max_by { |el|
        el.to_s.length 
      }.to_s.length
      column.each_with_index { |el, i| 
        column[i] = el.to_s.ljust(max_length_in_col, padstr)
      }
    end
    self
  end

  # In each row of a table (2-dimensional array) of strings, pads the string with +padstr+ (using ljust) so that all strings in that row have the same length.
  #
  #    [['a'  , 'aa' , 'a'  ],
  #     ['bbb', 'b'  , 'b'  ]].ljust_rows
  # => [['a ' , 'aa' , 'a ' ],
  #     ['bbb', 'b  ', 'b  ']]
  #
  # The new values in the table will be strings even if they were not originally (1 might turn into '1 ', for example).
  #
  def ljust_rows(padstr = ' ')
    new = self.deep_copy
    new.ljust_rows!(padstr)
    new
  end

  # Original version without using Matrix:
#  def ljust_rows!(padstr = ' ')
#    c_count = self[0].size  # We assume all rows have the same number of columns
#    self.each_index do |r|
#      max_length_in_row = 0.upto(c_count - 1).inject(0) { |memo, c|
#        [self[r][c].to_s.length, memo].max
#      }
#      0.upto(c_count - 1).each { |c| 
#        self[r][c] = self[r][c].to_s.ljust(max_length_in_row, padstr)
#      }
#    end
#    self
#  end

  # In-place version of ljust_rows.
  #
  def ljust_rows!(padstr = ' ')
    matrix = Matrix[*self]
    matrix.row_vectors.each do |row| 
      max_length_in_row = row.max_by { |el|
        el.to_s.length 
      }.to_s.length
      row.each_with_index { |el, i| 
        row[i] = el.to_s.ljust(max_length_in_row, padstr)
      }
    end
    self
  end

  #-------------------------------------------------------------------------------------------------
  # Maintenance note: rjust versions are simply copied and pasted with the substitution s/ljust/rjust/g applied and the descriptions and examples changed.

  # In each column of a table (2-dimensional array) of strings, pads the string with +padstr+ (using rjust) so that all strings in that column have the same length.
  #
  #    [[  'a', 'bb'],
  #     ['aaa',  'b']].rjust_columns
  # => [['  a', 'bb'],
  #     ['aaa', ' b']]
  #
  # The new values in the table will be strings even if they were not originally (1 might turn into '1 ', for example).
  #
  def rjust_columns(padstr = ' ')
    new = self.deep_copy
    new.rjust_columns!(padstr)
    new
  end

  # In-place version of rjust_columns.
  #
  def rjust_columns!(padstr = ' ')
    matrix = Matrix[*self]
    matrix.column_vectors.each do |column| 
      max_length_in_col = column.max_by { |el|
        el.to_s.length 
      }.to_s.length
      column.each_with_index { |el, i| 
        column[i] = el.to_s.rjust(max_length_in_col, padstr)
      }
    end
    self
  end

  # In each row of a table (2-dimensional array) of strings, pads the string with +padstr+ (using rjust) so that all strings in that row have the same length.
  #
  #    [[  'a',  'aa',   'a'],
  #     ['bbb',   'b',   'b']].rjust_rows
  # => [[ ' a',  'aa',  ' a'],
  #     ['bbb', '  b', '  b']]
  #
  # The new values in the table will be strings even if they were not originally (1 might turn into '1 ', for example).
  #
  def rjust_rows(padstr = ' ')
    new = self.deep_copy
    new.rjust_rows!(padstr)
    new
  end

  # In-place version of rjust_rows.
  #
  def rjust_rows!(padstr = ' ')
    matrix = Matrix[*self]
    matrix.row_vectors.each do |row| 
      max_length_in_row = row.max_by { |el|
        el.to_s.length 
      }.to_s.length
      row.each_with_index { |el, i| 
        row[i] = el.to_s.rjust(max_length_in_row, padstr)
      }
    end
    self
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
require 'pp'

describe 'Array.ljust_columns!' do
  before do
    @array =  [['a',   'bb', 'c'],
               ['aaa', 'b',  'c']]
    @array2 = [['a',   'bb'],
               ['aaa', 'b' ],
               ['a',   'b' ]]
  end

  it 'basic' do
    @array.ljust_columns!
    @array.should == [['a  ', 'bb', 'c'],
                      ['aaa', 'b ', 'c']]
  end

  it 'rotated' do
    @array2.ljust_columns!
    @array2.should == [['a  ', 'bb'],
                      ['aaa', 'b ' ],
                      ['a  ', 'b ' ]]
  end

  it 'with non-string receiver array' do
    @array = [[1, 2], [1, 22]]
    @array.ljust_columns!
    @array.should == [['1', '2 '], ['1', '22']]
  end

  it 'with different padding character' do
    @array.ljust_columns!('_')
    @array.should == [['a__', 'bb', 'c'],
                      ['aaa', 'b_', 'c']]
  end
end

describe 'Array.ljust_columns' do
  before do
    @array = [['a',   'bb', 'c'],
              ['aaa', 'b',  'c' ]]
  end

  it 'should not modify receiver array' do
    @array.should == [['a'  , 'bb', 'c'],
                      ['aaa', 'b' , 'c']]
    ret = @array.ljust_columns
    ret.should ==    [['a  ', 'bb', 'c'],
                      ['aaa', 'b ', 'c']]
    # Should not have modified @array
    @array.should == [['a'  , 'bb', 'c'],
                      ['aaa', 'b' , 'c']]
  end
end

describe 'Array.ljust_rows!' do
  before do
    @array =  [['a'  , 'aa', 'a'],
               ['bbb', 'b' , 'b']]
    @array2 = [['a'  , 'aa'],
               ['bbb', 'b' ],
               ['c'  , 'c' ]]
  end

  it 'basic' do
    @array.ljust_rows!
    @array.should == [['a ',  'aa',  'a ' ],
                      ['bbb', 'b  ', 'b  ']]
  end

  it 'rotated' do
    @array2.ljust_rows!
    @array2.should == [['a ' , 'aa' ],
                       ['bbb', 'b  '],
                       ['c'  , 'c'  ]]
  end

  it 'with non-string receiver array' do
    @array = [[1, 1], [2, 22]]
    @array.ljust_rows!
    @array.should == [['1', '1'], ['2 ', '22']]
  end

  it 'with different padding character' do
    @array.ljust_rows!('_')
    @array.should == [['a_',  'aa',  'a_' ],
                      ['bbb', 'b__', 'b__']]
  end
end

describe 'Array.ljust_rows' do
  before do
    @array =  [['a'  , 'aa', 'a'],
               ['bbb', 'b' , 'b']]
  end

  it 'should not modify receiver array' do
    @array.should ==  [['a'  , 'aa' , 'a'  ],
                       ['bbb', 'b'  , 'b'  ]]
    ret = @array.ljust_rows
    ret.should ==     [['a ' , 'aa' , 'a ' ],
                       ['bbb', 'b  ', 'b  ']]
    # Should not have modified @array
    @array.should ==  [['a'  , 'aa', 'a'],
                       ['bbb', 'b' , 'b']]
  end
end

#---------------------------------------------------------------------------------------------------

describe 'Array.rjust_rows' do
  before do
    @array =          [[  'a',  'aa',   'a'],
                       ['bbb',   'b',   'b']]
  end

  it 'should not modify receiver array' do
    @array.should ==  [[  'a',  'aa',   'a'],
                       ['bbb',   'b',   'b']]
    ret = @array.rjust_rows
    ret.should ==     [[ ' a',  'aa',  ' a'],
                       ['bbb', '  b', '  b']]
    # Should not have modified @array
    @array.should ==  [[  'a',  'aa',   'a'],
                       ['bbb',   'b',   'b']]
  end
end
=end

