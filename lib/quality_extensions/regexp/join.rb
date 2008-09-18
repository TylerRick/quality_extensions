#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# * Names considered:
#   * intersection (since there's already a Regexp#union), but unlike Regexp#union, it really doesn't seem like this method lends itself to a name from set theory. Mostly because unlike when dealing with sets (or unioned Regexps), *order matters* here.
#   * merge, concat, sum, add, combines
#   * join -- Settled on this because it's a lot like File.join: it combines the given pieces, *in order*, to make a whole.
#++


class Regexp
  # Returns a Regexp that results from interpolating each of the given +elements+ into an empty regular expression.
  #   /ab/ == Regexp.join(/a/, /b/)  # except spelled differently
  # Accepts both strings and Regexp's as +elements+ to join together. Strings that are passed in will be escaped (so characters like '*' will lose all of the Regexp powers that they would otherwise have and are treated as literals).
  #
  # Serving suggestion: Use it to check if the +actual+ string in an <tt>assert_match</tt> contains certain literal strings, which may be separated by any number of characters or lines that we don't care about. In other words, use it to see if a string contains the necessary "keywords" or "key phrases"...
  #   assert_match Regexp.join(
  #     'keyword1',
  #     /.*/m,
  #     'keyword2'
  #   ), some_method()
  #   # where some_method() returns "keyword1 blah blah blah keyword2"
  #
  def self.join(*elements)
    elements.inject(//) do |accumulator, element|
      accumulator + element
    end
  end

  # Pads the +elements+ (which may be strings or Regexp's) with /.*/ (match any number of characters) patterns.
  # Pass :multi_line => true if you want /.*/m as the padding pattern instead.
  def self.loose_join(*elements)
    options = (if elements.last.is_a?(Hash) then elements.pop else {} end)
    multi_line = options[:multi_line] || options[:m]
    padding = (multi_line ? /.*/m : /.*/)
    elements.inject(//) do |accumulator, element|
      accumulator + padding + element
    end
  end

  #   /a/ + /b/ == /ab/
  # Actually, the way it's currently implemented, it is
  #   /a/ + /b/ == /(?-mix:a)(?-mix:b)/
  # But they seem to be functionally equivalent despite the different spellings.
  def +(other)
    other = Regexp.escape(other) if other.is_a?(String)
    /#{self}#{other}/
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
  def test_1_simple_letters
    assert_equal /(?-mix:)(?-mix:b)/,  // + /b/
    assert_equal /(?-mix:)b/,          // + 'b'
    assert_equal /(?-mix:a)(?-mix:b)/, /a/ + /b/
    assert_equal /(?-mix:a)b/,         /a/ + 'b'
    assert_equal /(?-mix:(?-mix:(?-mix:)a)b)c/, Regexp.join('a', 'b', 'c')
    #assert_equal /(?-mix:(?-mix:(?-mix:)a)b)c/, Regexp.join(/a/, /b/, /c/)
    assert_equal 2,   '__abc__' =~ Regexp.join('a', 'b', 'c')
    assert_equal 2,   '__abc__' =~ Regexp.join(/a/, /b/, /c/)
    assert_equal nil, '__a.c__' =~ Regexp.join('a', 'b', 'c')
    assert_equal nil, '__a.c__' =~ Regexp.join(/a/, /b/, /c/)
  end

  def test_2_escaping
    assert_equal /(?-mix:)\./,          // + '.'  # Escaped
    assert_equal /(?-mix:)(?-mix:.)/,  // + /./   # Not escaped
  end

  def test_3
    assert_match Regexp.join(
      'keyword1',
      /.*/m,
      'keyword2'
    ),
'keyword1
asuethausnthauesth
blah blah blah
keyword2'
  end

  def test_loose_join
    regexp = Regexp.loose_join('keyword1', 'keyword2')
    assert_match regexp, 'keyword1 blah blah blah keyword2'
    assert_equal nil,    "keyword1 blah\nblah\nblah keyword2" =~ regexp
  end
  def test_loose_join_multiline
    regexp = Regexp.loose_join('keyword1', 'keyword2', :m => true)
    assert_match regexp, 'keyword1 blah blah blah keyword2'
    assert_match regexp, "keyword1 blah\nblah\nblah keyword2"
  end

end
=end


