#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# * May not have taken every single case into consideration. Needs a bit more testing.
#   * public/private/protected?
# * Rename to origin_of_method (or source_of_method)?? Since strictly speaking it may return a method that is not from any *ancestors* but is from the Class class.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'quality_extensions/module/class_methods'
require 'quality_extensions/module/ancestry_of_instance_method'


class Object
  # Returns the module/class which defined the given method. If more than one module/class defined the method, returns the _closest_
  # ancestor to have defined it (would be +self+ if it is defined in +self+).
  #
  # This is (as far as I know -- patches welcome) <b>the method that would _would_ be called if you actually called the method</b>.
  # So if you override 
  #
  # It does this by first checking
  # searching the methods defined in each ancestor in turn (in the order that <tt>self.ancestors</tt> returns them) and
  # returning the first module/class that satisfies the search.
  #
  # This looks at the results of <tt>methods</tt>, which means that if you call this on a module/class, it will _not_ return
  # any instance methods, only _class_ methods.
  #
  #   class Base
  #     def self.it; end
  #   end
  #   class SubWithIt < Base
  #     def self.it; end
  #   end
  #   class SubWithoutIt < Base
  #   end
  #   SubWithIt.ancestry_of_instance_method(:it)    # => SubWithIt  # (Stops with self)
  #   SubWithoutIt.ancestry_of_instance_method(:it) # => Base       # (Goes one step up the ancestry tree)
  #
  # If you call this on an object that is _not_ a module or a class (in other words, if you call it on an _instance_ of some
  # class), then it will assume you actually want to know about an _instance_ method defined in self.class or one of the
  # ancestors of self.class. (Since non-modules don't even technically have the concept of _ancestors_.) Therefore, this:
  #   class Klass
  #     def it; end
  #   end
  #   o = Klass.new
  #   o.ancestry_of_method(:it)                      # => Klass
  # is really just a shorthand way of doing:
  #   o.class.ancestry_of_instance_method(:it)       # => Klass
  #
  # If the method is a singleton method of +self+, it will return +self+:
  #   class << (foo = SubWithIt.new)
  #     def it; end
  #   end
  #   foo.ancestry_of_method(:it) # => #<SubWithIt:0xb7e5614c>
  #
  # Returns nil if it cannot be found in self or in any ancestor.
  def ancestry_of_method(method_name)
    method_name = method_name.to_s
    (self if self.methods(false).include?(method_name)) \
    ||
    if self.is_a?(Module)
      self.ancestors.find do |ancestor|
        ancestor.methods(false).include? method_name
      end or
      # The above search does not take into account *instance* methods provided by Class, Module, or Kernel.
      # Remember that ancestors and instances/class/superclass are different concepts, and that although classes/modules
      # do not have Class or Module as an "ancestor", they are still *instances* of Module or Class (which is a subclass of module).
      # self.ancestors does NOT include Class or Module, and yet we're still able to "inherit" instance methods from Class or Module.
      # So we have to do this extra search in case the method came from one of the instance methods of Class or Module or Kernel
      # (are there any other cases I'm missing?).
      begin
        # self.class.ancestors is usually [Class, Module, Object, PP::ObjectMixin, Kernel]
        self.class.ancestors.find do |ancestor|
          ancestor.instance_methods(false).include? method_name 
          # || ancestor.private_instance_method_defined?( method_name.to_sym )
        end
      end
    else
      self.class.ancestry_of_instance_method(method_name)
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
require 'rubygems'
require 'quality_extensions/test/assert_anything'
require 'pp'

class Base
  def it; end
end
class SubWithIt < Base
  def it; end
end
class SubWithoutIt < Base
end

class << ($with_singleton_method = SubWithIt.new)
  def it; end
end

class ClassyBase
  def self.classy_it; end
end
class ClassySubWithIt < ClassyBase
  def self.classy_it; end
end
class ClassySubWithoutIt < ClassyBase
end

class << ($class_with_singleton_method = ClassySubWithIt)
  def classy_it; end
end

class ATest < Test::Unit::TestCase
  def test_non_existent_method
    assert_equal nil,      Base.ancestry_of_method(:not_a_method)
    assert_equal nil,      Base.ancestry_of_instance_method(:not_a_method)
  end
end

