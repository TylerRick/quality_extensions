#--
# Source:     http://pastie.org/10707 (08/29/2006 by lukeredpath)
# Author::    Unknown, Tyler Rick
# Copyright:: Unknown, Tyler Rick
# License::   Original: assumed public domain / Modified version: Ruby License
# Submit to Facets?:: No. Already in Facets (different implementation).
# Developer notes::
# Changes::
#++

class Hash
  # Returns the hash with the keys named by +keys+ having been removed.
  #
  #    {:a => 1, :b => 2, :c => 3}.except(:a)
  # => {:b => 2, :c => 3}
  def except(*keys)
    self.reject { |k,v|
      keys.include? k
    }
  end

  # Returns the hash with only the keys named by +keys+ having been kept.
  #
  #    {:a => 1, :b => 2, :c => 3}.only(:a)
  # => {:a => 1}
  def only(*keys)
    self.dup.reject { |k,v|
      !keys.include? k
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
require 'facets/hash/rekey'

class TheTest < Test::Unit::TestCase
  def test_except
    assert_equal({         :b => 2, :c => 3},
                 {:a => 1, :b => 2, :c => 3}.except(:a))

    assert_equal({                  :c => 3},
                 {:a => 1, :b => 2, :c => 3}.except(:a, :b))
  end

  def test_except_does_not_symbolize_keys
    assert_equal({ :a => 1, :b  => 2},
                 { :a => 1, :b  => 2}.except('a'))
    assert_equal({'a' => 1, 'b' => 2},
                 {'a' => 1, 'b' => 2}.except(:a))

    # But it's easy to do if you need the hash rekeyed:
    assert_equal({          'b' => 2},
                 {:a  => 1, :b  => 2}.rekey(&:to_s).except('a'))
    assert_equal({          :b  => 2},
                 {'a' => 1, 'b' => 2}.rekey(&:to_sym).except(:a))
  end


  def test_only
    assert_equal({         :b => 2, :c => 3},
                 {:a => 1, :b => 2, :c => 3}.only(:b, :c))

    assert_equal({                  :c => 3},
                 {:a => 1, :b => 2, :c => 3}.only(:c))
  end

end
=end

