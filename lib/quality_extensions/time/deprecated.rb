#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No!
#++

class Time
  # This should be moved elsewhere because it is subjective and depends on the context where it's used.
  def datetime_for_report(line_break = false)
    optional_line_break = (line_break ? "<br/>\n" : "")
    strftime("%I:%M %p #{optional_line_break} %B %d, %Y")   # Example: "June 18, 2006"
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
    assert_equal "01:49 PM  June 18, 2006", Time.mktime(2006, 6, 18, 13, 49, 4).datetime_for_report()
    assert_equal "01:49 PM <br/>\n June 18, 2006", Time.mktime(2006, 6, 18, 13, 49, 4).datetime_for_report(line_break = true)
  end

end
=end
