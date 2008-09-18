#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# Changes::
#++


module Kernel
  def windows_platform?
    RUBY_PLATFORM =~ /mswin32/
    
    # What about mingw32 or cygwin32?
    #RUBY_PLATFORM =~ /(win|w)32$/
     
    # What about 64-bit Windows?
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
    # Impossible to test, unless your platform is Windows.
    assert true
  end

end
=end


