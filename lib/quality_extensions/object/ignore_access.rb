#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes:
# * Come up with a shorter/better name than ignore_access?
# * Other name ideas:
#   * ignore_private
#   * access_everything
#   * access
#   * sneaky
#   * rude
#   * all_public
#   * public!
#   * all (like rdoc's --all -- it's too generic for a method name though)
#   * promiscuous (like rdoc's --promiscuous -- different semantics though)
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'facets/functor'

class Object

  # Sends all messages to receiver, bypassing access restrictions, allowing you to call private methods (like class_variable_get) without having to write ugly send() calls.
  #
  #   o.class.ignore_access.class_variable_set(:@@v, 'new value')
  # is equivalent to:
  #   o.class.send(:class_variable_set, :@@v, 'new value')
  #
  # If you tried to just call the method directly, like this:
  #   o.class.class_variable_set(:@@v, 'new value')
  # you would get a NoMethodError:
  #   NoMethodError: private method `class_variable_set' called for Klass:Class
  #
  def ignore_access
    @_ignore_access_functor ||= Functor.new do |op,*args|
      self.send(op,*args)
    end
  end
  alias_method :access, :ignore_access

end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

class TheTest < Test::Unit::TestCase

  # It's not identical to Kernel#meta, as this test proves! (Must run it singly, without other tests.)
#  def test_meta
#    o = Object.new
#    o.class.meta.class_variable_set(:@@v, 'old value')
#    assert_equal 'old value', o.class.meta.class_variable_get(:@@v)
#
#    #assert_nothing_raised { o.class.send(:class_variable_get, :@@v) }    # Fails!
#
#    assert_equal Object, o.class
#    o.class.send(:class_variable_set, :@@v, 'new value')
#    assert_equal 'new value', o.class.send(:class_variable_get, :@@v)
#    assert_equal 'new value', o.class.meta.class_variable_get(:@@v)       # Fails! Still has 'old value'!
#  end

  def test_1
    o = Object.new
    o.class.ignore_access.class_variable_set(:@@v, 'old value')
    assert_nothing_raised { o.class.send(:class_variable_get, :@@v) }
    o.class.send(:class_variable_set, :@@v, 'new value')
    assert_equal 'new value', o.class.ignore_access.class_variable_get(:@@v)
    assert_equal 'new value', o.class.send(:class_variable_get, :@@v) 
  end

end

=end

