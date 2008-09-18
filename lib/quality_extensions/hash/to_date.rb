#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes. Unless it is deemed not generally reusable enough. Also, only if we can get a Date.new(y,m,d) added to Facets.
#++

require "rubygems"
require "active_support"

class Hash
  # Converts a <tt>{:year => ..., :month => ..., :day => ...}</tt> hash into an actual Date object.
  # Useful for when you have a date element in your <tt>params</tt> hash.
  def to_date
    Date.new(fetch(:year).to_i, fetch(:month).to_i, fetch(:day).to_i)
  end
end

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

class TheTest < Test::Unit::TestCase
  def test_Hash_to_date
    assert_equal Date.new(2007, 1, 22), {:year => "2007", :month => "01", :day => 22}.to_date
  end
  def test_HashWithIndifferentAccess_to_date
    assert_equal Date.new(2007, 1, 22), HashWithIndifferentAccess.new({:year => "2007", 'month' => 01, :day => 22}).to_date
  end
end
=end
