#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'quality_extensions/object/ignore_access'
require 'quality_extensions/module/split'
require 'quality_extensions/module/by_name'
require 'facets/module/modspace'

module Kernel
  # This is similar to +Kernel#remove_const+, but it _only_ works for modules/classes.
  #
  # This is similar to the built-in <tt>Module#remove_module</tt>, but it lets you do it in a more object oriented manner,
  # calling +remove!+ on the module/class/constant itself that you want to remove, rather than on its parent.
  #
  # Makes it possible to write simply:
  #   A::B::C.remove_const!
  # rather than having to think about which module the constant is actually defined in and calling +remove_const+ on that module.
  # This is how you would have to otherwise do it:
  #   A::B.send(:remove_const, :C)
  #
  def remove_const!
    if split.size > 1
      parent_module = modspace      # For example, would be A::B for A::B::C
      const_to_remove = split.last  # For example, would be :C   for A::B::C
      parent_module.ignore_access.remove_const(const_to_remove)
    else
      Object.ignore_access.remove_const(name)
    end
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
require 'quality_extensions/kernel/remove_const'     # Test for compatibility. Just in case the remove_const_before_was_added_to_Kernel alias might have thrown something off.

# How it would be done *without* this extension:
module TestRemoveABC_TheOldWay
  module A
    module B
      class C
      end
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

# How it would be done *with* this extension:
module TestRemoveABC
  module A
    module B
      class C
      end
    end
  end

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B::C }
      A::B::C.remove_const!
      assert_raise(NameError) { A::B::C }
    end
  end
end

module TestRemoveAB
  module A
    module B
      module C
      end
    end
  end

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A::B }
      A::B.remove_const!
      assert_raise(NameError) { A::B }
    end
  end
end

module A
end
module TestRemoveA_FromObject

  class TheTest < Test::Unit::TestCase
    def test_1
      assert_nothing_raised   { A }
      A.remove_const!
      assert_raise(NameError) { A }
    end
  end
end

=end



