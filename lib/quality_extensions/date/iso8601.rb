#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'date'
require 'facets/date'   # I'm guessing this used to provide iso8601 ... no longer does?

class Date
  def iso8601
    # Useful for SQL dates, among other things
    to_time().iso8601()[0..9]
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
  def test_iso8601
    assert_equal '2006-07-18', Date.civil(2006, 7, 18).iso8601()
  end
end
=end
