#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) ActiveSupport authors
# License::   
# Submit to Facets?:: Yes.
# Developer notes::
# * Tests incomplete...
# Changes::
# * Copied from ActiveSupport.
#++

$LOAD_PATH << File.expand_path(File.expand_path(File.join(File.dirname(__FILE__), '..', '..')))
require 'facets/kernel/constant'


class Module
  # Return all the parents of this module, ordered from nested outwards. The
  # receiver is not contained within the result.
  def parents
    parents = []
    parts = name.split('::')[0..-2]
    until parts.empty?
      #parents << (parts * '::').constantize
      parents << constant(parts * '::')
      parts.pop
    end
    parents << Object unless parents.include? Object
    parents
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

module OuterModule; end
module OuterModule::InnerModule; end

class TheTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal [Object], OuterModule.parents
  end
  def test_nesting
    assert_equal [OuterModule, Object], OuterModule::InnerModule.parents
  end
  def test_nesting_2
    assert_equal [TheTest, Object], InnerModule.parents
  end
end
=end

