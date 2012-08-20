#!/usr/bin/ruby
#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# * Make a patch to actual pathname source.
# * document all Pathname methods better, copying from docs for delegated class if necessary, but NOT just saying 'See FileTest.file?.' How useless that is to have to keep flipping back and forth referring to like 4 different classes!
# History::
# * Renamed parts to split_all to be the same as Facets' File.split_all
# To do:
# path.basename.capitalize doesn't work
# workaround:
# path = Pathname.new(path.basename.to_s.capitalize)
# better:
# path.basename.change_basename {|basename| basename.capitalize} ?
#++



# TODO: How much of this stuff already exists as private methods??
#
#  # chop_basename(path) -> [pre-basename, basename] or nil
#  def chop_basename(path)
#    base = File.basename(path)
#    if /\A#{SEPARATOR_PAT}?\z/ =~ base
#      return nil
#    else
#      return path[0, path.rindex(base)], base
#    end
#  end
#  private :chop_basename
#
#  # split_names(path) -> prefix, [name, ...]
#  def split_names(path)
#    names = []
#    while r = chop_basename(path)
#      path, basename = r
#      names.unshift basename
#    end
#    return path, names
#  end
#  private :split_names
#
#  def prepend_prefix(prefix, relpath)
#    if relpath.empty?
#      File.dirname(prefix)
#    elsif /#{SEPARATOR_PAT}/ =~ prefix
#      prefix = File.dirname(prefix)
#      prefix = File.join(prefix, "") if File.basename(prefix + 'a') != 'a'
#      prefix + relpath
#    else
#      prefix + relpath
#    end
#  end
#  private :prepend_prefix
#










require 'pathname'
require 'tempfile'

