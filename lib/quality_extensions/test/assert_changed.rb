#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

require 'test/unit'
class Test::Unit::TestCase

  # Asserts that the block that is passed in causes the value of the specified variable (+variable+) to change.
  # +variable+ should be a Proc that, when evaluated, returns the current value of the variable. 
  #
  # Options:
  # * If the optional +:from+ option is supplied, it also asserts that it had that initial value.
  # * If the optional +:to+ option is supplied, it also asserts that it changed _to_ that value.
  #
  # So instead of doing this:
  #   assert_equal 1, Model.count
  #   do_something_that_should_cause_count_to_increase
  #   assert_equal 2, Model.count
  # we can do this:
  #   assert_changed(lambda {ErrorType.count}, :from => 1, :to => 2) do
  #     do_something_that_should_cause_count_to_increase
  #   end
  # Or, if we don't care what it's changing _from_ as long as it increases in value _by_ 1, we can write this:
  #   assert_changed(c = lambda {ErrorType.count}, :to => c.call+1) do
  #     do_something_that_should_cause_count_to_increase
  #   end
  # instead of this:
  #   before = Model.count
  #   do_something_that_should_cause_count_to_increase
  #   assert_equal before + 1, Model.count
  #
  def assert_changed(variable, options = {}, &block)
    expected_from = options.delete(:from) || variable.call

    assert_equal expected_from, variable.call

    failure_message = build_message(failure_message, "The variable was expected to change from <?> to <?> but it didn't", variable.call, options.delete(:to) || "something else")
    assert_block(failure_message) do
      before = variable.call
      yield
      expected_to = options.delete(:to) || variable.call
      before != variable.call and variable.call == expected_to
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
  end
end
=end


