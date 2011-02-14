#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/symbol/to_proc'
require 'facets/kernel/require_relative'
require_relative '../string/shell_escape.rb'

require 'pp'
class Array
  def shell_escape
    self.map(&:shell_escape).map(&:to_s)
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
    assert_equal ['a'], ['a'].shell_escape
  end
  def test_2
    assert_equal ["arg1", "'multiple words for single argument'"],
                 ['arg1',  'multiple words for single argument'].shell_escape
  end
end
=end
