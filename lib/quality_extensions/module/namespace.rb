#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
# * 0.0.52: Renamed namespace to namespace_module to avoid conflicting with Facets' Module#namespace and Rake's namespace
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'quality_extensions/symbol/constantize'
require 'quality_extensions/module/split'


class Module
  # Return the module which contains this one; if this is a root module, such as
  # +::MyModule+, then Object is returned.
  def namespace_module
    namespace_name = name.split('::')[0..-2].join('::')
    namespace_name.empty? ? Object : namespace_name.constantize
  end

  # Gets the "dirname" of a "module path" (the string/symbol representing the namespace modules that it is contained in), 
  # in the same sense that <tt>File.dirname</tt> returns the dirname of a _filesystem_ path.
  #
  # Same as +namespace_of+, only this just returns the _name_ of the namespace module (as a string), rather than returning the
  # constant itself.
  #
  # See also <tt>Module.basename</tt>
  def self.dirname(module_or_name)
    case module_or_name
      when Module
        module_or_name.namespace_module.name
      when Symbol
        Module.split_name(module_or_name)[0..-2].join('::')
      when String
        Module.split_name(module_or_name)[0..-2].join('::')
    end
  end
  class << self
    alias_method :namespace_name_of, :dirname
  end

  def self.namespace_of(module_or_name)
    namespace_name_of(module_or_name).constantize
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
module OuterModule::MiddleModule; end
module OuterModule::MiddleModule::InnerModule; end

class NamespaceTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal Object, OuterModule.namespace_module
  end
  def test_nesting
    assert_equal OuterModule::MiddleModule, 
                 OuterModule::MiddleModule::InnerModule.namespace_module
  end
  def test_nesting_2
    assert_equal NamespaceTest, InnerModule.namespace_module
  end
end

class NamespaceOfTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal Object, Module.namespace_of(OuterModule)
  end
  def test_nesting
    assert_equal OuterModule::MiddleModule,
                 Module.namespace_of(OuterModule::MiddleModule::InnerModule)
    assert_equal OuterModule::MiddleModule,
                 Module.namespace_of(:'OuterModule::MiddleModule::InnerModule')
    assert_equal OuterModule::MiddleModule,
                 Module.namespace_of('OuterModule::MiddleModule::InnerModule')
  end
end

class NamespaceNameOfTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal 'Object',
                 Module.namespace_name_of(OuterModule)
  end
  def test_nesting
    assert_equal 'OuterModule::MiddleModule',
                 Module.namespace_name_of(OuterModule::MiddleModule::InnerModule)
    assert_equal 'OuterModule::MiddleModule',
                 Module.namespace_name_of(:'OuterModule::MiddleModule::InnerModule')
    assert_equal 'OuterModule::MiddleModule',
                 Module.namespace_name_of('OuterModule::MiddleModule::InnerModule')
  end
end
=end

