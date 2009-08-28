#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes! A great compliment to each_char!
# Developer notes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'

class String
  def each_char_with_index
    i = 0
    split(//).each do |c|
      yield i, c
      i += 1
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

class TheTest < Test::Unit::TestCase
  def test_1
    assert_equal [[0, "a"], [1, "b"], [2, "c"]],
                 'abc'.to_enum(:each_char_with_index).to_a
  end
end
=end


