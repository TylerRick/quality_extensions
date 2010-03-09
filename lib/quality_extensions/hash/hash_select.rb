#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No.
# Deprecated. Ruby 1.9 implements #select correctly.
#++

require "rubygems"

if RUBY_VERSION < '1.9'
class Hash
  # call-seq:
  #   hash.hash_select {| key, value | block }  -> hash
  #
  # <tt>Hash#reject</tt> returns a hash. One would intuitively expect <tt>Hash#select</tt> to also return a hash. However, it doesn't: instead, returns "a new array consisting of <tt>[key,value]</tt> pairs for which the block returns true".
  #
  # <tt>Hash#hash_select</tt> behaves how <tt>Hash#select</tt> (arguably) _should_ behave: Deletes every key-value pair from a copy of <tt>hash</tt> _except_ those for which <tt>block</tt> evaluates to <tt>true</tt>.
  #
  def hash_select(&block)
    reject {|k, v|
      !yield k, v
    }
  end

  alias_method :hash_find_all, :hash_select
  alias_method :delete_unless, :hash_select
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

class HashSelectTest < Test::Unit::TestCase
  def test_1
    hash_copy = hash = {:a => 1, :b => 2}
    assert_equal hash.reject      {|k,v| k != :b},
                 hash.hash_select {|k,v| k == :b}
    assert_equal(hash_copy, hash)
  end
end
=end
