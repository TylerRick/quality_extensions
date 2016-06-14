#--
# Credits::
# * Tom Locke (http://hobocentral.net/blog/2007/08/25/quiz/) -- original version
# * coderrr (http://coderrr.wordpress.com/2007/09/15/the-ternary-destroyer/) -- some optimizations
# * Tyler Rick -- packaged it, added some documention, and added some tests
# Copyright:: ?
# License::   ?
# Submit to Facets?:: Yes
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'singleton'
#require 'facets/functor'
gem 'builder'
require 'builder/blankslate'
#require 'facets/basicobject'
#puts Object.methods.include?(:blank_slate_method_added) # not there?


class Object
  # If you are not sure if the receiver is nil?, you can prefix a method call / operation with _? to be safe. If the receiver is not nil, it will behave as if you'd called your method on the receiver directly.
  # If on the other hand the receiver is nil (see NilClass#_?), calling _? will cause an instance of SafeNil to be the *real* receiver, which will returns nil when you actually call whatever real method you are calling.
  def _?
    self
  end

  #def unless_blank?
  #  self
  #end
end

class NilClass
  # The _? method just returns the object itself for all objects except for nil. For nil, _? will return a special version of nil (actually, an instance of
  # SafeNil) that lets you call undefined methods.
  #
  # If you call an undefined method on nil._?, you will get back nil -- rather than raising an exception, which is what would happen if you called the same
  # method on a _plain_ old nil!
  #
  # _? gives us a much conciser alternative to this common pattern:
  #   might_be_nil ? might_be_nil.some_method : nil
  # or
  #   (might_be_nil && might_be_nil.some_method)
  #
  # ... where might_be_nil is something that you hope is not nil most of the time, but which may on occasion be nil (and when it is, you don't want an exception
  # to be raised!).
  #
  # For example, accessing a key from a hash:
  #   (hash[:a] && hash[:a][:b] && hash[:a][:b].some_method)
  #
  # With _?, that simply becomes
  #   hash[:a]._?[:b]._?.some_method)
  #
  def _?
    SafeNil.instance
  end
end

# http://railstips.org/blog/archives/2009/08/07/patterns-are-not-scary-method-missing-proxy/
class BasicObject #:nodoc:
  instance_methods.each { |m| undef_method m unless m =~ /^__|instance_eval/ }
end unless defined?(BasicObject)

# Extending BasicObject because it provides us with a clean slate. It is similar to Object except it has almost all the standard methods stripped away so that
# we will hit method_missing for almost all method routing.
#
# See NilClass#_?/Object#_?
class SafeNil < BasicObject
  include ::Singleton   # I assume this is because it's faster than instantiating a new object each time.

  # See NilClass#_?/Object#_?
  def method_missing(method, *args, &block)
    return nil  unless nil.respond_to?(method)      # A much faster alternative to 'rescue nil' that can be used most of the time to speed things up.
    nil.send(method, *args, &block) rescue nil
  end

  # See NilClass#_?/Object#_?
  def nil?; true; end
  def blank?; true; end
end





#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

class SafeNilTest < Test::Unit::TestCase
  def test_simple__nil
    hash = {}
    assert_equal nil,      hash[:a]._?.length
  end
  def test_simple__normal_objects
    hash = {:a => 'abc'}
    assert_equal 3,        hash[:a]._?.length
  end

  def test_to_s
    assert_equal '', nil._?.to_s
    assert_equal( {}.to_s, {}._?.to_s ) # this is '' in 1.8, '{}' in 1.9
    assert_equal [].to_s, []._?.to_s
  end

  def test_chaining
    hash = {}
    assert_equal nil, hash[:a]._?.foo
    assert_equal nil, hash[:a]._?[:b]._?[:c]
    assert_equal nil, hash[:a]._?[:b]._?[:c]._?.some_method
  end

  # As far as I know, this is impossible to get to pass, since by design an object in Ruby is *always* truthy unless it is false or nil
  #def test_or_ing
  #  assert_equal 'else', nil._? || 'else'
  #end

  def test_inspect
    assert_equal 'nil', nil._?.inspect
  end

  def test_does_not_permanently_modify_nil_class
    assert_raise(NoMethodError) { nil.foo }
    nil._?
    assert_raise(NoMethodError) { nil.foo }
  end

  def test_nil?
    assert SafeNil.instance.nil?
  end

  def test_blank?
    require 'facets/blank'
    assert nil.blank?
    assert SafeNil.instance.blank?
    assert ({1=>'a', 2=>'b'})[3]._?.blank?
  end
end

class UnlessBlankTest < Test::Unit::TestCase
  def test_simple__blank
    hash = {}
    assert_equal nil,      hash[:a]._?.length
  end
  def test_simple__normal_objects
    hash = {:a => 'abc'}
    assert_equal 3,        hash[:a]._?.length
  end

  def test_to_s
    assert_equal '', nil._?.to_s
    assert_equal( {}.to_s, {}._?.to_s ) # this is '' in 1.8, '{}' in 1.9
    assert_equal [].to_s, []._?.to_s
  end

  def test_chaining
    hash = {}
    assert_equal nil, hash[:a]._?.foo
    assert_equal nil, hash[:a]._?[:b]._?[:c]
    assert_equal nil, hash[:a]._?[:b]._?[:c]._?.some_method
  end

  def test_inspect
    assert_equal 'nil', nil._?.inspect
  end

  def test_does_not_permanently_modify_nil_class
    assert_raise(NoMethodError) { nil.foo }
    nil._?
    assert_raise(NoMethodError) { nil.foo }
  end

  def test_nil?
    assert SafeNil.instance.nil?
  end

  def test_blank?
    require 'facets/blank'
    assert nil.blank?
    assert SafeNil.instance.blank?
    assert ({1=>'a', 2=>'b'})[3]._?.blank?
  end

end
=end



# Alternative version #1:
# This version is so nice and simple -- I wish we could use it...
# The problem with this implementation, however, is that it causes NilClass to be permanently modified with this new method_missing behavior.
# In other words, once you call _? once on nil, all instances of nil will forever behave the same as nil._? !  (So you may as well just modify NilClass
# directly.)
# This might have to do with the fact that nil itself is a “singleton object” (according to http://corelib.rubyonrails.org/classes/NilClass.html)
# Proof:
#    puts nil.foo rescue p $!  # => <NoMethodError: undefined method `foo' for nil:NilClass>
#    nil._?
#    puts nil.foo rescue p $!  # => nil
# Too bad... it was so simple.
#
=begin
class NilClass
  def _?
    n = nil
    def n.method_missing(*args)
      nil
    end
    n
  end
end
=end

