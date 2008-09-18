#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

module Kernel
  # Calling <tt>Kernel#trap()</tt> by itself will _replace_ any previously registered handler code.
  # <tt>Kernel#trap_chain()</tt>, on the other hand, will _add_ the block you supply to the existing "list" of registered handler blocks.
  # Similar to the way <tt>Kernel#at_exit()</tt> works, <tt>Kernel#trap_chain()</tt> will _prepend_ the given +block+ to the call chain for the given +signal_name+.
  # When the signal occurs, your block will be executed first and then the previously registered handler will be invoked. This can be called repeatedly to create a "chain" of handlers.
  def trap_chain(signal_name, *args, &block)
    previous_interrupt_handler = trap(signal_name, *args) {}
    trap(signal_name, *args) do
      block.call
      previous_interrupt_handler.call unless previous_interrupt_handler == "DEFAULT"
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
require 'rubygems'
require 'quality_extensions/kernel/capture_output'
require 'fileutils'

class TheTest < Test::Unit::TestCase
  def setup
    FileUtils.touch('trap_chain_test_output')
  end
  def teardown
    FileUtils.remove_entry_secure 'trap_chain_test_output'
  end

  def test_1
    output = capture_output do    # For some reason, this wasn't capturing the output from the child process when I did plain puts, so I changed it to write to a file instead...

      pid = fork do
        trap_chain("INT") { File.open('trap_chain_test_output', 'a') {|file| file.puts "Handler 1" } }
        trap_chain("INT") { File.open('trap_chain_test_output', 'a') {|file| file.puts "Handler 2"; file.puts "Exiting..."; }; exit }
        trap_chain("INT") { File.open('trap_chain_test_output', 'a') {|file| file.puts "Handler 3" } }
        puts 'Hello world'
        sleep 5
      end
      Process.kill "INT", pid
      Process.wait

    end

    assert_equal "Handler 3\nHandler 2\nExiting...\n", File.read('trap_chain_test_output')
  end

end
=end

