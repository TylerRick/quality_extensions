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
require 'builder/blankslate'
#require 'facets/basicobject'
#puts Object.methods.include?(:blank_slate_method_added) # not there?


class Object
  # not sure if receiver responds_to?
  def _r?(*args)
    if respond_to(args[0])
      send *args
    else
      nil
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

class TheTest < Test::Unit::TestCase
  def test_simple__nil
    hash = {}
    assert_equal nil,      hash[:a]._?.length
  end
  def test_simple__normal_objects
    hash = {:a => 'abc'}
    assert_equal 3,        hash[:a]._?.length
  end

  def test_chaining
    hash = {}
    assert_equal nil, hash[:a]._?.foo
    assert_equal nil, hash[:a]._?[:b]._?[:c]
    assert_equal nil, hash[:a]._?[:b]._?[:c]._?.some_method
  end

  def test_inspect
    assert_equal 'SafeNil', nil._?.inspect
  end

  def test_nil?
    assert SafeNil.instance.nil?
  end

  def test_does_not_permanently_modify_nil_class
    assert_raise(NoMethodError) { nil.foo }
    nil._?
    assert_raise(NoMethodError) { nil.foo }
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

