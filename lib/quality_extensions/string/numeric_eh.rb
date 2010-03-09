#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick and others
# Credits:: 
# - http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/14518
# - http://www.ruby-forum.com/topic/123422
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++

class String
  # returns true if the string is a valid number (which can be converted to an actual number using the Float() or String#to_f methods); otherwise returns false
  def numeric?
    !self.empty? && !!Float(self) rescue false
  end

  # returns true if the string is a valid integer (which can be converted to an Integer using the Integer() or String#to_i methods); otherwise returns false
  def integer?
    # not the empty string and containing only 1 or more digits
    !self.empty? && !!(self =~ /\A[-+]?\d+\Z/)
  end
  #def integer?
  #  !!Integer(self) rescue false
  #end
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
    '3'.numeric?.should     == true
    '+3'.numeric?.should    == true
    '-3'.numeric?.should    == true
    '3.14'.numeric?.should  == true
    '-3.14'.numeric?.should == true
  end

  it 'returns false for invalid numbers' do
    '3.14.1'.numeric?.should == false
    '1,2'.numeric?.should    == false
    'a'.numeric?.should      == false
    '3a'.numeric?.should     == false
  end
end

describe 'String#integer?' do
  it 'returns true for valid numbers' do
    '3'.integer?.should     == true
    '+3'.integer?.should    == true
    '-3'.integer?.should    == true
  end

  it 'returns false for non-integer strings' do
    '3.14'.integer?.should  == false
    '-3.14'.integer?.should == false
  end

  it 'returns false for invalid numbers' do
    '3.14.1'.integer?.should == false
    '1,2'.integer?.should    == false
    'a'.integer?.should      == false
    '3a'.integer?.should     == false
  end
end
=end
