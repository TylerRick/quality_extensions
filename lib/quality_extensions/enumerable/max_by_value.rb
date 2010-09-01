#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2010, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++


module Enumerable

  # Instead of returns the object in enum that gives the maximum value from the
  # given block, like max_by does, returns the *maximum value* calculated by
  # the given block (which is tested on each object in enum, just like in
  # max_by).
  #
  # Notice the difference:
  #   ['a','abc','ab'].max_by       {|el| el.length}.should == 'abc'
  #   ['a','abc','ab'].max_by_value {|el| el.length}.should == 3
  #
  def max_by_value(&block)
    max_value = nil
    each do |el|
      value = yield el
      if max_value.nil?
        max_value = value
      else
        max_value = [value, max_value].max
      end
    end
    max_value
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

describe 'Enumerable#max_by_value' do
  it 'works in simple case' do
    [1,3,2].max_by_value {|el| el}.should == 3
  end

  it 'works for array of strings' do
    ['a','abc','ab'].max_by_value {|el| el.length}.should == 3
    ['a','abc','ab'].max_by       {|el| el.length}.should == 'abc'
  end

  it 'works in more complicated example' do
    files = [
              ["app/controllers/application_controller.rb.orig",
              Pathname.new('app/controllers/application_controller.rb')]
            ]
    max = files.max_by {|a| a.first.to_s.length}.first.to_s.length
          files.max_by_value {|a| a.first.to_s.length}.should == max

  end
end
=end

