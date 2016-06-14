#--
# Author::    Aaron Pfeifer, Neil Abraham, Tyler Rick 
# Copyright:: Copyright (c) 2006-2007 Aaron Pfeifer & Neil Abraham
# License::   MIT License
# Submit to Facets?:: Yes!
# Developer notes::
# * Why are we calling it create? Why not just new? Would that cause any problems?
# To do::
# * Submit to pluginaweek mailing list
# Changes:
#   r2964 (Tyler):
#   * Started from http://svn.pluginaweek.org/trunk/plugins/ruby/module/module_creation_helper/ (Last Changed Rev: 320)
#   * Renamed :parent option to :namespace. (:parent is still allowed for backwards compatibility)
#   * Changed examples and tests to pass in the name as a symbol instead of a string.
#   * Made it so you can pass in the namespace as part of the name if you want: Module.create(:'Foo::Bar') instead of Module.create(:Foo, :parent => Bar)
#   * Added to the documentation
#   * Added new tests
#     * test_with_block_2
#     * test_nested_class_with_superclass_with_same_name
#     * test_referencing_a_namespace_that_isnt_defined
#     * test_creating_a_class_more_than_once
#     * test_using_return_value_of_one_create_within_another_create
#   * Added __FILE__, __LINE__ to class_eval so that error messages would be more helpful.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'quality_extensions/hash/assert_has_only_keys'
require 'facets/hash/merge'
require 'facets/kernel/constant'
require 'quality_extensions/module/split'
require 'quality_extensions/module/basename'
require 'quality_extensions/module/dirname'

class Module
  # Creates a new module with the specified name.  This is essentially the
  # same as actually defining the module like so:
  # 
  #   module NewModule
  #   end
  # 
  # or as a class:
  # 
  #   class NewClass < SuperKlass
  #   end
  # 
  # Configuration options:
  # <tt>superclass</tt> - The class to inherit from.  This only applies when using Class#create.  Default is Object.
  # <tt>namespace</tt>/<tt>parent</tt> - The class/module namespace that contains this module.  Default is Object.
  #
  # You can also include the namespace in the +name+ if you'd prefer. For instance, name = <tt>:'Foo::Bar'</tt> is the same as specifying <tt>name = :Bar, :namespace => Foo</tt>. (Note: The namespace module specified must already be defined, just like it would have to be defined if you used the <tt>:namespace</tt> option.)
  #
  # Examples:
  # 
  #   Module.create(:Foo)                                                      # => Foo
  #   Module.create(:'Foo::Bar', :namespace => Foo)                            # => Foo::Bar
  #   Module.create(:Bar, :namespace => Foo)                                   # => Foo::Bar
  #
  #   Class.create(:Base)                                                      # => Base
  #   Class.create(:'Foo::Klass', :superclass => Base)                         # => Foo::Klass
  #
  # Unlike the built-in Ruby +module+/+class+ directive, this actually returns the newly created module/class as the return value. So, for example, you can do things like this:
  # 
  #   klass = Class.create(:'Foo::Klass', :superclass => Class.create(:Base))  # => Foo::Klass
  #   klass.name                                                               # => Foo::Klass
  #   klass.superclass                                                         # => Base
  #
  # You can also pass a block to create. This:
  #
  #   Class.create(:ClassWithBlock, :superclass => BaseClass) do
  #     def self.say_hello
  #       'hello'
  #     end
  #   end
  #
  # is equivalent to this:
  #
  #   class ClassWithBlock < BaseClass do
  #     def self.say_hello
  #       'hello'
  #     end
  #   end
  #
  def create(name, options = {}, &block)
    # Validate arguments
    raise ArgumentError unless name.respond_to?(:to_s)
    options[:namespace] = options.delete(:parent) if options.has_key?(:parent)
    options.assert_has_only_keys(
      :superclass,
      :namespace
    )
    module_or_class = self.to_s.downcase
    raise ArgumentError, 'Modules cannot have superclasses' if options[:superclass] && module_or_class == 'module'

    # Set defaults
    namespace_module, superclass =
      options[:namespace]  || ::Object, 
      options[:superclass] || ::Object

    # Determine the namespace to create it in
    nesting = Module.split_name(name)
    if nesting.size > 1
      namespace_module = Module.namespace_of(name) # For example, would be A::B for A::B::C
      base_name = Module.basename(name)            # For example, would be :C   for A::B::C
    else
      base_name = name
    end
    
    # Actually create the new module
    if superclass != ::Object
      superclass = " < ::#{superclass}"
    else
      superclass = ''
    end
    namespace_module.class_eval <<-end_eval, __FILE__, __LINE__
      #{module_or_class} #{base_name}#{superclass}
        # Empty
      end
    end_eval
    our_new_module = namespace_module.const_get(base_name)
    
    our_new_module.class_eval(&block) if block_given?
    our_new_module
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
require 'quality_extensions/module/attribute_accessors'
require 'quality_extensions/module/namespace'
require 'quality_extensions/symbol/constantize'
require 'facets/module/basename'

module Namespace
end

class BaseClass
  cattr_accessor :test_name
  cattr_accessor :test_inspect
  cattr_accessor :test_to_s
  
  def self.inherited(base)
    self.test_name = base.name
    self.test_inspect = base.inspect
    self.test_to_s = base.to_s
  end
end

