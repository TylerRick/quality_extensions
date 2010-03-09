#--
# Author::    Tyler Rick, Erik Veenstra
# Copyright:: -
# License::   -
# Submit to Facets?:: Maybe
# Developer notes::
# Changes::
# * Created, based on Facets group_by
#++

module Enumerable

  # #group_by_and_map is used to group items in a collection by something they
  # have in common.  The common factor is the key in the resulting hash, the
  # array of like elements is the value.
  #
  # This differs from the normal group_by in that it lets you map the values 
  # (perhaps removing the key from the value since that would be redundant)
  # all in one step.
  #
  #
  #   # need better example
  #   (1..6).group_by_and_map { |n| next n % 3, n }
  #        # => { 0 => [3,6], 1 => [1, 4], 2 => [2,5] }
  #
  #   [
  #     ['31a4', 'v1.3'],
  #     ['9f2b', 'current'],
  #     ['9f2b', 'v2.0']
  #   ].group_by_and_map { |e| e[0], e[1] }
  #        # => {"31a4"=>["v1.3"], "9f2b"=>["current", "v2.0"]}
  #
  #   results.group_by_and_map { |a| a[0], a[1..-1] }
  #
  # CREDIT: Erik Veenstra, Tyler Rick

  def group_by_and_map #:yield:
    h = Hash.new
    each { |e| 
      result = yield(e)
      #p result
      (h[result[0]] ||= []) << result[1]
    }
    h
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

describe 'Enumerable#group_by_and_map' do
  it '' do
    (1..6).group_by_and_map { |n| next n % 3, n }.should ==
      {0=>[3, 6], 1=>[1, 4], 2=>[2, 5]}
  end

  it '' do
    [
      ['r1', 'v1.3'],
      ['r9', 'current'],
      ['r9', 'v2.0']
    ].group_by_and_map { |e| next e[0], e[1] }.should ==
      {"r1"=>["v1.3"], "r9"=>["current", "v2.0"]}
  end

  it 'beats the alternatives' do
    expected = {1=>["a", "b"], 2=>["c"], 3=>["d"]}
    result = [
      [1, 'a'],
      [1, 'b'],
      [2, 'c'],
      [3, 'd'],
    ].group_by_and_map { |e| next e[0], e[1] }
    result.should == expected
    result.should be_instance_of Hash
    result[1].should == ['a', 'b']

    # group_by and then map? Then it's no longer a hash and is icky to work with.
    result = [
      [1, 'a'],
      [1, 'b'],
      [2, 'c'],
      [3, 'd'],
    ].group_by { |e| e[0] }.map { |(k,v)| [k,v.map(&:last)]}
    result.should == expected.to_a
    result.should be_instance_of Array
    # Yuck
    result[0].should == [1, ['a', 'b']]
    result[1].should == [2, ['c']]

    # map and then group_by? As soon as you use map to discard the key so it's not in the value, that information is lost and can't be used by the group_by.
    result = [
      [1, 'a'],
      [1, 'b'],
      [2, 'c'],
      [3, 'd'],
    ].map {|a| a[1]}
    result.should == ["a", "b", "c", "d"]  # oops, now how do we do a group_by on the key we just removed?
    result.should be_instance_of Array
  end
end
=end

