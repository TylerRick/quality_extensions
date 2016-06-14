#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes. Actually, Facets already has one, which takes a symbol (:inherited, :local, :public, etc.). Possibly merge with that one. Accept symbol *or* boolean as arg?
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'facets/module/alias_method_chain'

class Object

  # Ruby's built-in Object#methods says:
  #   Returns a list of the names of methods publicly accessible in obj. This will include all the methods accessible in obj's ancestors.
  #
  # But sometimes you don't _want_ all of obj's ancestors!
  #
  # This <tt>Object#methods</tt> adds the following features to the built-in <tt>Object#methods</tt>:
  # * Provides the same +include_super+ option that Module#instance_methods has (Backwards compatible, because default is +true+)
  # * Returns an array of symbols rather than strings (Not backwards compatible)
  # * Sorts the array for you so you don't have to! (Not backwards compatible)
  def methods_with_sorting_and_include_super(include_super = true)
    if include_super
      methods_without_sorting_and_include_super
    else
      (methods_without_sorting_and_include_super - Object.methods_without_sorting_and_include_super)
    end.sort.map(&:to_sym)
  end
  alias_method_chain :methods, :sorting_and_include_super

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
    assert_equal [:[]], Array.methods(false)
    assert       Array.methods.size > Array.methods(false).size

    assert       !Object.methods(true).include?(:[])
    assert        Array. methods(true).include?(:[])
  end
end
=end

# Old idea:
#
# class Object
#   def own_methods  # (or Object#my_methods)
#     ((methods - Object.methods).sort)
#       # Could just use self.class.instance_methods(false) but what if we also want class/module methods to be included?
#   end
# end
