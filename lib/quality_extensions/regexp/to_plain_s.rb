#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009 Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
#++


class Regexp
  def self.to_plain_s(input, also_unescape = nil)
    input.
    gsub(/((?<!\\)(\\\\)*)\(((?=\?[^):]*:)\?[^):]*:)?/, '\1').   # remove all unescaped '('s and any '?-mix:b-style prefix that their contents begin with
    gsub(/((?<!\\)(\\\\)*)[)?*+\[\]]/, '\1').                    # remove all unescaped ')', '?', '*', etc.es
    gsub(/((?<!\\)(\\\\)*)\{.*\}/, '\1').                        # remove all unescaped /{.*}/
    gsub(/((?<!\\)(\\\\)*)\\([().\/#{also_unescape}])/, '\1\3').                    # unescape any remaining (escaped) '\(', '\)', '\.', etc.es
    gsub(/\\\\/, '\\')
  end

  # Sometimes you don't want to see a [serialized] version of the regular expression:
  #   /a/.to_s       => '(?-mix:a)'
  # and you simply want a simple, human-readable version:
  #   /a/.to_plain_s => 'a'
  #
  # Since the Regexp object doesn't know what it was delimited with, to_plain_s can't know which
  # delimiter character, if any, it should try to unescape.
  #
  # %r#a\#b#.to_plain_s('#') # => "a#b"
  # %r#a\#b#.to_plain_s      # => "a\\#b"
  #
  # An escaped '/' will always be unescaped, since Ruby escapes for you even when you don't:
  #   /a\/b/.to_plain_s      # => 'a/b'
  # %r#a\/b#.to_plain_s      # => 'a/b'
  # %r#a/b#. to_plain_s      # => "a/b"
  #
  def to_plain_s(also_unescape = nil)
    Regexp.to_plain_s(self.to_s, also_unescape)
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

describe 'Regexp#to_plain_s' do
  it "removes '?-mix:' prefix" do
    /a/.to_plain_s.should == 'a'
  end

  it "removes unescaped ()" do
    /(a)bc/.to_plain_s.should == 'abc'
  end

  it "removes unescaped ?, *, +" do
    /a?b*c+/.to_plain_s.should == 'abc'
  end

  it "removes unescaped /{3}/" do
    /a{3}bc/.to_plain_s.should == 'abc'
    /a{1,3}bc/.to_plain_s.should == 'abc'
  end

  it "unescapes escaped ()'s correctly" do
    #                        1       1 2   1 2
    Regexp.to_plain_s( "(a) \\(b\\) \\\\(c\\\\)" ).should ==
    "a (b) \\c\\"

    #    1  1  12  12
    /(a) \(b\) \\(c\\)/.to_plain_s.should ==
    "a (b) \\c\\"

    #                        1   1   1 2   1 2   1 2 3   1 2 3   1 2 3 4   1 2 3 4   1 2 3 4 5   1 2 3 4 5
    Regexp.to_plain_s( "(a) \\(b\\) \\\\(c\\\\) \\\\\\(d\\\\\\) \\\\\\\\(e\\\\\\\\) \\\\\\\\\\(f\\\\\\\\\\)" ).should ==
    #       1  1  1   1   1 2  1 2  1 2   1 2
    "a (b) \\c\\ \\(d\\) \\\\e\\\\ \\\\(f\\\\)"

    #    1  1  12  12  123  123  1234  1234  12345  12345
    /(a) \(b\) \\(c\\) \\\(d\\\) \\\\(e\\\\) \\\\\(f\\\\\)/.to_plain_s.should ==
    #       1  1  1   1   1 2  1 2  1 2   1 2
    "a (b) \\c\\ \\(d\\) \\\\e\\\\ \\\\(f\\\\)"
  end

  it "unescapes escaped /'s, iff they tell us that they need to be unescaped" do
      /a\/b/.to_plain_s.     should == 'a/b'
    %r#a\#b#.to_plain_s.     should == "a\\#b"
    %r#a\#b#.to_plain_s('#').should == "a#b"
    %r#a\/b#.to_plain_s.     should == 'a/b'
    %r#a/b#. to_plain_s.     should == "a/b"
  end

  it "unescapes escaped .'s" do
    /a\.b/.to_plain_s.should == 'a.b'
  end

  it 'matches the original regexp' do
    (r=/a/).to_plain_s.should match(r)
    (r=/(a)bc/).to_plain_s.should match(r)
    (r=/a?b*c+/).to_plain_s.should match(r)
    (r=/a{1}bc/).to_plain_s.should match(r)
    (r=/(a) \(b\) \\(c\\)/).to_plain_s.should match(r)
    (r=/(a) \(b\) \\(c\\) \\\(d\\\) \\\\(e\\\\) \\\\\(f\\\\\)/).to_plain_s.should match(r)

    # Cannot handle the following cases:
    #(r=/a{3}bc/).to_plain_s.should match(r)
    #(r=/a{1,3}bc/).to_plain_s.should match(r)
  end
end

=end