class Pathname
  # Creates a new temp file using Tempfile.new and returns the Pathname object for that file
  def self.tempfile
    Pathname.new(Tempfile.new('Pathname').path)
  end

  # Pathname.new(Dir.getwd)
  #
  # Name ideas: cwd
  def self.getwd
    Pathname.new(Dir.getwd)
  end

  # Returns a Pathname object representing the absolute path equivalent to self.
  #
  # If self is already absolute, returns self. Otherwise, prepends Pathname.getwd (in other words, creates an absolute path relative to the current working directory.)
  #
  # Pathname.new('.').absolutize == Pathname.getwd # => true
  #
  def absolutize
    if absolute?
      self
    else
      (Pathname.getwd + self).cleanpath
    end
  end

  # Same as FileUtils.touch
  #
  # Options: noop verbose
  #
  # Updates modification time (mtime) and access time (atime) of file(s) in list. Files are created if they don’t exist.
  #
  # FileUtils.touch 'timestamp'
  # FileUtils.touch Dir.glob('*.c');  system 'make'
  #
  # Returns self. This is different from FileUtils.touch, which returns an array of filenames.
  #
  def touch
    tap {|file| FileUtils.touch file.to_s }
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

  # Copies self to +dest+ using FileUtils.cp.
  #
  # See documentation for FileUtils.cp for a list of valid +options+.
  #
  # Returns Pathname object for +dest+ file.
  #
  def cp(dest, options = {})
    FileUtils.cp self.to_s, dest.to_s, options
    Pathname.new(dest)
  end
  alias_method :copy, :cp

  # Copies self to +dest+ using FileUtils.cp_r. If self is a directory, this method copies all its contents recursively. If +dest+ is a directory, copies self to +dest/src+.
  #
  # See documentation for FileUtils.cp_r for a list of valid +options+.
  #
  # Returns Pathname object for +dest+ file.
  #
  def cp_r(dest, options = {})
    FileUtils.cp_r self.to_s, dest.to_s, options
    Pathname.new(dest)
  end
  alias_method :copy_recursive, :cp_r


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


  # This is needed since <#Pathname> + <#String> treats both self and the string as a *directory* to be joined instead of simply treating them as parts of a basename/filename to join together.
  #
  # Pathname.new('/tmp/some_file') + '.suffix'
  # => Pathname.new('/tmp/some_file/.suffix')
  #
  # Pathname.new('/tmp/some_file').add_suffix('.suffix')
  # => Pathname.new('/tmp/some_file.suffix')
  #
  # Pathname.new('/tmp/some_file/').add_suffix('.suffix')
  # => Pathname.new('/tmp/some_file.suffix')
  #
  def add_suffix(s)
    Pathname.new(cleanpath.to_s + s)
  end

  def add_prefix(s)
    Pathname.new((dirname + s).to_s + basename.to_s)
  end

  # Better name? Would 'dirs' be better? 'parents'?
  #
  # Similar to split, but instead of only returning two parts ([dirname, basename]), returns an element for *each* directory/basename represented in the path.
  #
  # Similar to PHP's pathinfo()['parts']?
  #
  def split_all
    # Boundary condition for paths like '/usr' (['/', 'usr'] will be the result)
    if self.to_s == '/'
      [self]
    # Boundary condition for paths like 'usr' (we only want ['usr'], not ['.', 'usr'])
    elsif self.to_s == '.'
      []
    else
      parent.split_all + [self]
    end
  end

  # Returns all path parts except the last (the last part being the basename).
  #
  # When there is only one part (as is the case, f.e., with Pathname('/') or Pathname('file')), it returns an empty array (rather than Pathname('/') or Pathname('.')).
  #
  # Similar to split, but instead of only returning two parts ([dirname, basename]), returns an element for *each* directory represented in the path.
  #
  def split_all_without_basename
    parents = split_all.dup
    parents.pop
    parents
  end

  # Returns an array of all path parts that are directories. (If +self.directory?+, self is included too, unless +include_self+ is false.)
  #
  # This is similar to parts_without_basename except unlike parts_without_basename, which removes the last path ('basename') part no matter what, parent_dirs actually checks if the last path part is a *directory* and only removes it if it is not.
  #
  # absolutize is called to force it to be an absolute path; so this method will not behave as advertized if the path is invalid or if the current working directory isn't correct when the path is absolutized...
  #
  # parent_dirs is not useful when used with fictional paths. It actually calls #directory? on the last path part, so the path must actually exist for this method to work as advertised.
  # (You would might be advised to check #exist? before calling this method.)
  # If you are confident that self is a directory, then you might want to use parts_without_basename.
  #
  # Name ideas: parents, ancestors (but since it also includes self by default, I thought emphasizing *dirs* would be less misleading.)
  #
  def parent_dirs(include_self = true)
    parents = absolutize.split_all.dup
    parents.pop if parents.any? && !(parents.last.directory? && include_self)
    parents
  end

  # Better name? Would 'dirs' be better?
  #
  # Similar to split, but instead of only returning two parts ([dirname, basename]), returns an element for *each* directory represented in the path.
  #
  # Pathname.new('dir1/dir2/base').parts_s
  # # => ['dir1', 'dir2', 'base']
  #
  # Pathname.new('dir1/dir2/base').parts_s.first
  # # => 'dir1'
  #
  # Pathname.new('/dir1/dir2/base').parts_s
  # # => ['/', 'dir1', 'dir2', 'base']
  #
  # Unlike split_all, this returns an array of *strings* rather than an array of Pathnames.
  #
  # Similar to PHP's pathinfo()['parts']?
  #
  def split_all_s
    a, b = split
    a, b = a, b.to_s

    # Boundary condition for paths like '/usr' (['/', 'usr'] will be the result)
    if b == '/'
      [b]
    # Boundary condition for paths like 'usr' (we only want ['usr'], not ['.', 'usr'])
    elsif b == '.'
      []
    else
      a.split_all_s + [b]
    end
  end

  # Traverses up the file system until a match is found that is described by +block+ (that is, until +block+ yields a true value).
  #
  # Yields each parent *directory* (including self if self.directory?) as a Pathname object, one at a time, until we get to root of the file system (absolutize is called to force it to be an absolute path) or the block indicates that it has found what it's looking for.
  #
  # find_ancestor will return as its return value the block's return value as soon as the block's return value evaluates to true (not nil or false). If no match is found, find_ancestor will return nil.
  #
  # Example:
  #   git_dir = Pathname.getwd.find_ancestor {|dir| path = dir + '.git'; path if path.exist? }
  #
  # Note that this is quite unlike Pathname#find which has access to prune, etc.
  #
  # Other name ideas: reverse_find, upfind, find_up_tree, find_first_ancestor
  #
