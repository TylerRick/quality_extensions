#!/usr/bin/ruby
#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes:: Make a patch to actual pathname source.
# Changes::
#++

require 'pathname'
require 'tempfile'

class Pathname
  # Creates a new temp file using Tempfile.new and returns the Pathname object for that file
  def self.tempfile
    Pathname.new(Tempfile.new('Pathname').path)
  end

  # Moves self to +new_path+ using FileUtils.mv.
  #
  # See documentation for FileUtils.mv for a list of valid +options+.
  #
  # Returns Pathname object for +new_file+ file.
  #
  def mv(new_path, options = {})
    FileUtils.mv self.to_s, new_path.to_s, options
    Pathname.new(new_path)
  end
  alias_method :move, :mv
  
  # Copies self to +new_path+ using FileUtils.cp.
  #
  # See documentation for FileUtils.cp for a list of valid +options+.
  #
  # Returns Pathname object for +new_file+ file.
  #
  def cp(new_path, options = {})
    FileUtils.cp self.to_s, new_path.to_s, options
    Pathname.new(new_path)
  end
  alias_method :copy, :cp


  # Copies/install self to +dest+ using FileUtils.install.
  #
  # If src is not same as dest, copies it and changes the permission mode to mode. If dest is a directory, destination is dest/src.
  #
  #   FileUtils.install 'ruby', '/usr/local/bin/ruby', :mode => 0755, :verbose => true
  #   FileUtils.install 'lib.rb', '/usr/local/lib/ruby/site_ruby', :verbose => true
  #
  # Returns Pathname object for +dest+ file.
  #
  def install(dest, options = {})
    FileUtils.install self.to_s, dest.to_s, options
    Pathname.new(dest)
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
  def setup
    @object = Pathname.tempfile

    new_file = Pathname.new('/tmp/Pathname_new_file')
    new_file.unlink rescue nil
  end

  def test_tempfile_actually_creates_file
    assert @object.exist?
  end

  def test_tempfile_has_path_in_tmp
    assert_match %r(/tmp/Pathname), @object.to_s
  end

  def test_mv_actually_moves_file(new_file = '/tmp/Pathname_new_file', options = {})
    new_object = @object.mv(new_file, options)
    assert   !@object.exist?
    assert new_object.exist?
    assert_match %r(/tmp/Pathname), new_object.to_s
  end

  def test_mv_also_accepts_Pathname
    new_file = Pathname.new('/tmp/Pathname_new_file')
    new_file.unlink rescue nil
    assert !new_file.exist?
    test_mv_actually_moves_file new_file
    assert  new_file.exist?
  end

  def test_mv_accepts_noop_option
    new_object = @object.mv('/tmp/Pathname_new_file', :noop => true)
    assert     @object.exist?
    assert !new_object.exist?
  end

  def test_cp_actually_copies_file
    new_object = @object.cp('/tmp/Pathname_new_file')
    assert    @object.exist?
    assert new_object.exist?
    assert_match %r(/tmp/Pathname), new_object.to_s
  end

  def test_install_actually_copies_file
    new_object = @object.install('/tmp/Pathname_new_file')
    assert    @object.exist?
    assert new_object.exist?
    assert_match %r(/tmp/Pathname), new_object.to_s
  end
end
=end

