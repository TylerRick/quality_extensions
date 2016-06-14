#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe.
# Developer notes::
# * Method name too long? Imagine if we wanted to string multiple calls together.
#   * Ideas:
#     * single_send
#     * singleton_send
#     * singleton_call
#     * singleton
#     * singsend
#     * extend_send
#     * extend_call
#     * create_and_send
#     * create_and_call
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

class Object

  # Creates a singleton method and then calls it.
  #
  # More specificaly, it <tt>extend</tt>s +self+ with the methods from +moduule+ and then sends the supplied +message+ and +args+ (if any).
  #
  # Examples:
  #   "whatever".ss(MyColorizer, :colorize, :blue)
  #
  # Advantages:
  # * Keeps things object-oriented. Better than having global/class methods.
  #   * (<tt>"whatever".ss(MyColorizer, :colorize).ss(SomeOtherClass, :another_class_method)</tt> instead of 
  #     * <tt>SomeOtherClass::another_class_method(MyColorizer::colorize("whatever"))</tt>)
  #   * Method calls are _listed_ in the order in which they are _called_.
  # * Still lets you keep your methods in a namespace.
  # * Doesn't clutter up the base classes with methods that are only useful within a very small context. The methods are only added to the objects you specify. So you can "use" the base class <b>without cluttering up _all_ instances of the class with your methods</b>.
  # * Useful for cases where creating a subclass wouldn't help because the methods you are calling would still return instances of the base class.
  #
  # Disadvantages:
  # * You have to have/create a *module* for the functions you want to use.
  #   * Can't just call .sigleton_send(self, :some_method) if you want to use +some_method+ that's defined in +self+.
  #   * So what do we call the module containing the "singleton method"? String::MyColorizer? MyColorizer::String? MyStringColorizer?
  #
  # Adding methods to the base class using Facets' own *namespacing* facilities (Module#namespace and Module#include_as)
  # might actually be a more sensible alternative a lot of the time than bothering to create singleton methods for single objects!
  # That would look somethig like:
  #
  #   class String
  #     namespace :my_colorizer do
  #       def colorize(...); ...; end
  #     end
  #   end
  #   "whatever".my_colorizer.colorize(:blue)
  #
  # or
  #
  #   class String
  #     include_as :my_colorizer => MyColorizer
  #   end
  #   "whatever".my_colorizer.colorize(:blue)
  #
  def singleton_send(moduule, message, *args, &block)
    self.extend(moduule)
    self.send(message, *args, &block)
  end
  alias_method :ss, :singleton_send

  # Couldn't get this idea to work:
#  def singleton_that_accepts_object(object, method_name, *args)
##    #class << self 
##    #self.instance_eval do
##    self.class.module_eval do
##      define_method(:colorize2, object.class.instance_method(:colorize2))
##    end
##    # raises "TypeError: bind argument must be an instance of TheTest"
#
##    object.class.instance_method(method_name).
##      bind(self)
##    # raises "TypeError: bind argument must be an instance of TheTest"
#
##    self.class.extend(object.class)
##    self.class.send(:include, object.class)
##    # raises "TypeError: wrong argument type Class (expected Module)"
#    self.send(method_name, *args)
#  end

end

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'
require 'quality_extensions/test/assert_exception'
require 'quality_extensions/test/assert_includes'


module MyColorizer
  def colorize(color = nil)
    self + " (colorized in #{color})"
  end
end

#module PresentationLayer
#  create_module_method :to_currency do
#    #...
#  end
#end


class TheTest1_UsingSingletonSend < Test::Unit::TestCase
  def test_using_singleton_send
    assert_equal "whatever (colorized in )",     "whatever".ss(MyColorizer, :colorize)
    assert_equal "whatever (colorized in blue)", "whatever".ss(MyColorizer, :colorize, :blue)
  end

#  def test_singleton_that_accepts_object
#    assert_equal "whatever (colorized in )", "whatever".singleton_that_accepts_object(self, :colorize2)
#    assert_equal "whatever (colorized in blue)", "whatever".singleton_that_accepts_object(self, :colorize2, :blue)
#  end
#  def colorize2(color = nil)
#    self + " (colorized2 in #{color})"
#  end
end
=end

