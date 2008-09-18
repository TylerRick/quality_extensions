#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'quality_extensions/object/ignore_access'
require 'quality_extensions/module/split'
require 'quality_extensions/module/by_name'
require 'facets/module/modspace'

class Module
  alias_method :remove_const_before_was_added_to_Kernel, :remove_const
end
module Kernel
  # This is similar to the built-in <tt>Module#remove_const</tt>, but it is accessible from all "levels" (because it is defined
  # in +Kernel+) and can handle hierarchy.
  #
  # Makes it possible to write simply:
  #   remove_const(A::B::C.name)
  # rather than having to think about which module the constant is actually defined in and calling +remove_const+ on that module.
  #
  # This is how you would otherwise have to do it:
  #   A::B.send(:remove_const, :C)
  #
  # +const_name+ must be an object that responds to +to_s+.
  #
  # +const_name+ must be a <i>fully qualified name</i>. For example, this will not work as expected:
  #
  #   module Mod
  #     Foo = 'foo'
  #     remove_const(:Foo)
  #   end
  #
  # because it will try to remove ::Foo instead of Mod::Foo. Fortunately, however, this will work as expected:
  #
  #   module Mod
  #     Foo = 'foo'
  #     remove_const(Foo.name)
  #   end
  #
  # This method is partially inspired by Facets' Kernel#constant method, which provided a more user-friendly alternative to const_get.
  #
  def remove_const(const_name)
    #require 'pp'
    #puts "remove_const(#{const_name})"
    raise ArgumentError unless const_name.respond_to?(:to_s)
    nesting = const_name.to_s.split(/::/).map(&:to_sym)
    if nesting.size > 1
      parent_module = constant(nesting[0..-2].join('::')) # For example, would be A::B for A::B::C
      const_to_remove = nesting[-1]                       # For example, would be :C   for A::B::C
      parent_module.ignore_access.remove_const_before_was_added_to_Kernel(const_to_remove)
    else
      ignore_access.remove_const_before_was_added_to_Kernel(const_name)
    end
  end
end

#p Module.private_instance_methods.grep(/remove_const/) # Lists it
Module.send(:remove_method, :remove_const)
#p Module.instance_methods.grep(/remove_const/)         # Does list it, because inherits *public* remove_const from Kernel
#p Module.private_instance_methods.grep(/remove_const/) # Does not list it, because it's no longer private
Module.send(:define_method, :remove_const, Kernel.method(:remove_const))
#p Module.private_instance_methods.grep(/remove_const/) # Lists it

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

# Important regression test. This was failing at one point.
module A
  B = nil
  remove_const :B
end

# How it would be done *without* this extension:
module TestRemoveABC_TheOldWay
  module A
    module B
      C = 'foo'
    end
  end

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B::C }
      A::B.send(:remove_const, :C)
      assert_raise(NameError) { A::B::C }
    end
  end
end

# How it would be done *with* this extension (all tests that follow):

module TestRemoveABC_CIsString
  module A
    module B
      C = 'foo'
    end
  end

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B::C }
      assert_raise(NoMethodError) { remove_const(A::B::C.name) } # Because C is a *string*, not a *module*
      assert_nothing_raised   { remove_const A::B.name + '::C' }
      assert_raise(NameError) { A::B::C }
    end
  end
end

module TestRemoveAB_UsingName
  module A
    module B
    end
  end

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B }
      remove_const(A::B.name)
      assert_raise(NameError) { A::B }
    end
  end
end

module TestRemoveAB_Symbol
  module A
    module B
      Foo = :Foo
    end
  end

  remove_const(:'A::B::Foo')      # This tests that Module#remove_const was overriden as well.
                                  # If we hadn't also overriden Module#remove_const, then this would have caused this error:
                                  #   in `remove_const': `A::B::Foo' is not allowed as a constant name (NameError)

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B }

      assert_equal 'TestRemoveAB_Symbol::A', A.name
      assert_raise(NameError) { remove_const(:'A::B') }   # This doesn't work because A, when evaluated in this context, 
                                                          # is TestRemoveAB_Symbol::TheTest::A, which is *not* defined.
 
      remove_const(:'TestRemoveAB_Symbol::A::B')
      assert_raise(NameError) { A::B }
    end
  end
end

module TestRemoveAB_Symbol2
  class TheTest < Test::Unit::TestCase
    module A
      module B
      end
    end
    def test_1
      assert_nothing_raised   { A::B }

      assert_equal 'TestRemoveAB_Symbol2::TheTest::A', A.name
      remove_const(:'A::B')        # Does work, because A is defined *within* TheTest this time.
      assert_raise(NameError) { A::B }
    end
  end
end

=end


