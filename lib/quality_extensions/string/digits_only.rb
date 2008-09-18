#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

class String
  # Strips out everything except digits.
  def digits_only
    self.gsub(/[^0-9]/, "")
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
  def test_digits_only
    assert_equal "123", "$!@)(*&abc123[]{}".digits_only
  end
end
=end
