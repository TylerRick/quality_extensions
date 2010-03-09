#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++

#returns array with [index (of line/element that matched) , the matched line/element]

class Regexp
  # not working
  def debug_triple_equals(other)
    p other if $debug
    #p original_tripel_equals(other)
    original_tripel_equals(other)
  end
  alias_method :original_tripel_equals, :===
  alias_method :===, :debug_triple_equals
end

module Enumerable
  def grep_with_index(pattern)
    $debug = true
    each.with_index.grep(pattern)
    $debug = false
  end
end






#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec/autorun'

describe 'Enumerable#grep_with_index' do
  it '' do
    ['a', 'b'].grep_with_index(/a/).should == ['a', 0]
  end
end
=end

