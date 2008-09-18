#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
#++

require 'test/unit'

class Test::Unit::TestCase
  # Lets you make an assertion out of any method, without having to write a new assert_ method for it!
  #
  # So as long as the +whatever+ method's return value can be interpreted as a boolean value, you can simply call
  # <tt>assert_whatever a, b</tt>, which will be equivalent to calling <tt>assert a.whatever(b)</tt>
  #
  # Follow this basic pattern:
  #   assert_{method} {receiver}, {args}
  #   assert_not_{method} {receiver}, {args}
  #   assert_{method}_is      {receiver}, {args}, {expected_return_value}
  #   assert_{method}_returns {receiver}, {args}, {expected_return_value}
  #
  # Examples:
  #   assert_include? [1, 2, 3], 2
  #   assert_not_include? [1, 2, 3], 4
  #   assert_class_is 'foo', String
  #
  def method_missing(name, *args)
    # to do: 
    #   options = args.pop if args.last.is_a?(Hash)
    #   message = options[:message]
    if name.to_s =~ /^assert_(.*)/
      receiver = args.shift
      negated = false
      message_to_pass = $1

      if name.to_s =~ /^assert_(.*)_is/
        message_to_pass = $1
        expected = args.pop
        if name.to_s =~ /^assert_(.*)_is_not/
          message_to_pass = $1
          negated = true
        end

        result = receiver.send(message_to_pass, *args)
        if negated
          assert_not_equal expected, result
        else
          assert_equal expected, result
        end
      else
        if name.to_s =~ /^assert_not_(.*)|assert_(.*)_is_not/
          message_to_pass = $1
          negated = true
        end

        result = receiver.send(message_to_pass, *args)
        result = !result if negated
        assert result
      end

    else
      super
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
  def test_1
    assert_include? [1, 2, 3], 2
    assert_not_include? [1, 2, 3], 4
  end
  def test_is
    assert_class_is 'foo', String
    assert_class_is_not ['foo'], String
  end

end
=end


