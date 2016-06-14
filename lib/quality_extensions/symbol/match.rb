#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Maybe, if we can get the bugs worked out. I can't believe Facets has Regexp#chomp, capitalize, downcase, etc., but not match/=~ !
# Developer notes::
# * Rename to symbol/regexp.rb ?
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'facets/module/alias_method_chain'

unless :a =~ /a/

class Symbol
  def match(regexp)
    to_s.match(regexp)
  end

  # Warning: Due to what I think is a bug in Ruby, $1, Regexp.last_match do not yield accurate results when queried after
  # returning from a method call that does a regexp match!
  # If you need access to that data, you're better off just doing :symbol.to_s =~ /regexp/ yourself.
  # If all you need is a true/false (matches or doesn't match) result, then you can use this.
  #   :cat =~ /c.t/
  #
  def =~(regexp)
    to_s =~ regexp
  end
  # Seems to be equivalent to this, if anyone cares:
  #  m = self.match(regexp)
  #  m ? m.begin(0) : nil

end

# I would just do something like this, but it causes the $1-not-set-after-method-call bug to infect anything that uses Regexp#===, which would be really bad!!
  #class Regexp
  #  alias_method :orig_eee, :===
  #  def === (other)
  #    orig_eee(other)
  #  end
  #
  #end
# I can't even run the tests in this file after making this (trivial) wrapper for ===! If I try, I get this error:
#/usr/lib/ruby/1.8/optparse.rb:1099:in `make_switch': undefined method `downcase' for nil:NilClass (NoMethodError)
#        from /usr/lib/ruby/1.8/optparse.rb:1032:in `each'
#        from /usr/lib/ruby/1.8/optparse.rb:1032:in `make_switch'
#        from /usr/lib/ruby/1.8/optparse.rb:1140:in `define'
#        from /usr/lib/ruby/1.8/optparse.rb:1149:in `on'
#        from /usr/lib/ruby/1.8/test/unit/autorunner.rb:106:in `options'
#        from /usr/lib/ruby/1.8/optparse.rb:755:in `initialize'
#        from /usr/lib/ruby/1.8/test/unit/autorunner.rb:101:in `new'
#        from /usr/lib/ruby/1.8/test/unit/autorunner.rb:101:in `options'
#        from /usr/lib/ruby/1.8/test/unit/autorunner.rb:88:in `process_args'
#        from /usr/lib/ruby/1.8/test/unit/autorunner.rb:10:in `run'
#        from /usr/lib/ruby/1.8/test/unit.rb:278
#        from -:46

class Regexp
  def eee_with_support_for_symbols (other)
    case other
    when Symbol
      __send__ :===, other.to_s
    else
      __send__ :===, other
    end
  end

  module WithSupportForSymbols
    def self.extended(base)
      base.class.class_eval do
        alias_method :eee_without_support_for_symbols, :===
      end
    end
    def === (other)
      case other
      when Symbol
        eee_without_support_for_symbols(other.to_s)
      else
        eee_without_support_for_symbols(other)
      end
    end
  end
end

module Enumerable
  def grep_with_regexp_support_for_symbols(pattern, &block)
    map { |element|
      element.is_a?(Symbol) ? element.to_s : element
    }.grep_without_regexp_support_for_symbols(pattern, &block)
  end
  alias_method_chain :grep, :regexp_support_for_symbols

end

end # unless :a =~ /a/

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'
require 'quality_extensions/object/singleton_send'

class TheTest < Test::Unit::TestCase
  def test_equal_tilde
    assert_equal 1, :chopper =~ /hopper/
  end
  def test_match
    assert :chopper.match(/hopper/).is_a?(MatchData)
    assert_equal 'hopper', :chopper.match(/hopper/).to_s
  end
  def test_triple_equal
    assert_equal true, /hopper/ === 'chopper'
    assert_equal false, /hopper/ === :chopper       # Doesn't work!

    assert_equal true, /hopper/.eee_with_support_for_symbols(:chopper)
    assert_equal true, /hopper/.singleton_send(Regexp::WithSupportForSymbols, :===, :chopper)
    regexp = /chopper/
    regexp.extend Regexp::WithSupportForSymbols
    assert_equal true, regexp === :chopper
  end

  # Due to what I think is a BUG in Ruby, the details of the last_match appear to be reset after returning from a method.
  # In other words, if you print out $1 from within Symbol#=~, it has the value you'd expected, but as soon as we get back from
  # Symbol#=~, it's gone!
  # See http://svn.tylerrick.com/public/ruby/examples/regexp-variables_reset_after_return_from_method.rb
  def test_the_setting_of_match_variables
    # This doesn't work, unfortunately.
    assert_equal 0, :cat =~ /c(.)t/
    assert_equal nil, $1
    assert_equal nil, Regexp.last_match(1)

    # Nor this
    assert :cat.match(/c(.)t/)
    assert_equal nil, $1
    assert_equal nil, Regexp.last_match(1)

    # But if we do the to_s conversion *here* (as opposed to from within Symbol#=~), it works! Yuck!
    assert_equal 0, :cat.to_s =~ /c(.)t/
    assert_equal 'a', $1
    assert_equal 'a', Regexp.last_match(1)
  end

  def test_grep
    assert_equal ['a'], ['a', 'b', 'c'].grep(/a/)

    # This only works because of our grep_with_regexp_support_for_symbols() monkey patch.
    assert_equal ['a'], [:a, :b, :c].grep(/a/)
  end
end
=end
