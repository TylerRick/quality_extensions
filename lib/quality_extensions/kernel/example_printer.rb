#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# * Can anyone think of a better name than put_statement or stp?
#   * Something more like xmp (eXaMple_Put)...  sp? stp? xm? putst? -- Too cryptic?
#   * verbose? -- too ambiguous (that could be the name for xmp, for example)
# * xmp: Do the set_trace_func trick that irb_xmp/of_caller both use... so that the user doesn't have to pass in the local binding manually...
# * Add class method for ExamplePrinter to set a template for use by xmp? So if you don't like the default ("=> #{result}"), you can specify your own...
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'quality_extensions/module/attribute_accessors'
#require 'facets/binding/self/of_caller'

# This was written because the irb/xmp that was already available seemed to be
# needlessly complex and needlessly dependent upon "irb" stuff. This
# alternative is dirt simple, and it still works.
module ExamplePrinter
  # Prints the given statement (+code+ -- a string) before evaluating it.
  # Same as xmp only it doesn't print the return value. Is it instead of xmp when the return value isn't interesting or might even be distracting to the reader.
  #
  #   o = nil
  #   put_statement 'o = C.new', binding
  #   # Outputs:
  #   # o = C.new
  def put_statement(code, binding = nil, file = __FILE__, line = __LINE__)

    # We'd like to be able to just use the binding of the caller without passing it in, but unfortunately I don't know how (yet)...
    ## This didn't work. Still got this error: undefined local variable or method `x' for #<TheTest:0xb7dbc358> (NameError)
    #Binding.of_caller do |caller_binding|
    #  #puts caller_binding
    #  puts code
    #  eval code, caller_binding
    #end

    puts code
    eval code, binding, file, line
  end
  alias_method :stp, :put_statement


  # Prints the given statement (+code+ -- a string) before evaluating it. Then prints its return value.
  # Pretty much compatible with irb/xmp. But you have currently have to pass
  # in the binding manually if you have any local variables/methods that xmp
  # should have access to.
  #
  #   o = nil
  #   xmp '3 + x', binding
  #   # Outputs:
  #   # 3 + x
  #   # => 4
  def xmp(code, binding = nil, options = {})
    result = put_statement(code, binding)
    puts "=> #{result}"
  end
end

include ExamplePrinter

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
require 'facets/string/tab'

class TheTest < Test::Unit::TestCase
  def test_puts_statement
    result = nil
    x = 1
    output = capture_output { result = put_statement("3 + x", binding) }
    assert_equal 4, result
    assert_equal "3 + x", output.chomp
  end
  def test_xmp
    x = 1
    output = capture_output { xmp("3 + x", binding) }
    assert_equal <<-End.margin, output.chomp
      |3 + x
      |=> 4
    End
  end
end
=end
