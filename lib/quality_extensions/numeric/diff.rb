#--
# Source:     http://tfletcher.com/lib/gradiate.rb
# Author::    Tim Fletcher
# Copyright:: Copyright (c) 2008, Tim Fletcher
# License::   Ruby License?
# Submit to Facets?:: Yes
# Developer notes::
# Changes::
#++

class Numeric #:nodoc:
  def diff(n)
    return (self > n ? self - n : n - self)
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

describe Numeric.instance_method(:diff) do
  it "should not matter which object is the receiver" do
    1.diff(3).should == 2
    3.diff(1).should == 2
  end

  it "should be the same as taking the absolute value of the difference" do
    1.diff(1).should == (1 - 1).abs

    1.diff(3).should == (1 - 3).abs
    3.diff(1).should == (3 - 1).abs

    1. diff(-1).should == (1 - -1).abs
    -1.diff(1). should == (-1 - 1).abs
  end
end
=end
