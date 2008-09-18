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
require 'facets/symbol/to_proc'
require 'quality_extensions/symbol/constantize'
require 'quality_extensions/module/namespace'  # dirname
require 'quality_extensions/module/basename'

class Module
  # Joins pieces of a "module path" together in the same sense that <tt>File.join</tt> joins pieces of a _filesystem_ path.
  #
  # See also <tt>Module.dirname</tt>/<tt>Module.namespace_name_of</tt> and <tt>Module.basename</tt>.
  #
  # These can be used together, such that the following is always true:
  #   OuterModule::MiddleModule::InnerModule == Module.join(Module.dirname(some_module), Module.basename(some_module)).constantize
  #   
  def self.join(*path_parts)
    path_parts.map(&:to_s).join('::')
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

class JoinTest < Test::Unit::TestCase
  def test_join
    assert_equal 'OuterModule::MiddleModule::InnerModule',
                 Module.join('OuterModule', 'MiddleModule', 'InnerModule')
  end
end

class TeamworkTest < Test::Unit::TestCase
  def test_join
    assert_equal ['OuterModule::MiddleModule', 'InnerModule'],
                 [Module.dirname(OuterModule::MiddleModule::InnerModule), Module.basename(OuterModule::MiddleModule::InnerModule)]
    assert_equal 'OuterModule::MiddleModule::InnerModule',
                 Module.join(Module.dirname(OuterModule::MiddleModule::InnerModule), Module.basename(OuterModule::MiddleModule::InnerModule))
    assert_equal OuterModule::MiddleModule::InnerModule,
                 Module.join(Module.dirname(OuterModule::MiddleModule::InnerModule), Module.basename(OuterModule::MiddleModule::InnerModule)).constantize
  end
end
=end



