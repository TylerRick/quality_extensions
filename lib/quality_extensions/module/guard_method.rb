#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes::
# * Is it thread-safe?? Probably not, as it stands...
#   But the whole thing that prompted me to create a guard method in the first place was to try to avoid a deadlock that was
#   caused by recursively calling a method with a synchronize in it (in other words, someone else's attempt at thread-safety
#   resulted in me getting into a deadlock, which is why I wrote this method to begin with). So I'm not even sure if it's
#   possible to make it thread-safe?
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'quality_extensions/module/attribute_accessors'
require 'facets/kernel/require_local'
require_local 'bool_attr_accessor'
#require 'quality_extensions/module/bool_attr_accessor'
require 'quality_extensions/symbol/match'


class Module
  # A guard method (by this definition anyway) is a method that sets a flag, executes a block, and then returns the flag to its
  # previous value. It ensures that the flag is set during the execution of the block.
  #
  # In the simplest case, you'd use it like this:
  #   class A
  #     guard_method :disable_stupid_stuff!, :@stupid_stuff_disabled
  #   end
  #   a = A.new
  #   a.disable_stupid_stuff! do   # Causes @stupid_stuff_disabled to be set to true
  #     # Section of code during which you don't want any stupid stuff to happen
  #   end                          # Causes @stupid_stuff_disabled to be set back to false
  #   # Okay, a, you can resume doing stupid stuff again...
  #
  # If you want your guard method to *disable* the flag rather than *enable* it, simply pass false to the guard method.
  #
  # These calls can be nested however you wish:
  #   a.guard_the_fruit! do
  #     a.guard_the_fruit!(false) do
  #       assert_equal false, a.guarding_the_fruit?
  #     end
  #     assert_equal true, a.guarding_the_fruit?
  #   end
  #
  # You can also use the guard methods as normal flag setter/clearer methods by simply not passing a block to it. Hence
  #   a.guard_the_fruit!
  # will simply set @guarding_the_fruit to true, and
  #   a.guard_the_fruit!(false)
  # will set @guarding_the_fruit to false.
  #
  def guard_method(guard_method_name, guard_variable)
    raise ArgumentError.new("Expected an instance variable name but got #{guard_variable}") if guard_variable !~ /^@([\w_]+)$/
    guard_variable.to_s =~ /^@([\w_]+)$/    # Why didn't the regexp above set $1 ??
    class_eval do
      bool_attr_accessor $1.to_sym
    end
    module_eval <<-End, __FILE__, __LINE__+1
      def #{guard_method_name}(new_value = true, &block)
        old_guard_state, #{guard_variable} = #{guard_variable}, new_value
        if block_given?
          begin
            returning = yield
          ensure
            #{guard_variable} = old_guard_state
            returning
          end
        end
      end
    End
  end

  # See the documentation for guard_method. mguard_method does the same thing, only it creates a _class_ (or _module_) method
  # rather than an instance method and it uses a _class_ (or _module_) variable rather than an instance variable to store the
  # guard state.
  #
  # Example:
  #   mguard_method :guard_the_fruit!, :@@guarding_the_fruit
  #   mguard_method :use_assert_equal_with_highlight!, :@@always_use_assert_equal_with_highlight
  def mguard_method(guard_method_name, guard_variable)
    raise ArgumentError.new("Expected a class variable name but got #{guard_variable}") if guard_variable !~ /^@@[\w_]+$/
    guard_variable.to_s =~ /^@@([\w_]+)$/
    class_eval do
      mbool_attr_accessor $1.to_sym
    end
    module_eval <<-End, __FILE__, __LINE__+1
      class << self
        def #{guard_method_name}(new_value = true, &block)
          old_guard_state, #{guard_variable} = #{guard_variable}, new_value
          if block_given?
            begin
              returning = yield
            ensure
              #{guard_variable} = old_guard_state
              returning
            end
          end
        end
      end
    End
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

class GuardMethodTest_Simple < Test::Unit::TestCase
  class A
    guard_method :guard_the_fruit!, :@guarding_the_fruit
  end
  def test_guard_method
    a = A.new
    assert_equal nil, a.guarding_the_fruit?
    a.guard_the_fruit! do
      # Call it recursively!
      a.guard_the_fruit! do
        assert_equal true, a.guarding_the_fruit?
      end
      assert_equal true, a.guarding_the_fruit?   # This is the reason why we have to save the 'old_guard_state'. So that we don't stupidly set it back to false if we still haven't exited from the outermost call to the guard black.
    end
    assert_equal nil, a.guarding_the_fruit?
  end
  def test_guard_method_error
    assert_raise(ArgumentError) do
      self.class.class_eval do
        guard_method :guard_the_fruit!, :@@guarding_the_fruit
      end
    end
  end
  def test_return_value
    assert_equal 'special return value', A.new.guard_the_fruit! { 'special return value' }
  end

  def try_to_return_prematurely(a)
    a.guard_the_fruit! do
      assert_equal true, a.guarding_the_fruit?
      return 'prematurely'
    end
  end
  def test_guard_method_for_block_that_tries_to_return_prematurely
    a = A.new
    assert_equal nil, a.guarding_the_fruit?
    try_to_return_prematurely(a)
    assert_equal nil, a.guarding_the_fruit?
  end
end

