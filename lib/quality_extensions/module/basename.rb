#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/module/basename'
require 'quality_extensions/module/namespace'

class Module
  # Gets the basename of a "module path" (the name of the module without any of the namespace modules that it is contained in), 
  # in the same sense that <tt>File.basename</tt> returns the basename of a _filesystem_ path.
  #
  # This is identical to Facets' String#basename ('facets/string/basename') except that:
  # * it is a class method instead of an instance method of String,
  # * it accepts modules, strings, and symbols.
  #
  # See also <tt>Module.dirname</tt>/<tt>Module.namespace_name_of</tt>.
  #
  # These can be used together, such that the following is always true:
  #   OuterModule::MiddleModule::InnerModule == Module.join(Module.dirname(some_module), Module.basename(some_module)).constantize
  #   
  def self.basename(module_or_name)
    case module_or_name
      when Module
        module_or_name.basename
      when Symbol,String
        module_or_name.to_s.gsub(/^.*::/, '')
      else
        raise ArgumentError
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

module OuterModule; end
module OuterModule::MiddleModule; end
module OuterModule::MiddleModule::InnerModule; end

class BasenameTest < Test::Unit::TestCase
  def test_simple
    assert_equal 'OuterModule', Module.basename(OuterModule)
    assert_equal 'OuterModule', Module.basename(:OuterModule)
    assert_equal 'OuterModule', Module.basename('OuterModule')
  end
  def test_nesting
    assert_equal 'InnerModule',
                 Module.basename(OuterModule::MiddleModule::InnerModule)
    assert_equal 'InnerModule',
                 Module.basename(:'OuterModule::MiddleModule::InnerModule')
    assert_equal 'InnerModule',
                 Module.basename('OuterModule::MiddleModule::InnerModule')
  end
end
=end


