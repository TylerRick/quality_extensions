#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No!
#++

# Depends on some niceties from ActiveSupport (which really should be in core Ruby but aren't)...
require "rubygems"
require "active_support"
require "pp"

class Date
  # These should be moved elsewhere because they are subjective and depend on the context where they're used.
  def date_for_report
    strftime("%b %d, %Y")   # Example: "Jun 18, 2006"
  end
  def month_for_report
    strftime("%B %Y")   # Example: "June 2006"
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
  def test_date_for_report
    assert_equal 'Jun 18, 2006', Date.new(2006, 6, 18).date_for_report()
    assert_equal 'Jun 03, 2006', Date.new(2006, 6,  3).date_for_report()
  end

  def test_month_for_report
    assert_equal 'June 2006', Date.new(2006, 6).month_for_report()
  end
end
=end
