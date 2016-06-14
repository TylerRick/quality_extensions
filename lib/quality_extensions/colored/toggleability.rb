#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
gem 'colored'
require 'colored'
gem 'facets'
require 'facets/module/alias_method_chain'
require 'quality_extensions/module/guard_method'

class String
  @@colorize_enabled = true   # Default to enabled
  def colorize_with_toggleability(string, options = {})
    if @@colorize_enabled
      colorize_without_toggleability(string, options)
    else
      string
    end
  end
  alias_method_chain :colorize, :toggleability
  mguard_method :color_on!, :@@colorize_enabled

end unless String.instance_methods.include?('colorize_with_toggleability')


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

class TheTest < Test::Unit::TestCase
  def test_color_on
    String.color_on!
    assert_equal "\e[31mfoo\e[0m", 'foo'.red
  end
  def test_color_off
    String.color_on! false
    assert_equal "foo", 'foo'.red
  end
  def test_color_off_with_block
    String.color_on!
    assert_equal "\e[31mfoo\e[0m", 'foo'.red
    String.color_on! false do
      assert_equal "foo", 'foo'.red
    end
    assert_equal "\e[31mfoo\e[0m", 'foo'.red
  end

end
=end


