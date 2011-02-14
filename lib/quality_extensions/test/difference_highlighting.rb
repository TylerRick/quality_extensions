#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009 Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
#++

require 'facets'

if $LOADED_FEATURES.detect {|f| f =~ %r(minitest/unit.rb)}
  require_relative 'difference_highlighting-minitest.rb'
else
  require_relative 'difference_highlighting-test_unit.rb'
end
