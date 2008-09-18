#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

require 'test/unit'
class Test::Unit::TestCase
  def assert_includes(container, expected_contents, failure_message = nil)
    failure_message = build_message(failure_message, "Container <?> was expected to contain <?> but it didn't", container, expected_contents)
    assert_block(failure_message) do
      container.include?(expected_contents)
    end
  end
  alias_method :assert_contains, :assert_includes

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



