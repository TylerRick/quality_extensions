#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'escape'    # http://www.a-k-r.org/escape/
require 'facets/symbol/to_proc'
require 'facets/kernel/require_relative'

class String
  def shell_escape
    Escape.shell_command([self])
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
  # Use `echo` command to test integrity all the way to a command and back out the other side.
  def assert_that_echo_gives_back_what_we_put_in(input)
    input = %q{!&'"`$0 |()<>}
    output = `echo -n #{input.shell_escape}`
    assert_equal input, output
  end
  def test_using_echo_1
    assert_that_echo_gives_back_what_we_put_in(
      %q{!&'"`$0 |()<>} )
  end
  def test_using_echo_2
    assert_that_echo_gives_back_what_we_put_in(
      %q{'an arg that's got "quotes"} )
  end

  # Escape has changed its behavior in newer versions. It wants to return it as type Escape::ShellEscaped.
#  def test_type
#    assert_equal Escape::ShellEscaped, 'a'.shell_escape.class
#    assert_equal 'a', 'a'.shell_escape.to_s
#  end
end
=end

