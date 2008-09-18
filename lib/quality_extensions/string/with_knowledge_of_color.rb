#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

module WithKnowledgeOfColor
  Color_regexp = /\e\[[^m]+m/

  def strip_color
    gsub(Color_regexp, '')
  end

  # This version of +length+ takes into account the fact that the ANSI color codes themselves don't take up any space to display on the screen.
  # So this returns the number of characters wide the string is when it is actually printed to the screen.
  def length_without_color
    strip_color.length
  end

  def nonprinting_characters_used_for_color
    self.scan(Color_regexp).join
  end

  def ljust_with_color(width, padstr=' ')
    #ljust(width + nonprinting_characters_used_for_color.length, padstr)
    # That didn't work when you wanted the padstr to have color (as in ' '.on_blue)

    self + padstr*(width - length_without_color)
  end

  def rjust_with_color(width, padstr=' ')
    padstr*(width - length_without_color) + self
  end
end

class String
  include WithKnowledgeOfColor
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
gem 'colored'
require 'colored'

class TheTest < Test::Unit::TestCase
  def test_strip_color
    assert       "abc" != "abc".blue
    assert_equal "abc",   "abc".blue.strip_color
  end
  def test_length_without_color
    assert_equal 12, "abc".blue.length
    assert_equal 3,  "abc".blue.length_without_color
  end
  def test_nonprinting_characters_used_for_color
    assert_equal "\e[34m\e[0m", 'abc'.blue.nonprinting_characters_used_for_color
  end
  def test_ljust_with_color
    assert_equal "abc  ", 'abc'.     ljust(              5)
    assert_equal "abc  ", 'abc'.blue.ljust_with_color(5).strip_color
    assert_equal "\e[34mabc\e[0m  ", 'abc'.blue.ljust_with_color(5)
    assert_equal "\e[34mabc\e[0m\e[44m \e[0m\e[44m \e[0m", 'abc'.blue.ljust_with_color(5, ' '.on_blue)
  end
  def test_rjust_with_color
    assert_equal "  abc", 'abc'.     rjust(              5)
    assert_equal "  abc", 'abc'.blue.rjust_with_color(5).strip_color
    assert_equal "  \e[34mabc\e[0m", 'abc'.blue.rjust_with_color(5)
    assert_equal "\e[44m \e[0m\e[44m \e[0m\e[34mabc\e[0m", 'abc'.blue.rjust_with_color(5, ' '.on_blue)
  end

end
=end
