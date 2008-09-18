#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

require "rubygems"

class Hash
  # call-seq:
  #   hash.delete_unless {| key, value | block }  -> hash
  #
  # <tt>Hash#delete_unless</tt> is the opposite of <tt>Hash#delete_if</tt>: Deletes every key-value pair from <tt>hash</tt> _except_ those for which <tt>block</tt> evaluates to <tt>true</tt>.
  #
  def delete_unless(&block)
    delete_if {|k, v|
      !yield k, v
    }
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
  def test_1
    hash_copy = hash = {:a => 1, :b => 2}
    assert_equal hash.delete_if     {|k,v| k != :b},
                 hash.delete_unless {|k,v| k == :b}
    assert_equal({:b => 2}, hash)
  end
end
=end

