#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2001, Leo [ slonika AT yahoo DOT com ], Tyler Rick
# Credits:: 
# - http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/14518
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++


# Conversion from a String to Numbers should raise an exception if the string has
# an improper format. Strangely enough, Ruby's standard conversion functions do not
# provide for any kind of error handling and return number '0' on failure.
# Therefore, in Ruby one cannot possibly distinguish between these two cases:
#       "0".to_i             # -> 0
#       "not-a-number".to_i  # -> 0

# The following code augments standard conversion functions String#to_i and
# String#to_f with the error handling code so that an attempt to convert a
# string not suited for numeric conversion will raise NumericError exception.

class NumericError < RuntimeError
end

require 'facets/kernel/require_local'
require_local 'numeric_eh'


class String
  alias __std__to_i to_i   if ! method_defined? :__std__to_i
  alias __std__to_f to_f   if ! method_defined? :__std__to_f
  alias __std__hex  hex    if ! method_defined? :__std__hex
  alias __std__oct  oct    if ! method_defined? :__std__oct
  
  def to_i()
    case self 
    when /^[-+]?0\d/         then  __std__oct
    when /^[-+]?0x[a-f\d]/i  then  __std__hex
    when /^[-+]?\d/          then  __std__to_i
    else raise NumericError, "Cannot convert string to Integer!"
    end
  end

  def to_f()
    case self
    when /^[-+]?\d/          then  __std__to_f
    else raise NumericError, "Cannot convert string to Float!"
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

describe 'String#numeric?' do
  it 'returns true for valid numbers' do
    '3'.to_f.should     == 3
    '+3'.to_f.should    == 3
    '-3'.to_f.should    == -3
    '3.14'.to_f.should  == 3.14
    '-3.14'.to_f.should == -3.14

    # Debatable!: Should also work for strings that are not valid floats but can still be converted
    '3.14.1'.to_f.should == 3.14
    '1,2'.to_f.should    == 1
    '3a'.to_f.should     == 3
  end

  it 'returns raises an Exception for non-convertable strings' do
    lambda { 'garbage'.to_f }.should raise_error(NumericError)
  end
end

describe 'String#to_i' do
  it 'returns works for valid numbers' do
    '3'.to_i.should     == 3
    '+3'.to_i.should    == 3
    '-3'.to_i.should    == -3

    # Debatable!: Should also work for strings that are not valid integers but can still be converted
    # Question: should we make it raise NumericError in these cases? and require a .to_f.to_i if they want to convert strings to floats to integers?
    '3.14'.to_i.should  == 3
    '-3.14'.to_i.should == -3
    '3.14.1'.to_i.should == 3
    '1,2'.to_i.should    == 1
    '3a'.to_i.should     == 3
  end

  it 'returns raises an Exception for non-convertable strings' do
    lambda { 'garbage'.to_i }.should raise_error(NumericError)
  end
end
=end
