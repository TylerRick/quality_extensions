#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# Changes::
# To do::
# * !! Why does Hash#each_with_index yield |(k,v), i| but my select_with_index yields flat |k, v, i| ?
#++

require 'facets/kernel/require_local'
require_local 'select_with_index'

module Enumerable
  # Original version before I changed it to use select so that Hash#select_until would return a hash instead of an array.
#  def select_until(inclusive = true)
#    return self unless block_given?
#
#    selected = []
#    if inclusive
#      each do |item|
#        selected << item
#        break if yield(item)
#      end
#    else
#      each do |item|
#        break if yield(item)
#        selected << item
#      end
#    end
#    selected
#  end

  # Returns an array containing all _consecutive_ elements of +enum+ for which +block+ is not false, starting at the first element.
  # So it is very much like +select+, but unlike +select+, it stops searching as soon as +block+ ceases to be true. (That means it will stop searching immediately if the first element doesn't match.)
  #
  # This might be preferable to +select+, for example, if:
  # * you have a very large collection of elements
  # * the desired elements are expected to all be consecutively occuring and are all at the beginning of the collection
  # * it would be costly to continue iterating all the way to the very end
  #
  # If +inclusive+ is false, only those elements occuring _before_ the first element for which +block+ is true will be returned.
  # If +inclusive+ is true (the default), those elements occuring up to and _including_ the first element for which +block+ is true will be returned.
  #
  # Examples:
  #
  # (0..3).select_until        {|v| v == 1} # => [0, 1]
  # (0..3).select_until(false) {|v| v == 1} # => [0]
  #
  # {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until        {|k, v| v == 2} ) # => {"a"=>1, "b"=>2}
  # {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false) {|k, v| v == 2} ) # => {"a"=>1}
  #
  # puts caller # => 30 lines of context, many of them so far removed that they are irrelevant
  # puts caller.select_until {|l| l =~ %r(/app/) } # only print the stack back to the first frame from our own code
  #
  def select_until(inclusive = true)
    return self unless block_given?

    done = false
    if inclusive
      select do |*args|
        returning = !done
        done = true if yield(*args)
        returning
      end
    else
      select do |*args|
        done = true if yield(*args)
        !done
      end
    end
  end

  # Same as select_until but each time an element of the enum is yielded, an index/counter is also included as an argument.
  #
  # This is probably only useful for collections that have some kind of predictable ordering (such as Arrays). Fortunately, Hashes have a predictable order in Ruby 1.9.
  #
  def select_until_with_index(inclusive = true)
    return self unless block_given?

    done = false
    if inclusive
      select_with_index do |*args|
        returning = !done
        done = true if yield(*args)
        returning
      end
    else
      select_with_index do |*args|
        done = true if yield(*args)
        !done
      end
    end
  end

  # Better name? select_consec?
  def select_while(include_first_false_element = false)
    return self unless block_given?

    done = false
    if include_first_false_element
      select do |*args|
        returning = !done
        done = true if !yield(*args)
        returning
      end
    else
      select do |*args|
        #puts "!done=#{!done};  !yield(#{args}) => #{!yield(*args)}"
        done = true if !yield(*args)
        !done
      end
    end
  end

  def select_while_with_index(include_first_false_element = false)
    return self unless block_given?

    done = false
    if include_first_false_element
      select_with_index do |*args|
        returning = !done
        done = true if !yield(*args)
        returning
      end
    else
      select_with_index do |*args|
        #puts "!done=#{!done};  !yield(#{args}) => #{!yield(*args)}"
        done = true if !yield(*args)
        !done
      end
    end
  end

  # Whereas select_until goes until it reaches the _first_ element for which +block+ is true, select_until_last  goes until it reaches the _last_ element for which +block+ is true.
  #
  def select_until_last(inclusive = true)
    return self unless block_given?

    # Find the index of the last-matching element
    last = nil
    #each_with_index do |item, i|
    #  last = i if yield(item)
    #end
    each_with_index do |*args|
      i = args.pop
      last = i if yield(*args.first)
    end

    # If they want to exclude the last-matching element, adjust the index by -1 (if possible)
    #if last && !inclusive
    #  if last == 0
    #    # If the last-matching element was also the first element, then we want to select *none* of the elements
    #    last = nil
    #  else
    #    last -= 1
    #  end
    #end
    # Select all elements up to last-matching element
    #self.to_a[0 .. last]   # (didn't work for hashes)
    #select_with_index do |item, i|
    #  true if last && i <= last
    #end
    #select_while_with_index do |item, i|
    #  #puts "#{i} <= #{last} => #{last && i <= last}"
    #  last && i <= last
    #end

    # Select all elements up to last-matching element
    if last.nil?
      select do |*args|
        false
      end
    else
      select_until_with_index(inclusive) do |*args|
        i = args.last
        i == last
      end
    end
  end

  def select_until_last_with_index(inclusive = true)
    return self unless block_given?

    # Find the index of the last-matching element
    last = nil
    each_with_index do |*args|
      #p args
      i = args.last
      last = i if yield(*args)
    end

    # Select all elements up to last-matching element
    if last.nil?
      select do |*args|
        false
      end
    else
      select_until_with_index(inclusive) do |*args|
        i = args.last
        i == last
      end
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
require 'facets/string/indent'