class GuardMethodTest_WithUnguard < Test::Unit::TestCase    # (By "unguard" here I mean passing false to the guard method...)
  class A
    guard_method :guard_the_fruit!, :@guarding_the_fruit
  end
  def test_guard_method
    a = A.new
    assert_equal nil, a.guarding_the_fruit?
    a.guard_the_fruit! do
      a.guard_the_fruit! do
        assert_equal true, a.guarding_the_fruit?

        a.guard_the_fruit! false do
          assert_equal false, a.guarding_the_fruit?
          a.guard_the_fruit! do
            assert_equal true, a.guarding_the_fruit?
          end
          assert_equal false, a.guarding_the_fruit?
        end

        assert_equal true, a.guarding_the_fruit?
      end
      assert_equal true, a.guarding_the_fruit?
    end
    assert_equal nil, a.guarding_the_fruit?
  end

  def test_guard_method_with_simple_blockless_toggles
    a = A.new
    assert_equal nil, a.guarding_the_fruit?
    a.guard_the_fruit!
    assert_equal true, a.guarding_the_fruit?

    a.guarding_the_fruit? do
      assert_equal false, a.guarding_the_fruit?
      a.guard_the_fruit! do
        assert_equal true, a.guarding_the_fruit?
        a.guard_the_fruit! false
        assert_equal false, a.guarding_the_fruit?
        a.guard_the_fruit!
        assert_equal true, a.guarding_the_fruit?
      end
      assert_equal false, a.guarding_the_fruit?
    end

    assert_equal true, a.guarding_the_fruit?
  end

  def test_return_value
    assert_equal nil, A.new.guard_the_fruit!
    assert_equal nil, A.new.guard_the_fruit!(false)
    assert_equal 'special return value', A.new.guard_the_fruit!        { 'special return value' }
    assert_equal 'special return value', A.new.guard_the_fruit!(false) { 'special return value' }
  end
end

#---------------------------------------------------------------------------------------------------------------------------------
# Begin duplication
# The following TestCases are simply duplicates of the previous except that they test mguard_method rather than guard_method
# The main differenes/substitutions:
# * @@guarding_the_fruit, rather than @guarding_the_fruit
# * :'<,'>s/A.new/B/g
# * :'<,'>s/\<a\>/B/g

class MGuardMethodTest_Simple < Test::Unit::TestCase
  class B
    mguard_method :guard_the_fruit!, :@@guarding_the_fruit
  end
  def test_mguard_method
    assert_equal nil, B.guarding_the_fruit?
    B.guard_the_fruit! do
      # Call it recursively!
      B.guard_the_fruit! do
        assert_equal true, B.guarding_the_fruit?
      end
      assert_equal true, B.guarding_the_fruit?   # This is the reason why we have to save the 'old_guard_state'. So that we don't stupidly set it back to false if we still haven't exited from the outermost call to the guard black.
    end
    assert_equal nil, B.guarding_the_fruit?
  end
  def test_mguard_method_error
    assert_raise(ArgumentError) do
      self.class.class_eval do
        mguard_method :guard_the_fruit!, :@guarding_the_fruit
      end
    end
  end
  def test_return_value
    assert_equal 'special return value', B.guard_the_fruit! { 'special return value' }
  end

  def try_to_return_prematurely
    B.guard_the_fruit! do
      assert_equal true, B.guarding_the_fruit?
      return 'prematurely'
    end
  end
  def test_guard_method_for_block_that_tries_to_return_prematurely
    assert_equal nil, B.guarding_the_fruit?
    try_to_return_prematurely
    assert_equal nil, B.guarding_the_fruit?
  end
end

class MGuardMethodTest_WithUnguard < Test::Unit::TestCase
  class B
    mguard_method :guard_the_fruit!, :@@guarding_the_fruit
  end
  def test_guard_method
    assert_equal nil, B.guarding_the_fruit?
    B.guard_the_fruit! do
      B.guard_the_fruit! do
        assert_equal true, B.guarding_the_fruit?

        B.guard_the_fruit!(false) do
          assert_equal false, B.guarding_the_fruit?
          B.guard_the_fruit! do
            assert_equal true, B.guarding_the_fruit?
          end
          assert_equal false, B.guarding_the_fruit?
        end

        assert_equal true, B.guarding_the_fruit?
      end
      assert_equal true, B.guarding_the_fruit?
    end
    assert_equal nil, B.guarding_the_fruit?
  end

  def test_guard_method_with_simple_blockless_toggles
    assert_equal nil, B.guarding_the_fruit?
    B.guard_the_fruit!
    assert_equal true, B.guarding_the_fruit?

    B.guard_the_fruit!(false) do
      assert_equal false, B.guarding_the_fruit?
      B.guard_the_fruit! do
        assert_equal true, B.guarding_the_fruit?
        B.guard_the_fruit!(false)
        assert_equal false, B.guarding_the_fruit?
        B.guard_the_fruit!
        assert_equal true, B.guarding_the_fruit?
      end
      assert_equal false, B.guarding_the_fruit?
    end

    assert_equal true, B.guarding_the_fruit?
  end

  def test_return_value
    assert_equal nil, B.guard_the_fruit!
    assert_equal nil, B.guard_the_fruit!(false)
    assert_equal 'special return value', B.guard_the_fruit!         { 'special return value' }
    assert_equal 'special return value', B.guard_the_fruit!(false) { 'special return value' }
  end
end
# End duplication
#---------------------------------------------------------------------------------------------------------------------------------
=end

