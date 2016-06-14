#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No.
# Deprecated. Because I discovered Kernel::abort !
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
module Kernel
  def die(message, exit_code = 1)
    $stderr.puts message
    exit exit_code
  end
end

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'test/unit'
require 'quality_extensions/kernel/capture_output'
#require_relative './capture_output'

class TheTest < Test::Unit::TestCase

  def test_1
    stderr = capture_output $stderr do
      assert_raise(SystemExit) do
        die "Aggh! I'm dying!"
      end
    end
    assert_equal "Aggh! I'm dying!", stderr.chomp
  end

  def test_abort
    stderr = capture_output $stderr do
      assert_raise(SystemExit) do
        abort "Aggh! I'm dying!"
      end
    end
    assert_equal "Aggh! I'm dying!", stderr.chomp
  end

end
=end