#  def find_parent
#    absolutize.parent_dirs.each do |part|
#      ret = yield part
#      return ret if ret
#    end
#    nil
#  end

  # Traverses up the file system until a match is found that is described by +block+ (that is, until +block+ yields a true value).
  #
  # Yields each parent *directory* (including self if self.directory?) as a Pathname object, one at a time, until we get to root of the file system (absolutize is called to force it to be an absolute path) or the block indicates that it has found what it's looking for.
  #
  # find_ancestor will return as its return value the block's return value as soon as the block's return value evaluates to true (not nil or false). If no match is found, find_ancestor will return nil.
  #
  # Examples:
  #   git_dir = Pathname.getwd.each_parent_dir {|dir| path = dir + '.git'; break path if path.exist? }
  #   git_dirs = []; Pathname.getwd.each_parent_dir {|dir| path = dir + '.git'; git_dirs << path if path.exist? }
  #
  # To do: deprecate, merge docs with parent_dirs?
  def each_parent_dir
    parent_dirs.reverse.each do |part|
      ret = yield part
    end
    nil
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

  def test_cwd
    assert_equal Dir.getwd, Pathname.getwd.to_s
  end

  def test_absolutize
    assert_equal Pathname.new('/some/already/absolute/path'), Pathname.new('/some/already/absolute/path').absolutize
    assert_equal Pathname.getwd, Pathname.new('.').absolutize
  end

  def test_touch
    new_file = Pathname.new('/tmp/sought')
    new_file.unlink rescue nil
    assert !new_file.exist?
    new_file.touch
    assert new_file.exist?
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

  def test_cp_r_actually_copies_file
    new_object = @object.cp_r('/tmp/Pathname_new_file')
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

  def test_add_suffix
    file = Pathname.new('/tmp/Pathname_new_file')
    assert_equal Pathname.new('/tmp/Pathname_new_file/.suffix'), file + '.suffix'.to_s
    assert_equal Pathname.new('/tmp/Pathname_new_file.suffix'), file.add_suffix('.suffix')

    file = Pathname.new('/tmp/Pathname_new_file/')
    assert_equal Pathname.new('/tmp/Pathname_new_file.suffix'), file.add_suffix('.suffix')
  end

  def test_add_prefix
    file = Pathname.new('/tmp/Pathname_new_file')
    assert_equal              'prefix-/tmp/Pathname_new_file', 'prefix-' + file.to_s
    assert_equal Pathname.new('/tmp/prefix-Pathname_new_file'), file.add_prefix('prefix-')

    file = Pathname.new('/tmp/Pathname_new_file/')
    assert_equal Pathname.new('/tmp/prefix-Pathname_new_file'), file.add_prefix('prefix-')
  end

  def test_split_all
    file = Pathname.new('/')
    assert_equal [Pathname.new('/')], file.split_all

    file = Pathname.new('dir1')
    assert_equal [Pathname.new('dir1')], file.split_all

    file = Pathname.new('/dir1')
    assert_equal [Pathname.new('/'), Pathname.new('/dir1')], file.split_all

    file = Pathname.new('dir1/dir2/base')
    assert_equal [Pathname.new('dir1'), Pathname.new('dir1/dir2'), Pathname.new('dir1/dir2/base')], file.split_all

    file = Pathname.new('/dir1/dir2/base')
    assert_equal [Pathname.new('/'), Pathname.new('/dir1'), Pathname.new('/dir1/dir2'), Pathname.new('/dir1/dir2/base')], file.split_all
  end

  def test_split_all_without_basename
    file = Pathname.new('/')
    assert_equal [], file.split_all_without_basename

    file = Pathname.new('dir1')
    assert_equal [], file.split_all_without_basename

    file = Pathname.new('/dir1')
    assert_equal [Pathname.new('/')], file.split_all_without_basename

    file = Pathname.new('dir1/dir2/base')
    assert_equal [Pathname.new('dir1'), Pathname.new('dir1/dir2')], file.split_all_without_basename

    file = Pathname.new('/dir1/dir2/base')
    assert_equal [Pathname.new('/'), Pathname.new('/dir1'), Pathname.new('/dir1/dir2')], file.split_all_without_basename
  end

  def test_parent_dirs
    file = Pathname.new('/')
    assert_equal [Pathname.new('/')], file.parent_dirs

    # Before I had absolutize in parent_dirs
#    file = Pathname.new('dir1')
#    assert_equal false, file.directory?  # Even though 'dir1' sounds like a directory to us humans, #directory? has no way of knowing that and so returns false.
#    # parent_dirs is not useful when used with fictional paths; because it actually calls #directory?, the path must actually exist for it to work as advertised.
#    assert_equal [], file.parent_dirs

    # Before I had absolutize in parent_dirs
#    Dir.chdir('/tmp') do
#      Pathname.new('dir1').mkpath
#      file = Pathname.new('dir1')
#      # dir1 is not fictional in this test; parent_dirs will work as expected
#      assert_equal true, file.directory?
#      assert_equal [Pathname.new('dir1')], file.parent_dirs
#      assert_equal [], file.parent_dirs(false) # don't include self
#    end

    Dir.chdir('/tmp') do
      Pathname.new('dir1').mkpath
      file = Pathname.new('dir1')
      assert_equal true, file.directory?
      assert_equal [Pathname.new('/'), Pathname.new('/tmp'), Pathname.new('/tmp/dir1')], file.parent_dirs
    end


    # Before I had absolutize in parent_dirs
