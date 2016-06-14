#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

# :todo: Can we find a simpler way to do this based on facets' silence_stream?
  #
  # File lib/facets/kernel/silence_stream.rb, line 13
  #  def silence_stream(stream)
  #    old_stream = stream.dup
  #    stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
  #    stream.sync = true
  #    yield
  #  ensure
  #    stream.reopen(old_stream)
  #  end

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'stringio'
require 'facets/dictionary'

module Kernel

  # Captures the output (stdout by default) that +block+ tries to generate and returns it as a string.
  #
  #   output = capture_output($stderr) { noisy_command }
  #
  #   output = capture_output([$stdout, $stderr]) do
  #     noisy_command
  #   end
  #
  # *Note*: If you specify more than one output stream, the entire results of each will be concatenated <i>in the order you listed them</i>, not necessarily in the order that you wrote _to_ those streams.
  def capture_output(output_streams = $stdout, &block)
    output_streams = [output_streams] unless output_streams.is_a? Array
    
    saved_output_streams = Dictionary.new
    output_streams.each do |output_stream|
      case output_stream.object_id
        when $stdout.object_id
          saved_output_streams[:$stdout] = $stdout
          $stdout = StringIO.new
        when $stderr.object_id
          saved_output_streams[:$stderr] = $stderr
          $stderr = StringIO.new
      end
    end

    what_they_tried_to_output = '' 
    begin
      yield
    rescue Exception
      raise
    ensure
      saved_output_streams.each do |name, output_stream|
        case name
          when :$stdout
            what_they_tried_to_output += $stdout.string
          when :$stderr
            what_they_tried_to_output += $stderr.string
        end

        # Restore the original output_stream that we saved.
        case name
          when :$stdout
            $stdout = saved_output_streams[:$stdout]
          when :$stderr
            $stderr = saved_output_streams[:$stderr]
        end
      end
    end
    return what_they_tried_to_output
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

def noisy_command
  puts "Some lovely message"
  $stderr.puts "Some lovely error message"
end
def noisy_command_with_error
  puts "Some lovely message"
  $stderr.puts "Some lovely error message"
  raise 'an error'
end

class TheTest < Test::Unit::TestCase
  def test_capture_all
    assert_equal "Some lovely message\nSome lovely error message\n", capture_output([$stdout, $stderr]) { noisy_command }
  end
  def test_capture_all__different_order
    # This is, I suppose a limitation of StingIO. This behavior may change in a future version if a workaround is found. (Creating a new IO subclass, +TimestampedStringIO+, that keeps a timestamp for every thing you add to it so that the results of two such objects can be merged to yield chronological output.)
    assert_equal "Some lovely error message\nSome lovely message\n", capture_output([$stderr, $stdout]) { noisy_command }
  end
  def test_capture_stdout
    assert_equal "Some lovely message\n", capture_output($stdout) { noisy_command }
  end
  def test_capture_stderr
    assert_equal "Some lovely error message\n", capture_output($stderr) { noisy_command }
  end
  def test_when_an_error_is_raised_from_block
    assert_raise(RuntimeError) { capture_output() { noisy_command_with_error } }
  end
end
=end
