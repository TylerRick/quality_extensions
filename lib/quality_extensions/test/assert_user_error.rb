#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No
# Context::   Rails
#++

require 'test/unit'
class Test::Unit::TestCase
  def assert_user_error(error_message)
    assert_tag({
      :attributes => { :id => "errorExplanation" },
      :descendant => { 
        :content => error_message
      }
    })
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
  end
end
=end