class ModuleCreationHelperTest < Test::Unit::TestCase
  def setup
    BaseClass.test_name = nil
    BaseClass.test_inspect = nil
    BaseClass.test_to_s = nil
  end
  
  def test_no_options_for_class
    klass = Class.create(:Foo)
    assert_equal Object, klass.superclass
    assert_equal Object, klass.namespace_module
    assert Object.const_defined?('Foo')
  end
  
  def test_no_options_for_module
    mod = Module.create(:FooMod)
    assert_equal Object, mod.namespace_module
    assert Object.const_defined?('FooMod')
  end
  
  def test_invalid_option
    assert_raise(ArgumentError) {Class.create(nil, :invalid => true)}
  end
  
  def test_superclass_for_module
    assert_raise(ArgumentError) {Module.create(nil, :superclass => Object)}
  end
  
  def test_superclass
    klass = Class.create(:Bar, :superclass => BaseClass)
    assert_equal BaseClass, klass.superclass
    assert_equal Object, klass.namespace_module
    assert Object.const_defined?('Bar')
  end
  
  def test_namespace_for_class
    klass = Class.create(:Baz, :namespace => Namespace)
    assert_equal Object, klass.superclass
    assert_equal Namespace, klass.namespace_module
    assert Namespace.const_defined?('Baz')
  end
  
  def test_namespace_for_class__namespace_as_part_of_name
    klass = Class.create(:'Namespace::Baz')
    assert_equal Object, klass.superclass
    assert_equal Namespace, klass.namespace_module
    assert Namespace.const_defined?('Baz')
  end
  
  def test_namespace_for_module
    mod = Module.create(:BazMod, :namespace => Namespace)
    assert_equal Namespace, mod.namespace_module
    assert Namespace.const_defined?('BazMod')
  end
  
  def test_superclass_and_namespace
    klass = Class.create(:Biz, :superclass => BaseClass, :namespace => Namespace)
    assert_equal BaseClass, klass.superclass
    assert_equal Namespace, klass.namespace_module
    assert Namespace.const_defined?('Biz')
  end
  
  def test_name_before_evaluated
    klass = Class.create(:Waddle, :superclass => BaseClass)
    assert_equal 'Waddle', BaseClass.test_name
  end
  
  def test_inspect_before_evaluated
    klass = Class.create(:Widdle, :superclass => BaseClass)
    assert_equal 'Widdle', BaseClass.test_inspect
  end
  
  def test_to_s_before_evaluated
    klass = Class.create(:Wuddle, :superclass => BaseClass)
    assert_equal 'Wuddle', BaseClass.test_to_s
  end
  
  def test_name_before_evaluated_with_namespace
    klass = Class.create(:Waddle, :superclass => BaseClass, :namespace => Namespace)
    assert_equal 'Namespace::Waddle', BaseClass.test_name
  end
  
  def test_inspect_before_evaluated_with_namespace
    klass = Class.create(:Widdle, :superclass => BaseClass, :namespace => Namespace)
    assert_equal 'Namespace::Widdle', BaseClass.test_inspect
  end
  
  def test_to_s_before_evaluated_with_namespace
    klass = klass = Class.create(:Wuddle, :superclass => BaseClass, :namespace => Namespace)
    assert_equal 'Namespace::Wuddle', BaseClass.test_to_s
  end
  
  def test_subclass_of_dynamic_class
    klass = Class.create(:Foobar)
    subclass = Class.create(:Foobaz, :superclass => klass)
    
    assert_equal klass, subclass.superclass
    assert_equal 'Foobaz', subclass.name
    assert_equal 'Foobaz', subclass.inspect
    assert_equal 'Foobaz', subclass.to_s
  end
  
  def test_with_block_1
    klass = Class.create(:ClassWithBlock, :superclass => BaseClass) do
      def self.say_hello
        'hello'
      end
    end
    assert_equal 'hello', ClassWithBlock.say_hello
  end

  def test_with_block_2
    klass = Class.create(:ClassWithBlock, :superclass => BaseClass) do
      def say_hello
        'hello'
      end
    end
    assert_equal 'hello', ClassWithBlock.new.say_hello
  end
  
  def test_nested_class_with_superclass_with_same_name
    klass = Class.create(:Employee)
    nested_class = Class.create(:Employee, :superclass => klass, :namespace => Namespace)
    assert_equal klass, nested_class.superclass
    assert_equal klass.basename, nested_class.basename
  end
  
  def test_nested_class_with_superclass_with_same_name
    klass = Class.create(:Employee)
    nested_class = Class.create(:Employee, :superclass => klass, :namespace => Namespace)
    assert_equal klass, nested_class.superclass
    assert_equal klass.basename, nested_class.basename
  end

  def test_referencing_a_namespace_that_isnt_defined
    assert_raise(NameError) { Class.create(:'Zzt::Klass') }
  end

  def test_creating_a_class_more_than_once
    klass = Class.create(:'Foo')
    klass = Class.create(:'Foo')
  end

  def test_using_return_value_of_one_create_within_another_create
    klass = Class.create(:'Foo')
    klass = Class.create(:'Base')
    klass = Class.create(:'Foo::Klass', 
             :superclass => Class.create(:Base)
            )
    assert_equal 'Foo::Klass', klass.name
    assert_equal Base, klass.superclass
  end

  
end
=end

