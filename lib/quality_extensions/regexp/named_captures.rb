# http://tfletcher.com/lib/named_captures.rb
require 'strscan'

class Module
  # c.f. ActiveSupport
  def alias_method_chain(target, feature)
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?
    alias_method "#{aliased_target}_without_#{feature}#{punctuation}", target
    alias_method target, "#{aliased_target}_with_#{feature}#{punctuation}"
  end unless method_defined?(:alias_method_chain)
end

class MatchData
  attr_accessor :capture_names
  
  def method_missing(capture_name, *args, &block)
    if index = capture_names.index(capture_name)
      return self[index + 1]
    else
      super capture_name, *args, &block
    end
  end
end

class Regexp
  def match_with_named_captures(pattern)
    matchdata = match_without_named_captures(pattern)
    matchdata.capture_names = capture_names if matchdata.respond_to?(:capture_names=)
    matchdata
  end

  alias_method_chain :match, :named_captures

  def capture_names
    @capture_names ||= extract_capture_names_from(source)
  end

  private
  
  def extract_capture_names_from(pattern)
    names, scanner, last_close = [], StringScanner.new(pattern), nil
    
    while scanner.skip_until(/\(/)
      next if scanner.pre_match =~ /\\$/

      if scanner.scan(/\?\#(.+?)(?=\))/)
        if scanner[1] =~ /^:(\w+)$/
          names[last_close] = $1.to_sym
        end
      else
        names << :capture
      end
      
      while scanner.skip_until(/[()]/)
        if scanner.matched =~ /\)$/
          (names.size - 1).downto(0) do |i|
            if names[i] == :capture
              names[last_close = i] = nil
              break
            end
          end
        else
          scanner.unscan
          break
        end
      end
    end
    
    return names
  end
end

if __FILE__ == $0 then
  require 'test/unit'
  
  class NamedCapturesTest < Test::Unit::TestCase
    def test_escaped_brackets_are_ignored
      assert /\(\)\(\)/.capture_names.empty?
    end
    def test_normal_comments_are_ignored
      assert /(?#a comment)/.capture_names.empty?
    end
    def test_unnamed_captures_are_nil
      assert_equal Array.new(4), /()()()()/.capture_names
      assert_equal Array.new(4), /(((())))/.capture_names
    end
    def test_named_captures
      assert_equal [nil, :foo, nil], /()()(?#:foo)()/.capture_names
      assert_equal [nil, :bar, nil], /((())(?#:bar))/.capture_names
    end
    def test_typical_usage
      date = /(\d+)(?#:day)\/(\d+)(?#:month)\/(\d+)(?#:year)/.match('03/12/2006')
      assert_equal 3, date.day.to_i
      assert_equal 12, date.month.to_i
      assert_equal 2006, date.year.to_i
    end
  end
end