#    # Again, passed a fictional dir, so #directory? will return false (even though technically it is unknown/undefined) and basename will be dropped
    begin
      file = Pathname.new('/dir1')
      assert_equal [Pathname.new('/')], file.parent_dirs

      file = Pathname.new('/dir1/dir2/base')
      assert_equal [Pathname.new('/'), Pathname.new('/dir1'), Pathname.new('/dir1/dir2')], file.parent_dirs
    end

    # dir1 should be real (should exist) this time, and self/basename is included by default if self is a directory.
    file = Pathname.new('/tmp/dir1')
    assert_equal [Pathname.new('/'), Pathname.new('/tmp'), Pathname.new('/tmp/dir1')], file.parent_dirs
    assert_equal [Pathname.new('/'), Pathname.new('/tmp')                           ], file.parent_dirs(false)
  end

  def test_split_all_s
    file = Pathname.new('/')
    assert_equal ['/'], file.split_all_s

    file = Pathname.new('dir1')
    assert_equal ['dir1'], file.split_all_s

    file = Pathname.new('/dir1')
    assert_equal ['/', 'dir1'], file.split_all_s

    file = Pathname.new('dir1/dir2/base')
    assert_equal ['dir1', 'dir2', 'base'], file.split_all_s

    file = Pathname.new('/dir1/dir2/base')
    assert_equal ['/', 'dir1', 'dir2', 'base'], file.split_all_s
  end

  # original:
#  def test_each_parent_dir
#    sought_file = Pathname.new('/tmp/sought')
#    sought_file.touch
#    assert sought_file.exist?
#    assert !sought_file.directory?
#
#    inner_dir = Pathname.new('/tmp/a/b')
#    inner_dir.mkpath
#    assert inner_dir.exist?
#    assert inner_dir.directory?
#
#    i = 0
#    found = inner_dir.each_parent_dir do |dir|
#      i += 1
#      candidate = dir + 'sought'
#      candidate if candidate.exist?
#    end
#
#    assert_equal '/tmp/sought', found.to_s
#    assert_equal sought_file, found
#    assert_equal 2, i
#
#    # But if we start from our getwd, we probably shouldn't find sought
#    i = 0
#    found = Pathname.getwd.each_parent_dir do |dir|
#      i += 1
#      candidate = dir + 'sought'
#      candidate if candidate.exist?
#    end
#    assert_equal nil, found
#    assert i >= 2
#
#    # It should call cleanpath to convert relative to absolute paths
#    # If we didn't do that, the block would not get called at all in this case.
#    i = 0
#    found = Pathname.new('.').each_parent_dir do |dir|
#      i += 1
#      candidate = dir + 'sought'
#      candidate if candidate.exist?
#    end
#    assert_equal nil, found
#    assert i >= 1, "Did not ascend at least 1 directory higher than '.'"
#  end

  def test_each_parent_dir
    sought_file = Pathname.new('/tmp/sought')
    sought_file.touch
    assert sought_file.exist?
    assert !sought_file.directory?

    inner_dir = Pathname.new('/tmp/a/b')
    inner_dir.mkpath
    assert inner_dir.exist?
    assert inner_dir.directory?

    visited = []
    inner_dir.each_parent_dir do |dir|
      visited << dir
    end
    assert_equal [Pathname.new('/tmp/a/b'), Pathname.new('/tmp/a'), Pathname.new('/tmp'), Pathname.new('/')], visited

    visited = []
    found = inner_dir.each_parent_dir do |dir|
      visited << dir
      candidate = dir + 'sought'
      break candidate if candidate.exist?
    end

    assert_equal '/tmp/sought', found.to_s
    assert_equal sought_file, found
    assert_equal [Pathname.new('/tmp/a/b'), Pathname.new('/tmp/a'), Pathname.new('/tmp')], visited

    # But if we start from our getwd, we probably shouldn't find sought
    i = 0
    found = Pathname.getwd.each_parent_dir do |dir|
      i += 1
      candidate = dir + 'sought'
      break candidate if candidate.exist?
    end
    assert_equal nil, found
    assert i >= 2

    # It should call cleanpath to convert relative to absolute paths
    # If we didn't do that, the block would not get called at all in this case.
    i = 0
    found = Pathname.new('.').each_parent_dir do |dir|
      i += 1
      candidate = dir + 'sought'
      break candidate if candidate.exist?
    end
    assert_equal nil, found
    assert i >= 1, "Did not ascend at least 1 directory higher than '.'"
  end

end
=end

