#--
# Author::    Lloyd Zusman, Tyler Rick
# Copyright:: Copyright (c) 2002-2007 Lloyd Zusman
# License::   Ruby License
# History::
# * 2002-10-05: Based on code posted by Lloyd Zusman on ruby-talk on 2002-10-05 (http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/52548) 
# * 2007-03-15: Cleaned up a bit and wrote tests.
# Submit to Facets?:: Yes
#++

module FileTest

private
  def self.is_text?(block)
    return (block.count("^ -~", "^\b\f\t\r\n") < (block.size / 3.0) &&
            block.count("\x00") < 1)
  end

public
  # The text_file? and binary_file? methods are not inverses of each other. Both return false if the item is not a file, or if it
  # is a zero-length file. The "textness" or "binariness" of a file can only be determined if it's a file that contains at least
  # one byte.

  def self._binary_file?(filename)
    size = self.size(filename)
    blksize = File.stat(filename).blksize
    return nil if !File.file?(filename) || size < 1
    size = [size, blksize].min
    begin
      open(filename) {
        |file|
        block = file.read(size)
        return !self.is_text?(block)
      }
    end
  end

  def self.binary_file?(filename)
    self._binary_file?(filename)   
  end

  def self.text_file?(filename)
    return_value = self._binary_file?(filename)   
    if return_value.nil?
      return_value 
    else
      !return_value 
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
  def empty_file
    File.open(filename = 'test_file', 'w') do |file|
    end
    yield filename
  ensure
    FileUtils.rm filename
  end

  def binary_file
    File.open(filename = 'test_file', 'wb') do |file|
      bin_data = [0].pack('c')*(1024)
      file.write(bin_data)
    end
    yield filename
  ensure
    FileUtils.rm filename
  end

  def text_file
    File.open(filename = 'test_file', 'w') do |file|
      file.puts('Guten Tag!')
    end
    yield filename
  ensure
    FileUtils.rm filename
  end

  def test_empty
    empty_file do |filename|
      assert !FileTest.binary_file?(filename)
      assert !FileTest.text_file?(filename)
    end
  end
  def test_binary
    binary_file do |filename|
      assert FileTest.binary_file?(filename)
      assert !FileTest.text_file?(filename)
    end
  end
  def test_text
    text_file do |filename|
      assert !FileTest.binary_file?(filename)
      assert FileTest.text_file?(filename)
    end
  end
end
=end

