#--
# Credits::
# * Daniel Lucraft (http://www.daniellucraft.com/blog/2007/08/null-objects/) -- for the idea
# * Tyler Rick -- Re-wrote it more simply so that the method_missing was in NilClass directly; packaged it, added some documention, and added some tests
# Copyright:: Tyler Rick
# License::   Ruby License
# Submit to Facets?:: No
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))

class NilClass
  # This allows you to call undefined methods on nil without an exception being raised.
  #
  # This gives us a much conciser alternative to this common pattern:
  #   might_be_nil ? might_be_nil.some_method : nil
  # or
  #   (might_be_nil && might_be_nil.some_method)
  #
  # ... where might_be_nil is something that you hope is not nil most of the time, but which may on accosion be nil (and when it is, you don't want an exception
  # to be raised!).
  #
  # For example, accessing a key from a hash:
  #   (hash[:a] && hash[:a][:b] && hash[:a][:b].some_method)
  #
  # With NilClass#method_missing, that simply becomes
  #   hash[:a][:b].some_method)
  #
  # The caveat with this approach is that it requires changing the behavior of a core class, NilClass, which could potentially have undesirable effects on
  # code that expects the original behavior. Don't require this file unless you are sure that you want *all* nils everywhere to have this behavior.
  #
  # For a safer alternative that doesn't require monkey-patching NilClass, consider using the _? method.
  #
  def method_missing(*args)
    nil
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

class TheTest < Test::Unit::TestCase

  def test_simple__nil
    hash = {}
    assert_equal nil,      hash[:a].length
  end
  def test_simple__normal_objects
    hash = {:a => 'abc'}
    assert_equal 3,        hash[:a].length
  end

  def test_chaining
    hash = {}

    assert_equal nil, hash[:a].length * 4
    assert_equal nil, hash[:a][:b][:c]
    assert_equal nil, hash[:a][:b][:c].some_method
  end

end
=end


# Alternative version #1:
# (See note in safe_nil.rb -- this version fails the test_does_not_permanently_modify_nil_class test)
=begin
class NilClass
  def __?
    n = nil
    def n.method_missing(*args)
      __?
    end
    n
  end
end
=end


# Alternative version #2:
# Another attempt, which doesn't require modifying NilClass ... but I found it didn't work as well as one might hope... :
=begin
# The __? method just returns the object itself for all objects except for nil. For nil, __? will return a special version of nil that lets you call undefined
# methods.
#
# If you call an undefined method on nil._?, you will get back an instance of ChainableSafeNil -- rather than raising an exception, which is what would 
# happen if you called the same method on a _plain_ old nil.
#
# __? gives us a much conciser alternative to this common pattern:
#   might_be_nil ? might_be_nil.some_method : nil
# or
#   (might_be_nil && might_be_nil.some_method)
#
# ... where might_be_nil is something that you hope is not nil most of the time, but which may on accosion be nil (and when it is, you don't want an exception
# to be raised!).
#
# For example, accessing a key from a hash:
#   (hash[:a] && hash[:a][:b] && hash[:a][:b].some_method)
#
# With __?, that simply becomes
#   hash[:a].__?[:b].some_method)
#
# Unfortunately, this idea fails in two ways:
# * nil.__?.whatever will return an instance of ChainableSafeNil, which means you may end up with ChainableSafeNil objects as values of variables and arguments
#   in your code... which seems messy, undesirable, and undefined (Should ChainableSafeNil act like nil? Should it evaluate to false like nil does? Good luck
#   with that...)
# * If something evaluates to nil further on down the chain, after the __?, then all method calls to that nil will be unsafe. For example:
#   hash = { :a => {} }
#   hash[:a].__?[:b][:c]) => NoMethodError
#
# Conclusion: Chaining is impossible -- Just use _? on any object that might return nil (on which you want to call a method).


require 'singleton'
require 'rubygems'
require 'facets/more/basicobject'


class Object
  def __?
    self
  end
end

class NilClass
  def __?
    ChainableSafeNil.instance
  end
end

class ChainableSafeNil < BasicObject
  include Singleton

  def inspect
    "ChainableSafeNil"
  end

  def method_missing(method, *args, &block)
    #puts "nil.respond_to?(method)=#{nil.respond_to?(method)}"
    return ChainableSafeNil.instance  unless nil.respond_to?(method)
    nil.send(method, *args, &block) rescue ChainableSafeNil.instance
  end

  def ==(other)
    #other.nil?
    raise "Why on earth is this line never getting executed?? And yet if I remove this method entirely, equality breaks"
  end

  def nil?; true; end
end





class TheTest < Test::Unit::TestCase

  def test_simple__nil
    hash = {}
    assert_equal ChainableSafeNil.instance, hash[:a].__?.length
  end
  def test_simple__normal_objects
    hash = {:a => 'abc'}
    assert_equal 3,        hash[:a].__?.length
  end

  def test_chaining
    hash = {}

    assert_raise(NoMethodError)           { hash[:a]    .length * 4          }
    assert_raise(NoMethodError)           { hash[:a]    [:b][:c]             }
    assert_raise(NoMethodError)           { hash[:a]    [:b][:c].some_method }

    assert_equal ChainableSafeNil.instance, hash[:a].__?.length * 4
    assert_equal ChainableSafeNil.instance, hash[:a].__?[:b][:c]
    assert_equal ChainableSafeNil.instance, hash[:a].__?[:b][:c].some_method

    # But it needs to be chainable even if the *receiver* of __? isn't nil but something *later* down the chain is nil...
    # (in this example, hash[:a] isn't nil, but hash[:a][:b] is, making it unsafe to evaluate hash[:a][:b][:c])
    hash = { :a => {} }
    assert_raise(NoMethodError)           { hash[:a]    [:b]    [:c] }
    # Unfortunately, I don't know any way to make that possible!!!
    assert_raise(NoMethodError)           { hash[:a].__?[:b]    [:c] }
    # So one is left with calling __? for *anything* that might be nil...
    assert_equal ChainableSafeNil.instance, hash[:a].__?[:b].__?[:c]
    # ... which is what we were trying to avoid having to do! This means __? is *not* chainable and we may as well use the plain old _? / SafeNil.
    # We have failed as programmers and may as well go home in shame.
  end


  def test_inspect
    assert_equal 'ChainableSafeNil', nil.__?.inspect
  end

  def test_nil?
    assert ChainableSafeNil.instance.nil?
  end

  def test_equality
    assert_equal ChainableSafeNil.instance, ChainableSafeNil.instance
    assert       ChainableSafeNil.instance.eql?( nil.__?.length )
    assert       ChainableSafeNil.instance == nil.__?.length

    assert ChainableSafeNil.instance == nil
    # But:
    assert nil != ChainableSafeNil.instance

    # Why isn't this true?? Which == is getting called here?
    #assert ChainableSafeNil.instance.send(:==, ChainableSafeNil.instance)
  end

  def test_does_not_permanently_modify_nil_class
    assert_raise(NoMethodError) { nil.foo }
    nil.__?
    assert_raise(NoMethodError) { nil.foo }
  end
end
=end