class InstanceMethodsTest < Test::Unit::TestCase
  def test_1
    assert_equal [SubWithoutIt, Base, Object, PP::ObjectMixin, Kernel], SubWithoutIt.ancestors
    assert_equal Base,      Base.ancestry_of_instance_method(:it)
    assert_equal Base,      SubWithoutIt.ancestry_of_instance_method(:it)
    assert_equal SubWithIt, SubWithIt.ancestry_of_instance_method(:it)
    assert_equal SubWithIt, SubWithIt.ancestry_of_instance_method(:it)
  end
  def test_ancestry_of_method__falls_back_to_using__ancestry_of_instance_method__if_is_an_instance
    assert_include?         Base.instance_methods, :it.to_s
    assert_equal Base,      Base.new.ancestry_of_method(:it)
    assert_equal Base,      SubWithoutIt.new.ancestry_of_method(:it)
    assert_equal SubWithIt, SubWithIt.new.ancestry_of_method(:it)

    # In other words, it's a *shortcut*. See?:
    o = SubWithIt.new
    assert_equal o.class.ancestry_of_instance_method(:it), o.ancestry_of_method(:it)
  end
  def test_singleton_method
    assert_equal $with_singleton_method, $with_singleton_method.ancestry_of_method(:it)
  end
  def test_that_you_cant_use_ancestry_of_instance_method_for_instances
    # undefined method `ancestors' for #<SubWithIt:0xb7e0fbc0>
    assert_raise(NoMethodError) { SubWithIt.new.ancestry_of_instance_method(:it) }
    assert_raise(NoMethodError) { $with_singleton_method.ancestry_of_instance_method(:it) }
  end
end
class ClassMethodsTest < Test::Unit::TestCase
  def test_ancestry_of_method_doesnt_return_instance_methods
    assert_include?     Base.instance_methods, :it.to_s
    assert_not_include? Base.methods,          :it.to_s

    assert_equal [SubWithoutIt, Base, Object, PP::ObjectMixin, Kernel], SubWithoutIt.ancestors

    assert_equal nil, Base.ancestry_of_method(:it)
    assert_equal nil, SubWithoutIt.ancestry_of_method(:it)
    assert_equal nil, SubWithIt.ancestry_of_method(:it)
  end
  def test_ancestry_of_method_does_return_class_methods
    assert_include?     ClassyBase.methods,          :classy_it.to_s
    assert_not_include? ClassyBase.instance_methods, :classy_it.to_s

    assert_equal [ClassySubWithoutIt, ClassyBase, Object, PP::ObjectMixin, Kernel], ClassySubWithoutIt.ancestors

    assert_equal ClassyBase,      ClassySubWithoutIt.ancestry_of_method(:classy_it)
    assert_equal ClassyBase,      ClassyBase.ancestry_of_method(:classy_it)
    assert_equal ClassySubWithIt, ClassySubWithIt.ancestry_of_method(:classy_it)
  end
  def test_singleton_method
    assert_equal $class_with_singleton_method, $class_with_singleton_method.ancestry_of_method(:classy_it)
    assert_equal nil,                          $class_with_singleton_method.ancestry_of_instance_method(:classy_it)
  end
end

class BuiltInMethodsTest < Test::Unit::TestCase
  def test_1
    assert_equal [Object, PP::ObjectMixin, Kernel], Object.ancestors
    assert_equal Kernel, Object.ancestry_of_method(:binding)
    assert_equal Kernel, Object.ancestry_of_method(:require)
    assert_equal Kernel, Object.ancestry_of_method(:proc)
  end

  def test_looks_at_Class_Module_and_Kernel_instance_methods_if_necessary
    # Sometimes it inherits a method NOT from any of its ancestors, but from Class (one of the *instance methods* of Class).

    # (Class is *not* an ancestor of Object and yet that appears to be where these methods come from.)
    assert_not_include? Object.ancestors, Class
    assert_equal Class, Object.class
    [
      :superclass,
      :new,
      :allocate,
    ].each do |method|
      assert_ancestry_of_method_is Object, method, Class
    end

    # superclass (and others) comes from Class, but instance_variable_get (and others) come from Module or Kernel.
    # (See below for more examples)
    assert_equal true, Class.instance_methods(false).include?('superclass')
    assert_equal false, Class.instance_methods(false).include?('instance_variable_get')
    assert_equal true, Kernel.instance_methods(false).include?('instance_variable_get')

    # (Module is *not* an ancestor of Object and yet that appears to be where these methods come from.)
    assert_not_include? Object.ancestors, Module
    [
      :instance_methods,
      :included_modules,
      :constants,
      :ancestors,
      :public_method_defined?,
    ].each do |method|
      assert_equal Module, Object.ancestry_of_method(method), "Failed for #{method}"
    end

    # (Kernel *is* an ancestor of Object, but these methods come from Kernel.instance_methods and *not* from Kernel.methods.)
    assert_include? Object.ancestors, Kernel
    [
      :puts,
      :system,
      :inspect,
      :send,
      :private_methods,
      :instance_variable_get,
    ].each do |method|
      assert_equal Kernel, Object.ancestry_of_method(method)
    end

    # proc apparently comes from *class method* Kernel.proc,
    # while instance_variable_get comes from *intance method* Kernel.instance_variable_get
    assert_equal true,  Kernel.class_methods(false).include?('proc')
    assert_equal false, Kernel.instance_methods(false).include?('proc')
    assert_equal false, Kernel.class_methods(false).include?('instance_variable_get')
    assert_equal true,  Kernel.instance_methods(false).include?('instance_variable_get')

    # Where does this method come from then???
    [
      :remove_class_variable,
      :remove_const,
      :remove_method,
      :undef_method,
      :nesting,
    ].each do |method|
      assert_equal nil, Object.ancestry_of_method(method)
    end
  end
end
=end
