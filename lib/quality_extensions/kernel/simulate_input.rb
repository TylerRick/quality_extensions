#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes:
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'stringio'

# Simulates a user typing in +input_string+ on the keyboard.
#
# Useful for testing console apps that are ordinarily (they prompt the user for input).
#
#   output = simulate_inpute('foo') do
#     input = $stdin.gets
#     capture_output { do_stuff() }
#   end
#
def simulate_input(input_string, &block)

  original_stdin = $stdin
  $stdin = StringIO.new(input_string, 'r')

  begin
    yield
  rescue Exception
    raise
  ensure
    $stdin = original_stdin
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
    input_received = nil
    simulate_input('foo') { input_received = $stdin.getc.chr }
    assert_equal 'f', input_received
  end
end
=end
