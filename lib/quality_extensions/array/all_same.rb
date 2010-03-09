#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++

module Enumerable
  def all_same?
    all? {|a| a == first}
  end
end




#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec/autorun'

describe 'Enumerable#all_same?' do
  it 'works with arrays' do
    [1, 2].all_same?.should == false
    [1, 1].all_same?.should == true
  end

  it 'works with Enumerators' do
    'a b'.chars.all_same?.should == false
    'aaa'.chars.all_same?.should == true
  end
end
=end

