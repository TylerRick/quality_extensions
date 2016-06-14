#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 the Rails people; QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
gem 'facets'
require 'facets/module/alias_method_chain'
require 'facets/kernel/singleton_class'


class Module

  def alias_method_chain_with_prevent_repeat_aliasing(target, feature, &block)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.

    aliased_target, punctuation = target.to_s.sub(/([?!])$/, ''), $1
    target_without_feature = "#{aliased_target}_without_#{feature}#{punctuation}"

    #puts "#{target} is #{method_defined?(target)}"
    alias_method_chain_without_prevent_repeat_aliasing(target, feature, &block) unless method_defined?(target_without_feature)
  end
  alias_method_chain :alias_method_chain, :prevent_repeat_aliasing

  # If you pass <tt>:create_target => true</tt> as one of the +options+:
  # * Guarantees that <tt>alias_method_chain target, feature</tt> will work even if the target method has not been defined yet.
  #   If the target method doesn't exist yet, an empty (no-op) target method will be created.
  # * This could come in handy for callback methods (method_added, method_missing, etc.), for instane, when you don't know if that
  #   particular callback method has been defined or not.
  # * You want your alias_method_chain to wrap the existing method if there *is* an existing method, but to <b>not break</b> in 
  #   the case that the method _doesn't_ exist.
  def alias_method_chain_with_target_need_not_exist(target, feature, options = {}, &block)
    create_target = options.delete(:create_target)
    
    if create_target && true #!self.methods.include?(target)
      self.send :define_method, target do |*args|
        # Intentionally empty
      end
    end

    alias_method_chain_without_target_need_not_exist(target, feature, &block)
  end
  alias_method_chain :alias_method_chain, :target_need_not_exist
end



=begin test
require 'test/unit'

class Test_alias_method_chain_basic < Test::Unit::TestCase

  class X
    def foo?
      'foo?'
    end
    def foo_with_feature?
      foo_without_feature? + '_with_feature'
    end
  end

  def test_question_mark
    name, punctuation = nil, nil
    X.instance_eval do
      alias_method_chain :foo?, :feature do |a, b|
        name, punctuation = a, b
      end
    end

    assert_equal 'foo?_with_feature', X.new.foo?
    assert_equal 'foo', name
    assert_equal '?', punctuation
  end

  class Y
    def foo!
      'foo!'
    end
    def foo_with_feature!
      foo_without_feature! + '_with_feature'
    end
  end

  def test_exclamation_mark
    name, punctuation = nil, nil
    Y.instance_eval do
      alias_method_chain :foo!, :feature do |a, b|
        name, punctuation = a, b
      end
    end

    assert_equal 'foo!_with_feature', Y.new.foo!
    assert_equal 'foo', name
    assert_equal '!', punctuation
  end

end

class Test_alias_method_chain_with_prevent_repeat_aliasing < Test::Unit::TestCase

  class X
    def foo
      'foo'
    end
    def foo_with_feature
      foo_without_feature + '_with_feature'
    end
    alias_method_chain :foo, :feature
    alias_method_chain :foo, :feature   # We want to test that this won't cause an infinite recursion (stack overflow).
  end

  def test_1
    assert_equal 'foo_with_feature', X.new.foo
  end

end


class Test_alias_method_chain_with_target_need_not_exist < Test::Unit::TestCase

  # Let's assume that we are *re*-opening X here, and at this point we *don't know* if it has a foo method or not.
  # Also, we *don't want to care*. We just want to add to the chain if the method exists, or *create* the chain
  # if it does not yet.
  class X
    def foo_with_feature
      # *Don't* do this if you're using :create_target => true:
      #   foo_without_feature + '_with_feature'
      # If you're using :create_target => true, then you are pretty much saying "I don't know anything about thhe target method".
      # Yet the previous statement shows that you expect it to return a String. You can't do that. You can't pretend to know
      # anything about it's return value. It will always be nil if alias_method_chain created an empty method for you.
      # But, it may be something else if it already existed and alias_method_chain did *not* create an empty method for you.

      # The safest thing to do is to just call it and pay not attention to its return value. (Or at least *consider* the
      # possibility that it may be nil.)

      foo_without_feature
      'feature was successfully added'
    end
    alias_method_chain :foo, :feature, :create_target => true
  end

  def test_1
    assert_equal 'feature was successfully added', X.new.foo
    assert_equal 'feature was successfully added', X.new.foo { 'test that it works with a block' }
  end
end
=end
