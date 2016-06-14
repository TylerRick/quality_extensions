#--
# Author::    Tyler Rick
# Inspired by: http://snippets.dzone.com/posts/show/3746 (ntk on Fri Mar 30 10:00:43 -0400 2007)
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++

require_relative 'select_bang'

module Enumerable
#   def reject!
#     if self.is_a? Range
#       to_a.reject! { yield }
#     else
#       raise NoMethodError
#     end
#   end

   def select_with_index
     index = -1
     if block_given?
       #select { |x| index += 1; yield(x, index) }  # not hash friendly?
       select { |*args| index += 1; yield(*(args + [index])) }
     else
       self
     end
   end

   def select_with_index!
     index = -1
     if block_given?
       select! { |x| index += 1; yield(x, index) }
     else
       self
     end
   end

   def reject_with_index
     index = -1
     if block_given?
       reject { |x| index += 1; yield(x, index) }
     else
       self
     end
   end

   def reject_with_index!
     index = -1
     if block_given?
       reject! { |x| index += 1; yield(x, index) }
     else
       self
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

describe 'Enumerable#select_with_index' do
  it 'select_with_index without a block, return self' do
    ('a'..'e').select_with_index.should == ('a'..'e')
  end

  it 'reject_with_index without a block, return self' do
    ('a'..'n').reject_with_index.should == ('a'..'n')
  end

  it 'select_with_index with i % 2 == 0' do
    ('a'..'e').select_with_index { |x, i| x if i % 2 == 0 }.should == ["a", "c", "e"]
  end

  it 'reject_with_index with i % 2 == 0' do
    ('a'..'n').reject_with_index { |x, i| x if i % 2 == 0 }.should == ["b", "d", "f", "h", "j", "l", "n"]
  end
end

describe 'Enumerable#select_with_index!' do
  it 'reject!' do
    a = %w[a b c d]
    a.reject! {|e| e =~ /[ab]/}
    a.should == %w[c d]
  end

  it 'select!' do
    a = %w[a b c d]
    a.select! {|e| e =~ /[ab]/}
    a.should == %w[a b]
  end

  it 'select_with_index! modifies receiver' do
    a = %w[a b c d]
    a.select_with_index! { |x, i| x if i % 2 == 0 }.should == a
    a.should == %w[a c]
  end

  it 'reject_with_index! modifies receiver' do
    a = %w[a b c d]
    a.reject_with_index! { |x, i| x if i % 2 == 0 }.should == a
    a.should == %w[b d]
  end
end

describe 'Enumerable#select_with_index! with hashes' do
  it 'reject!' do
    pending
    a = %w[a b c d]
    a.reject! {|e| e =~ /[ab]/}
    a.should == %w[c d]
  end

  it 'select!' do
    pending
    a = %w[a b c d]
    a.select! {|e| e =~ /[ab]/}
    a.should == %w[a b]
  end

  it 'select_with_index! modifies receiver' do
    pending
    a = %w[a b c d]
    a.select_with_index! { |x, i| x if i % 2 == 0 }.should == a
    a.should == %w[a c]
  end

  it 'reject_with_index! modifies receiver' do
    pending
    a = %w[a b c d]
    a.reject_with_index! { |x, i| x if i % 2 == 0 }.should == a
    a.should == %w[b d]
  end
end
=end
