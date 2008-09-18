#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Not sure. This might not be necessary if caller() actually works reliably.
#++


module Kernel
  # Equivalent to calling caller(0)
  def backtrace
    full_backtrace = caller(0)
    return full_backtrace[1..-1]    # We don't want this call to backtrace showing up in the backtrace, so skip top 1 frame.
  end

  # Returns a human-readable backtrace
  def pretty_backtrace
    "Backtrace:\n" +
      backtrace[1..-1].map{|frame| "* " + frame}.join("\n")
  end

  # I thought I ran into some case where it didn't work to use caller(0)...which prompted me to do it this way (raise and rescue an exception)...but now I can't duplicate that problem, so I will deprecate this method.
  def backtrace_using_exception
    begin
      raise "Where am I?"
    rescue Exception => exception
      full_backtrace = exception.backtrace
      return full_backtrace[1..-1]    # We don't want this call to backtrace showing up in the backtrace, so skip top 1 frame.
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
require "rubygems"
require "facets/string/lines"

class TheTest < Test::Unit::TestCase
  def test_1_level
    assert_match /^.*backtrace.rb:\d*:in `test_1_level'$/, backtrace[0]
    assert_match /^.*testcase.rb:\d*:in `__send__'$/, backtrace[1]
  end

  def test_pretty_backtrace
    assert_match /^Backtrace:$/, pretty_backtrace.lines[0]
    assert_match /^.*backtrace.rb:\d*:in `test_pretty_backtrace'$/, pretty_backtrace.lines[1]
    assert_match /^.*testcase.rb:\d*:in `__send__'$/, pretty_backtrace.lines[2]
  end

  def test_2_levels
    assert_match /^.*backtrace.rb:\d*:in `a_method_that_returns_a_backtrace'$/, a_method_that_returns_a_backtrace[0]
    assert_match /^.*backtrace.rb:\d*:in `test_2_levels'$/, a_method_that_returns_a_backtrace[1]
    assert_match /^.*testcase.rb:\d*:in `__send__'$/, a_method_that_returns_a_backtrace[2]
  end

  def a_method_that_returns_a_backtrace
    backtrace
  end

  def test_all_methods_of_getting_backtrace_are_equivalent
    assert_equal backtrace_using_exception, backtrace
    assert_equal backtrace_using_exception, caller(0)
  end

end
=end
