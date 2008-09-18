#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe.
# Developer notes::
#++

class Object
  def send_if_not_nil(message, *args)
    if message
      send(message, *args) 
    else
      self
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
    assert_equal 'a', 'a'.send_if_not_nil(nil)
    assert_equal 'A', 'a'.send_if_not_nil(:upcase)
  end
end
=end