class SelectWhileAndUntilTest < Test::Unit::TestCase
  def test_basic_usage
    assert_equal [0, 1], (0..3).select              {|v| v <= 1}
    assert_equal [0, 1], (0..3).select_while        {|v| v <= 1}
    assert_equal [0, 1], (0..3).select_until        {|v| v == 1}
    assert_equal [0],    (0..3).select_until(false) {|v| v == 1}
  end

  def test_basic_usage_with_index
    assert_equal %w[a b], %w[a b c].select_with_index              {|v, i| i <= 1}
    assert_equal %w[a b], %w[a b c].select_while_with_index        {|v, i| i <= 1}
    assert_equal %w[a b], %w[a b c].select_until_with_index        {|v, i| i == 1}
    assert_equal %w[a],   %w[a b c].select_until_with_index(false) {|v, i| i == 1}
  end

  def test_when_no_matches_found
    assert_equal [],  (0..3).select              {|v| false}
    assert_equal [],  (0..3).select_while        {|v| false}
    assert_equal [0], (0..3).select_until        {|v| true}
    assert_equal [],  (0..3).select_until(false) {|v| true}
  end

  def test_with_hashes_basic_usage
    if RUBY_VERSION < '1.9'
      # Yuck! Hash#select returns an array instead of returning a hash like reject.
      assert_equal [["a", 1], ["b", 2], ["d", 1]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select              {|k, v| v <= 2}
      assert_equal [["a", 1], ["b", 2]          ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while        {|k, v| v <= 2}
      assert_equal [["a", 1], ["b", 2]          ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until        {|k, v| v == 2}
      assert_equal [["a", 1]                    ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false) {|k, v| v == 2}
    else
      assert_equal( {"a"=>1, "b"=>2, "d"=>1},      {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select              {|k, v| v <= 2})
      assert_equal( {"a"=>1, "b"=>2},              {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while        {|k, v| v <= 2} )
      assert_equal( {"a"=>1, "b"=>2},              {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until        {|k, v| v == 2} )
      assert_equal( {"a"=>1},                      {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false) {|k, v| v == 2} )
    end
  end

  def test_with_hashes_basic_usage_with_index
    if RUBY_VERSION < '1.9'
      assert_equal [["a", 1], ["b", 2]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_with_index              {|k, v, i| i <= 1}
      assert_equal [["a", 1], ["b", 2]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while_with_index        {|k, v, i| i <= 1}
      assert_equal [["a", 1], ["b", 2]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_with_index        {|k, v, i| i == 1}
      assert_equal [["a", 1]          ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_with_index(false) {|k, v, i| i == 1}
    else
      assert_equal( {"a"=>1, "b"=>2},    {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_with_index              {|k, v, i| i <= 1} )
      assert_equal( {"a"=>1, "b"=>2},    {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while_with_index        {|k, v, i| i <= 1} )
      assert_equal( {"a"=>1, "b"=>2},    {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_with_index        {|k, v, i| i == 1} )
      assert_equal( {"a"=>1},            {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_with_index(false) {|k, v, i| i == 1} )
    end
  end

  def test_with_hashes_when_no_matches_found
    if RUBY_VERSION < '1.9'
      assert_equal [],         {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select              {|k, v| false}
      assert_equal [],         {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while        {|k, v| false}
      assert_equal [["a", 1]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until        {|k, v| true}
      assert_equal [],         {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false) {|k, v| true}
    else
      assert_equal( {},        {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select              {|k, v| false})
      assert_equal( {},        {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_while        {|k, v| false} )
      assert_equal( {"a"=>1},  {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until        {|k, v| true} )
      assert_equal( {},        {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false) {|k, v| true} )
    end
  end


  def test_show_how_it_differs_from_plain_old_select
    # Ah, yes, it behaves the same as select in *this* simple case:
    assert_equal [1, 2], (1..4).select {|v| v <= 2}

    # But what about _this_ one... hmm?
    assert_equal [1, 2],       [1, 2, 3, 2, 1].select_while {|v| v <= 2}
    assert_equal [1, 2, 2, 1], [1, 2, 3, 2, 1].select       {|v| v <= 2}  # Not the same! Keyword: _consecutive_.

    # Or _this_ one...
    assert_equal [1, 2, 1],  [1, 2, 1, 99, 2].select_while {|v| v <= 2}
    assert_equal [1, 2],     [1, 2, 1, 99, 2].select {|v| v <= 2}.uniq    # Even this isn't the same.
  end

  def test_example_use_of_inclusive_option
    # Let's say we have an array with these lines of code:
    lines_of_code = <<-End.indent(-6).lines.map(&:chomp)
      def a
        :a
      end
      def b
        :b
      end
    End
    #puts lines_of_code.to_a
    # ... and we want to match up to and including the first line that matches /end/.

    assert_equal [
        'def a',
        '  :a',
      ],
      lines_of_code.select_until(false) {|line| line =~ /end/}
    # It didn't go far enough. We actually want to *include* that last element. This is when we'd want to use inclusive=true.

    assert_equal [
        'def a',
        '  :a',
        'end',
      ],
      lines_of_code.select_until(true) {|line| line =~ /end/}

    assert_equal [
        'def a',
        '  :a',
      ],
      lines_of_code.select_while(false) {|line| line !~ /end/}

    # Although a bit contrived, this is an example of when you might want to use include_first_false_element = true
    # In practice, you'd probably seldom have a use for it, but I thought I should include it just to be consistent with select_until. Disagree?
    assert_equal [
        'def a',
        '  :a',
        'end',
      ],
      lines_of_code.select_while(true) {|line| line !~ /end/}
  end
end

class SelectUntilLastTest < Test::Unit::TestCase
  def test_simplest_case
    assert_equal [1], [1].select_until_last        {|v| v == 1}
    assert_equal [],  [1].select_until_last(false) {|v| v == 1}  # if exclusive, we won't even return the one and only element
  end

  def test_basic_usage
    assert_equal [1, 2, 1],  [1, 2, 1, 2].select_until_last        {|v| v == 1}
    assert_equal [1, 2],     [1, 2, 1, 2].select_until_last(false) {|v| v == 1}
  end

  def test_basic_usage_with_index
    assert_equal %w[a b], %w[a b c].select_until_last_with_index        {|v, i| i == 1}
    assert_equal %w[a],   %w[a b c].select_until_last_with_index(false) {|v, i| i == 1}
  end

  def test_when_no_matches_found
    assert_equal [], [1, 2, 1, 2].select_until_last                   {|v| v == 3}
    assert_equal [], [1, 2, 1, 2].select_until_last(false)            {|v| v == 3}
    assert_equal [], [1, 2, 1, 2].select_until_last_with_index(false) {|v, i| v == 3}
    # It should be the same as doing this:
    assert_equal [], [1, 2, 1, 2].select                              {|v| false}
  end

  def test_with_hashes_basic_usage
    if RUBY_VERSION < '1.9'
      assert_equal [["a", 1]],                               {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until             {|k, v| v == 1}
      assert_equal [        ],                               {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false)      {|k, v| v == 1}

      # See the difference:
      assert_equal [["a", 1], ["b", 2], ["c", 3], ["d", 1]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last        {|k, v| v == 1}
      assert_equal [["a", 1], ["b", 2], ["c", 3]          ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last(false) {|k, v| v == 1}
    else
      assert_equal( {"a"=>1},                         {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until             {|k, v| v == 1} )
      assert_equal( {},                               {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until(false)      {|k, v| v == 1} )

      # See the difference:
      assert_equal( {"a"=>1, "b"=>2, "c"=>3, "d"=>1}, {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last        {|k, v| v == 1} )
      assert_equal( {"a"=>1, "b"=>2, "c"=>3        }, {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last(false) {|k, v| v == 1} )
    end
  end

  def test_with_hashes_basic_usage_with_index
    if RUBY_VERSION < '1.9'
      assert_equal [["a", 1], ["b", 2]], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last_with_index        {|(k, v), i| p=[k,v,i]; i <= 1}
      assert_equal [["a", 1]          ], {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last_with_index(false) {|(k, v), i| i == 1}
    else
      assert_equal( {"a"=>1, "b"=>2}, {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last_with_index        {|(k, v), i| p=[k,v,i]; i <= 1} )
      assert_equal( {"a"=>1        }, {'a'=>1, 'b'=>2, 'c'=>3, 'd'=>1}.select_until_last_with_index(false) {|(k, v), i| i == 1} )
    end
  end

end
=end


