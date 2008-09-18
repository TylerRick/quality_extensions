#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

# To do:
# * Is there a more object-oriented way to do this? Instance method instead of class method?

class File
  def self.exact_match_regexp(filename)
    /(^|\/)#{Regexp.escape(filename)}$/
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
    assert 'bar.rb'          =~ File.exact_match_regexp('bar.rb')
    assert '/path/to/bar.rb' =~ File.exact_match_regexp('bar.rb')
    # But:
    assert 'foobar.rb'       !~ File.exact_match_regexp('bar.rb')
  end
end
=end

