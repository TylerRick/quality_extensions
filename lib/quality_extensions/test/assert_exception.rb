#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

require 'test/unit'
class Test::Unit::TestCase

  # Used when you want to make assertions *about* an assertion that you expect to be raised. (With the built-in assert_raise()
  # you can only assert *that* a particular class of exception is raised, not any specifics about it.
  #
  # Before:
  #
  #    exception = nil
  #    assert_raises(ArgumentError) { SomeCommand.execute("foo '''") }
  #    begin
  #      SomeCommand.execute("foo -m '''")
  #    rescue Exception => _exception
  #      exception = _exception
  #    end
  #    assert_equal "Unmatched single quote: '", exception.message
  #
  # After:
  #
  #    assert_exception(ArgumentError, lambda { |exception|
  #      assert_match /Unmatched single quote/, exception.message
  #    }) do
  #      SomeCommand.execute("foo -m 'stuff''")
  #    end
  #
  def assert_exception(expected_class, additional_expectations = nil, &block)
    exception = nil
    assert_raise(expected_class) do
      begin
        yield
      rescue Exception => _exception
        exception = _exception
        raise
      end
    end
    additional_expectations.call(exception) if additional_expectations
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
    assert_exception(RuntimeError, lambda { |exception|
      assert_match /est/, exception.message
    }) do
      raise "Test"
    end
  end
end
=end

