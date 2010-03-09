#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++

require 'matrix'

class Vector
  include Enumerable

  def each &block
    to_a.each &block
  end

  def sum
    inject(&:+)
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

describe 'Vector' do
  it 'has an each method' do
    Vector[1, 2].each.to_a.should == [1, 2]
  end

  it 'includes Enumerable' do
    Vector.ancestors.should include(Enumerable)
  end

  it 'has an inject method that works' do
    Vector[1, 2].inject(&:+).should == 3
  end

  it 'has a sum method' do
    Vector[1, 2].sum.should == 3
  end
end
=end

