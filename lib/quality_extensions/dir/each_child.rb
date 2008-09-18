#--
# Author::    Nolan Cafferky
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++


class Dir
  # Much like each(), except the "." and ".." special files
  # are ignored.
  def each_child
    each do |file|
      yield file if file != "." and file != ".."
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

require 'fileutils'

class TheTest < Test::Unit::TestCase
  def setup
    @base_path = "dir_extensions_test_test_each_child"
    make_test_files @base_path
  end
  def teardown
    FileUtils.remove_entry_secure @base_path
  end

  def test_each_child
    Dir.open(@base_path) do |d|
      results = []
      d.each_child { |file| results << file }
      assert_equal 3, results.size
      assert results.include?("foo")
      assert results.include?("bar")
      assert results.include?("foobar")
    end
  end

  def make_test_files base_path
    Dir.mkdir(      base_path)
    FileUtils.touch(base_path + "/foo")
    FileUtils.touch(base_path + "/bar")
    Dir.mkdir(      base_path + "/foobar")
    FileUtils.touch(base_path + "/foobar/baz")
  end
end
=end
