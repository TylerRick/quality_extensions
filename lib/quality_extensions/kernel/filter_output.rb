#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes:
#++

require 'stringio'

# Applies +filter+ to any $stderr output that +block+ tries to generate.
#
# +filter+ should be a Proc that accepts +attempted_output+ as its parameter and returns the string that should _actually_ be output.
#
#   filter_stderr(lambda{''}) do
#     noisy_command
#   end
def filter_stderr(filter, &block)
  old_stderr = $stderr
  $stderr = StringIO.new
  begin
    yield
  ensure
    what_they_tried_to_output = $stderr.string
    $stderr = old_stderr
    $stderr.print filter.call(what_they_tried_to_output)
  end
end
def filter_stdout(filter, &block)
  old_stderr = $stdout
  $stdout = StringIO.new
  begin
    yield
  ensure
    what_they_tried_to_output = $stdout.string
    $stdout = old_stderr
    $stdout.print filter.call(what_they_tried_to_output)
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

# Not sure whether it's better to duplicate for increased readability here or metaprogram for decreased duplication...

# Duplicate for increased readability:
  def noisy_command
    $stderr.puts "Some annoying error message"
    $stderr.puts "Some error message that we actually care to see"
  end
  class TheTest < Test::Unit::TestCase
    def setup
      $stderr = StringIO.new
    end
    def test_simple_filter
      filter_stderr(lambda{|input| ''}) do
        noisy_command
      end
      assert_equal '', $stderr.string
    end
    def test_sub_filter
      filter_stderr(Proc.new { |attempted_output|
          attempted_output.sub(/^Some annoying error message\n/, '')
        }
      ) do
        noisy_command
      end
      assert_equal "Some error message that we actually care to see\n", $stderr.string
    end
  end

# Metaprogram for decreased duplication...
  ['stdout', 'stderr'].each do |stream_name|
    eval <<-End, binding, __FILE__, __LINE__+1
    def noisy_command_#{stream_name}
      $#{stream_name}.puts "Some annoying error message"
      $#{stream_name}.puts "Some error message that we actually care to see"
    end

    class TheTest#{stream_name} < Test::Unit::TestCase
      def setup
        $#{stream_name} = StringIO.new
      end
      def test_simple_filter
        filter_#{stream_name}(lambda{|input| ''}) do
          noisy_command_#{stream_name}
        end
        assert_equal '', $#{stream_name}.string
      end
      def test_sub_filter
        filter_#{stream_name}(Proc.new { |attempted_output|
            attempted_output.sub(/^Some annoying error message\n/, '')
          }
        ) do
          noisy_command_#{stream_name}
        end
        assert_equal "Some error message that we actually care to see\n", $#{stream_name}.string
      end
    end
    End
  end
=end
