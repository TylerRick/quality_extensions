#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

class Object

  def class_methods(include_super = true)
    (
        methods(include_super) \
      - instance_methods
      #- Object.instance_methods ?
      #- Module.methods
    ).
      sort
  end
  alias_method :module_methods, :class_methods

end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'
require 'quality_extensions/test/assert_anything'
require 'set'

module M
  def instance_meth; end
  def self.module_meth; end
end
class C
  def instance_meth; end
  def self.module_meth; end
end
class CSub < C
  def sub_instance_meth; end
  def self.sub_module_meth; end
end


class TheTest < Test::Unit::TestCase
  C_common_instance_methods = ['object_id', 'dup', 'send', 'is_a?']
  C_common_class_methods = ['instance_methods']
  def test_class
    assert_subset? (['instance_meth'] + C_common_instance_methods).to_set,
      C.instance_methods.to_set
    assert_subset? (['module_meth'] + C_common_class_methods).to_set,
      C.class_methods.to_set
  end
  def test_class__no_super
    assert_subset? ['instance_meth'].to_set,
      C.instance_methods(false).to_set
    assert_subset? ['module_meth'].to_set,
      C.class_methods(false).to_set
  end

  def test_module
    assert_equal ['instance_meth'], M.instance_methods    # Unlike a class, modules don't have all the common instance methods from Object
    assert_subset? (['module_meth'] + C_common_class_methods).to_set,
      M.class_methods.to_set
  end
  def test_module__no_super
    assert_equal ['instance_meth'], M.instance_methods(false)    # Unlike a class, modules don't have all the common instance methods from Object
    assert_subset? (['module_meth']).to_set,
      M.class_methods(false).to_set
  end

  def test_subclass
    assert_subset? (['instance_meth', 'sub_instance_meth'] + C_common_instance_methods).to_set,
      CSub.instance_methods.to_set
    assert_subset? ['module_meth', 'sub_module_meth'].to_set,
      CSub.class_methods.to_set
  end
  def test_subclass__no_super
    assert_equal ['sub_instance_meth'], CSub.instance_methods(false)
    assert_equal ['sub_module_meth'],   CSub.class_methods(false)
  end
end
=end

