#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

require "digest/md5"

class String
  # Because it's so much more natural to have this as a method of the string rather than having to call <tt>Digest::MD5.hexdigest(string)</tt>.
  def md5
    return Digest::MD5.hexdigest(self)
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
  def test_md5
    assert_equal "abc".md5, Digest::MD5.hexdigest("abc")
  end
end
=end
