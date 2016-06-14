#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# * Add depth argument to inspect()? 
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'facets/module/alias_method_chain'

class Exception
  # Use this if you want to output an exception with all the details that you'd *normally* see if the exception went unrescued
  # (since exception.inspect/p exception doesn't provide a backtrace!) 
  #
  # This is mostly useful if you rescue an exception, want to print or log it and then re-raise it...
  #
  # Use inspect_without_backtrace if you want to access the previous behavior (<tt>#<MissingSourceFile: no such file to load -- whatever></tt>).
  #
  def inspect_with_backtrace
    exception.class.name + ": " + exception.message + "\n" +
      exception.backtrace.map {|v| '  ' + v}.join( "\n" )
  end
  alias_method_chain :inspect, :backtrace
end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'
require 'facets/ruby' # lines

class TheTest < Test::Unit::TestCase
  def raise_an_error(arg = nil)
    raise ArgumentError, "You passed in the wrong argument!" 
  end
  def test_1
    begin
      raise_an_error
    rescue ArgumentError => exception
      #puts exception.inspect
      assert_equal 'ArgumentError: You passed in the wrong argument!', exception.inspect.lines[0]
      assert_match /[^:]+:\d+:in `raise_an_error'/, exception.inspect.lines[1]
      assert exception.inspect.lines.size > 3
    end
  end

end
=end


=begin
Sightings of other exception -> string formatters

log4r/formatter/formatter.rb
        return "Caught #{obj.class}: #{obj.message}\n\t" +\
               obj.backtrace[0...@depth].join("\n\t")

=end
