#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
gem 'facets'
require 'facets/kernel/singleton_class'
require 'facets/module/alias_method_chain'

class Module

  # Same as <tt>Module#alias_method_chain</tt>, only it works for modules/classes
  #
  #   class X
  #     def self.foo
  #       'foo'
  #     end
  #     malias_method_chain :foo, :feature
  #   end
  #
  # Note: You could always do the same thing with <tt>Module#alias_method_chain</tt> by simply doing this:
  #
  #   class << self
  #     alias_method_chain :foo, :feature
  #   end
  #
  def malias_method_chain(target, feature, *args)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.

    singleton_class.instance_eval do
      alias_method_chain target, feature, *args
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

class TestHowYouWouldDoItWithPlain_alias_method_chain < Test::Unit::TestCase

  class X
    def self.foo
      'foo'
    end
    def self.foo_with_feature
      foo_without_feature + '_with_feature'
    end
    class << self
      alias_method_chain :foo, :feature
    end
  end

  def test_001
    assert_equal 'foo_with_feature', X.foo
  end

end

class Test_malias_method_chain < Test::Unit::TestCase

  class Y
    def self.foo
      'foo'
    end
    def self.foo_with_feature
      foo_without_feature + '_with_feature'
    end
    malias_method_chain :foo, :feature
  end

  def test_001
    assert_equal 'foo_with_feature', Y.foo
  end

end

=end

