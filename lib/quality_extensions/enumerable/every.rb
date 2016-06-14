#--
# Source:     http://tfletcher.com/lib/gradiate.rb
# Author::    Tim Fletcher
# Copyright:: Copyright (c) 2008, Tim Fletcher
# License::   Ruby License?
# Submit to Facets?:: Yes
# Developer notes::
# Changes::
# * 2009-01-11 (Tyler):
#   * Added some tests
#++

module Enumerable

  # Yields every nth object (if invoked with a block),
  # or returns an array of every nth object.
  #
  # every(2), for example, would return every other element from the enumerable:
  #
  #   [1, 2, 3, 4, 5, 6].every(2)               -> [1, 3, 5]
  #   [1, 2, 3, 4, 5, 6].every(2) { |i| ... }   -> nil
  #
  def every(n)
    result = [] unless block_given?
    each_with_index do |object, i|
      if i % n == 0
        block_given?? yield(object) : result << object
      end
    end
    return block_given?? nil : result
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
require_relative 'enum'

describe Enumerable.instance_method(:every) do
  it "without block, every(1)" do
    (1..6).every(1).should == (1..6).to_a
    [1, 2].every(1).should == [1, 2]
  end

  it "without block, every(2)" do
    (1..6).every(2).should == [1, 3, 5]
    [1, 2].every(2).should == [1]
  end

  it "without block, every(3)" do
    (1..7).every(3).should == [1, 4, 7]
    (0..7).every(3).should == [0, 3, 6]
  end

  it "with block, every(2)" do
    results = []
    (1..6).every(2) {|i| results << i.to_s}
    results.should == %w[1 3 5]
  end

  it "as Enumerator" do
    (1..6).enum(:every, 2).map(&:to_s).should == %w[1 3 5]
  end
end
=end
