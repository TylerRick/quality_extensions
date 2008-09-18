#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe.
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

class Object
  # Calls the method implementation from the module of your choice (+moduule+) on the object of your choice (+self+).
  #
  # The only (huge) catch is that +self+ must either be an instance of +moduule+ or have +moduule+ as an ancestor... which severely limits its usefullness. (Compare with singleton_send.)
  #
  # It is still useful, though, if you want to call some "original" implementation provided by Kernel (or some other base module) and the people that overrode it didn't play nice and use +alias_method_chain+.
  #
  # No matter! If the class of the object you are calling this on has Kernel as an ancestor, then you can call any method from Kernel on this object!
  #
  # This implementation is gratefully owed to the folks who wrote PP (/usr/lib/ruby/1.8/pp.rb)
  def mcall(moduule, message, *args, &block)
    moduule.instance_method(message).bind(self).call(*args, &block)
  end
  alias_method :msend, :mcall
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
require 'quality_extensions/test/assert_exception'
require 'quality_extensions/test/assert_includes'
require 'facets/module/alias_method_chain'


module MyColorizer
  def colorize(color = nil)
    self + " (colorized in #{color})"
  end
end
class String
  def class()
    'classy'
  end
end

class TheTest < Test::Unit::TestCase
  def test_doesnt_work_like_singleton_send
    # This doesn't quite work the same as singleton_send ...
    assert_exception(TypeError, lambda { |exception|
      assert_equal 'bind argument must be an instance of MyColorizer', exception.message
    }) do
      "whatever".mcall(MyColorizer, :colorize, :blue)
    end
    # self actually has to *be* a MyColorizer for this to work... which severely limits the usefulness of mcall...
    # Since the whole reason we want this is because we don't want to simply mix in MyColorizer into the base class...
  end

  module ClassSystem
    def self.included(base)
      base.class_eval do
        alias_method_chain :class, :class_system
      end
    end
    def class_with_class_system()
      1<2 ? 'lower' : 'middle'
    end
  end

  def test_1
    assert_equal "classy", "me".class
    # The main use for this would be to call "original" implementations provided by Kernel or some other base module that you can be pretty sure is an ancestor of self...
    assert_contains String.ancestors, Kernel
    assert_equal String,  "me".mcall(Kernel, :class)
  end

  def test_2_after_doing_alias_method_chain
    String.class_eval do
      #remove_method :to_s
      include ClassSystem
    end
    assert_equal "lower",  "me".class                       # Version 3
    assert_equal "classy", "me".class_without_class_system  # Version 2
    assert_equal String,   "me".mcall(Kernel, :class)       # Version 1
  end

end
=end

