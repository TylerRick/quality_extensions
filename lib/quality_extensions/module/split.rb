#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

class Module
  # Very similar to Facets' +Module#nesting+, but, whereas +nesting+ will break <tt>A::B</tt> into an array of _constants_ represting nesting
  # (<tt>[A, A::B]</tt>), this method will split it into an array of _symbols_: <tt>[:A, :B]</tt>.
  #
  # Note that the second element in this array, <tt>:B</tt>, is _not_ fully qualified, so you could not do a <tt>const_get</tt>
  # on that symbol.
  def split
    name.split(/::/).map(&:to_sym)
  end

  # Like Module#split, only this operates on a string/symbol. Useful for when you don't want to or can't actually instantiate
  # the module represented by the symbol.
  def self.split_name(name)
    name.to_s.split(/::/).map(&:to_sym)
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

module A
  module B
  end
end

class TheTest < Test::Unit::TestCase
  def test_A
    assert_equal [:A], A.split
  end
  def test_A_B
    assert_equal [:A, :B], A::B.split
  end

end
=end


