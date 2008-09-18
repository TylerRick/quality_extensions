#--
# Author::    Trans?
# Copyright:: Copyright (c) Trans?
# License::   Ruby License
# Submit to Facets?:: No. Copied from facets-1.8.54/lib/facets/core/hash/assert_has_only_keys.rb. No longer exists in 2.4.1.
# Developer notes::
#++

class Module

  # Automatically create an initializer assigning the given 
  # arguments.
  #
  #   class MyClass
  #     initializer(:a, "b", :c)
  #   end
  #
  # _is equivalent to_
  #
  #   class MyClass
  #     def initialize(a, b, c)
  #       @a,@b,@c = a,b,c
  #     end
  #   end
  #
  # Downside: Initializers defined like this can't take blocks.
  # This can be fixed when Ruby 1.9 is out.
  #
  # The initializer will not raise an Exception when the user
  # does not supply a value for each instance variable. In that
  # case it will just set the instance variable to nil. You can
  # assign default values or raise an Exception in the block.
  #
  def initializer(*attributes, &block)
    define_method(:initialize) do |*args|
      attributes.zip(args) do |sym, value|
        instance_variable_set("@#{sym}", value)
      end

      instance_eval(&block) if block
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

  class TCModule < Test::Unit::TestCase

    def test_attr_initializer
      cc = Class.new
      cc.class_eval {
        initializer :ai
        attr_reader :ai
      }
      c = cc.new(10)
      assert_equal( 10, c.ai )
    end

  end

=end
