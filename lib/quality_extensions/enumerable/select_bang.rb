#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++

module Enumerable
#   def reject!
#     if self.is_a? Range
#       to_a.reject! { yield }
#     else
#       raise NoMethodError
#     end
#   end

   def select!
     reject! { |x| !yield(x) }
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

describe 'Enumerable#select!' do
  it 'reject!' do
    a = %w[a b c d]
    a.reject! {|e| e =~ /[ab]/}.should == a
    a.should == %w[c d]
  end

  it 'select!' do
    a = %w[a b c d]
    a.select! {|e| e =~ /[ab]/}.should == a
    a.should == %w[a b]
  end
end
=end


