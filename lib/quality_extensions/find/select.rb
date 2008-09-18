#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# Changes::
#++


require 'find'
require 'enumerator'

module Find
  # Identical to +find+ except +select+ returns the matching files as an _array_. (+find+ returns nil, which is not very useful if you actually wanted an array.)
  #
  # Calls the associated block with the name of every file and directory listed as arguments, then recursively on their subdirectories, and so on.
  #
  # Return a true (non-false) value from the block for every path that you want to be returned in the resulting array.
  #
  # You can still use <tt>Find.prune</tt>.
  #
  def self.select(*paths, &block)
    Enumerable::Enumerator.new(self, :find, *paths).select{|value| yield value}
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
  # to do: would probably be safer if we *created* our own files/directories during setup, rather than expecting there to be some for us to use in cwd
  
  def test_true
    dir = '.'
    files_expected = []
    Find.find(dir) { |path| files_expected << path }

    files = Find.select(dir) { |path| true }
    assert_equal files_expected, files

    # Doesn't have to be true necessarily -- can be a string
    files = Find.select(dir) { |path| path }
    assert_equal files_expected, files
  end

  def test_false
    dir = '.'
    files = Find.select(dir) { |path| false }

    assert_equal [], files
  end

end
=end


