#--
# Author::    Trans?
# Copyright:: Copyright (c) Trans?
# License::   Ruby License
# Submit to Facets?:: No. Copied from facets-1.8.54/lib/facets/core/hash/assert_has_only_keys.rb. No longer exists in 2.4.1.
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/hash/keys'

class Hash

  # Returns true is hash has only then given keys,
  # otherwise throws an ArgumentError.
  #
  #   h = { :a => 1, :b => 2 }
  #   h.assert_has_only_keys( :a, :b )   #=> true
  #   h.assert_has_only_keys( :a )       #=> ArgumentError
  #
  def assert_has_only_keys(*check_keys)
    raise(ArgumentError, "has unexpected key(s)") unless has_only_keys?(*check_keys)
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

  class TCHash < Test::Unit::TestCase

    def test_assert_has_only_keys
      assert_nothing_raised {  { :a=>1,:b=>2,:c=>3 }.assert_has_only_keys(:a,:b,:c) }
      assert_raises( ArgumentError ) { { :a=>1,:b=>2,:c=>3 }.assert_has_only_keys(:a,:b) }
    end

  end

=end
