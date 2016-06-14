#--
# Credits::
# Copyright:: Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Maybe
# Developer notes::
#++

require 'facets/numeric/round'
require 'quality_extensions/module/alias_method_chain'

# * http://www.oreillynet.com/ruby/blog/2005/12/adding_utility_to_core_classes_1.html
#class Float
#  def round_to(x = nil)
#    if x > 0
#      ("%.0#{x.to_i}f" % self).to_f
#    else
#      # http://www.oreillynet.com/ruby/blog/2005/12/adding_utility_to_core_classes_1.html
#      # An advantage (I think) of Jonas' solution is it allows rounding on the other side of the decimal when x is negative.
#      # 1234.567.prec(-2) #=>1200.0
#      puts (self * 10**x).to_i
#      puts (10**x).to_f
#      (self * 10**x).round / (10**x)
#    end
#  end
#end

# File lib/core/facets/float/round.rb, line 17
# def round_at( d ) #d=0
#   (self * (10.0 ** d)).round.to_f / (10.0 ** d)
# end

class Float
  # This is the same as round_at except instead of rounding (up or down) to the nearest integer, it always truncates, rounding down to the next lowest integer.
  def truncate_with_precision(d)
   (self * (10.0 ** d)).truncate_without_precision.to_f / (10.0 ** d)
  end
  alias_method_chain :truncate, :precision
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
  def test_0
    assert_equal 1234.0, 1234.567.truncate(0)
    assert_equal 1235.0, 1234.567.round_at(0)
  end

  def test_1
    assert_equal 1234.5, 1234.567.truncate(1)
    assert_equal 1234.6, 1234.567.round_at(1)
  end

  def test_2
    assert_equal 1234.56, 1234.567.truncate(2)
    assert_equal 1234.57, 1234.567.round_at(2)
  end

  def test_negative_1
    assert_equal 1230.0, 1235.567.truncate(-1)
    assert_equal 1240.0, 1235.567.round_at(-1)
  end

  def test_negative_2
    assert_equal 1200.0, 1254.567.truncate(-2)
    assert_equal 1300.0, 1254.567.round_at(-2)
  end
end
=end

