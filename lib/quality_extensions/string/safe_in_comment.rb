#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# History::
#++



class String
  def safe_in_comment
    gsub('-', '&#45;')
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

describe 'safe_in_comment' do
  it 'works' do
    '1-2'.safe_in_comment.should == '1&#45;2'
  end
end
=end

