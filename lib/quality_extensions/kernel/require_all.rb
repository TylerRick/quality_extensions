#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/filelist'

require 'facets/kernel/require_local'
require_local '../file/exact_match_regexp'

module Kernel

  # <tt>require</tt>s all Ruby files specified by <tt>what</tt>, but not matching any of the exclude filters.
  # * If <tt>what</tt> is a string, recursively <tt>require</tt>s all Ruby files in the directory named <tt>what</tt> or any of its subdirectories.
  # * If <tt>what</tt> is a FileList, <tt>require</tt>s all Ruby files that match the <tt>what</tt> FileList.
  #
  # Options:
  # <tt>:exclude</tt>:       An array of regular expressions or glob patterns that will be passed to FileList#exclude. If you specify this option, a file will not be included if it matches *any* of these patterns.
  # <tt>:exclude_files</tt>: An array of filenames to exclude. These will be matched exactly, so if you tell it to exclude 'bar.rb', 'foobar.rb' will _not_ be excluded.
  #
  # Examples:
  #   require_all 'lib/', :exclude => [/ignore/, /bogus/]   # will require 'lib/a.rb', 'lib/long/path/b.rb', but not 'lib/ignore/c.rb'
  #   require_all File.dirname(__FILE__), :exclude_files => ['blow_up_stuff.rb']
  def require_all(what, options = {})
    files, exclusions = [nil]*2

    case what
      when String
        base_dir = what
        base_dir += '/' unless base_dir[-1].chr == '/'
        files = FileList[base_dir + "**/*.rb"]
      when FileList
        files = what
      else
        raise ArgumentError.new("Expected a String or a FileList")
    end
    if (exclusions = options.delete(:exclude))
      exclusions = [exclusions] if exclusions.is_a? String
      files = files.exclude(*exclusions)
    end
    if (exclusions = options.delete(:exclude_files))
      exclusions = [exclusions] if exclusions.is_a? String
      files = files.exclude(*exclusions.map {|a| File.exact_match_regexp(a) })
    end

    files.each do |filename|
      # puts "requiring #{filename}" if filename =~ /test/
      require filename
    end
  end

  # <tt>require</tt>s all Ruby files in +dir+ (relative to <tt>File.dirname(__FILE__)</tt>) or any of its subdirectories.
  #
  # This is just a shortcut for this:
  #   require_all File.expand_path(File.join(File.dirname(__FILE__), dir))
  #
  # All of the +options+ available for +require_all+ are still available here.
  #
  def require_local_all(dir = './', options = {})
    raise ArgumentError.new("dir must be a String") unless dir.is_a?(String)
    local_dir = File.dirname( caller[0] )
    require_all(
      File.expand_path(File.join(local_dir, dir)),
      options
    )
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
require 'tmpdir'
require 'fileutils'
require 'English'

class TheTest < Test::Unit::TestCase
  def setup
    @base_dir = "#{Dir.tmpdir}/require_all_test"
    @base_local_dir = File.dirname(__FILE__) # To allow testing of require_local_all. But tests should put everything in "#{@base_local_dir}/require_all_test" to avoid clutter or name conflicts with other files!
    FileUtils.mkdir              @base_dir
    @deep_dir = "really/really/deep/subdir"
    $loaded = []

  end
  def teardown
    FileUtils.rm_rf @base_dir
    FileUtils.rm_rf "#{@base_local_dir}/require_all_test"
  end


  def test_repeat_requires
    create_ruby_file 'moo.rb'

    require_all File.dirname(@base_dir)
    assert_equal ['moo.rb'], $loaded

    require "#{@base_dir}/moo.rb"
    assert_equal ['moo.rb'], $loaded

    # Good! It refuses to load it again, even if we drop the ".rb" part!
    require "#{@base_dir}/moo"
    assert_equal ['moo.rb'], $loaded

    # But, we can still trick it!
    # Update: Apparently, in Ruby 1.9.1, this no longer works. moo.rb will only be required once.
#    $LOAD_PATH << @base_dir
#    require "moo"
#    assert_equal ['moo.rb', 'moo.rb'], $loaded
#
#    load "moo.rb"
#    assert_equal ['moo.rb', 'moo.rb', 'moo.rb'], $loaded
  end

  def test_deep_subdir
    create_ruby_file 'flip.rb'
    create_ruby_file @deep_dir + "/flop.rb"

    require_all File.dirname(@base_dir)
    assert_equal [@deep_dir + "/flop.rb", 'flip.rb'], $loaded
  end

  def test_exclude_pattern
    create_ruby_file 'require_me.rb'
    create_ruby_file 'please_ignore_me.rb'

    require_all File.dirname(@base_dir), :exclude => [/ignore/]
    assert_equal ['require_me.rb'], $loaded
  end

  def test_require_local_all
    create_ruby_file 'require_all_test/lib/require_me.rb', @base_local_dir
    create_ruby_file 'require_all_test/lib/please_ignore_me.rb', @base_local_dir

    require_local_all 'require_all_test/lib', :exclude => [/ignore/]
    assert_equal ['require_all_test/lib/require_me.rb'], $loaded
  end

  def test_exclude_pattern_with_directory
    create_ruby_file 'subdir/test/assert_even.rb'
    create_ruby_file 'subdir/test/assert_odd.rb'

    require_all File.dirname(@base_dir), :exclude => [/(^|\/)test/]
    assert_equal [], $loaded
  end

  def test_passing_a_FileList
    create_ruby_file 'subdir/junk/pretty_much_useless.rb'
    create_ruby_file 'subdir/not_junk/good_stuff.rb'

    require_all FileList[File.dirname(@base_dir) + "/**/*.rb"], :exclude => [/(^|\/)junk/]
    assert_equal ['subdir/not_junk/good_stuff.rb'], $loaded
  end

  def test_exclude_filename
    create_ruby_file 'yes.rb'
    create_ruby_file 'all.rb'

    # :todo: Interesting how none of these patterns work. I would have expected them to. Is there a bug in FileList? Find out...
    #   /usr/lib/ruby/gems/1.8/gems/facets-1.8.51/lib/facets/more/filelist.rb
    #require_all File.dirname(@base_dir), :exclude => ['all.rb']
    #require_all File.dirname(@base_dir), :exclude => ['**/all']
    #require_all File.dirname(@base_dir), :exclude => [/^all\.rb$/]
    # This works, but it's too much to expect users to type out!:
    #require_all File.dirname(@base_dir), :exclude => [/(\/|^)all\.rb$/]
    
    # So...... I added an :exclude_files option so that people wouldn't have to!
    require_all File.dirname(@base_dir), :exclude_files => ['all.rb']

    assert_equal ['yes.rb'], $loaded
  end

  def test_exclude_filename_string
    create_ruby_file 'yes2.rb'
    create_ruby_file 'all2.rb'

    require_all File.dirname(@base_dir), :exclude_files => 'all2.rb'

    assert_equal ['yes2.rb'], $loaded
  end

  #-------------------------------------------------------------------------------------------------------------------------------
  # Helpers

  def create_ruby_file(file_name, base_dir = @base_dir)
    # use dirname instead?
    if file_name =~ /(.*)\//
      FileUtils.mkdir_p base_dir + '/' + $1
    end
    path = base_dir + '/' + file_name
    File.open(path, "w") {|f| f.puts "$loaded << '#{file_name}'"}
  end

end
=end
