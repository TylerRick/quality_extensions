#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# Changes::
#++

require 'facets/array/delete_values'

class Array
  # Like partition, in that it creates two arrays, the first containing the elements of
  # <i>enum</i> for which the block evaluates to false, the second
  # containing the rest, only instead of returning both arrays, it changes +self+ for the first array (those for which the block evaluates to false)
  # and thus only needs to return the second array (those for which the block evaluates to true)
  #
  # this is analagous to what shift (or pop) does: it shifts (or pops) an element off of a collection and simultaneously returns that element which was shifted (or popped) off
  #
  # Example:
  #
  #   orig_a = a = (1..6).to_a
  #   b = a.select_if! {|i| i % 3 == 0}   # => [1, 2, 4, 5] 
  #   a                                   # => [3, 6]
  #
  # This is identical to doing this:
  #   orig_a = a = (1..6).to_a
  #   a, b = a.partition {|i| i % 3 == 0}
  #   a                                   # => [3, 6]
  #   b                                   # => [1, 2, 4, 5] 
  #
  # except that in the case of partition, orig_a and a are now to different objects, whereas with select_if, a remains the same object and is modified in place.
  #
  # name?:
  #   modify!
  #   select_if_returning_deleted
  #   shift_if :)
  #
  def select_if!(&block)
    d = []
    each{ |v| d << v unless yield v}
    delete_values(*d)
    d
  end

  #
  # Note that self is not modified (the values are not deleted) until it has finished iterating through elements and has given a chance for you to decide the fate of each element.
  # (So if, for instance, you want to refer to the previous value, you can do that with select_if_with_index! by using array[i-1], even if array[i-1] is "scheduled for deletion", because it will not have been deleted yet.)
  #
  # Example:
  # args_for_vim = ARGV.delete_if! {|arg, i|
  #   arg =~ /^-c/ || ARGV[i-1] =~ /^-c/ \
  #     || arg =~ /^\+/
  # }
  # 
  def select_if_with_index!(&block)
    d = []
    each_with_index{ |v,i| d << v unless yield v,i}
    delete_values(*d)
    d
  end

  # Like partition, in that it creates two arrays, the first containing the elements of
  # <i>enum</i> for which the block evaluates to false, the second
  # containing the rest, only instead of returning both arrays, it changes +self+ for the first array (those for which the block evaluates to false)
  # and thus only needs to return the second array (those for which the block evaluates to true)
  #   (1..6).partition {|i| i % 3 == 0} # => [[3, 6], [1, 2, 4, 5]]
  #
  #   a = (1..6).to_a
  #   a.delete_if! {|i| i % 3 == 0}     # => [3, 6]
  #   a                                 # => [1, 2, 4, 5]
  #
  # similar to delete_if / reject!, but modifies self in place (removes elements from self) and rather than simply discarding the deleted elements, it returns an array containing those elements removed (similar to partition)
  #
  # a more generic version of Facets' delete_values; that can only be used to delete if a value matches exactly; this can use any arbitrary comparison to determine whether or not to delete element
  #
  # name?:
  #   modify!
  #   delete_if_returning_deleted
  #   shift_unless :)
  #
  def delete_if!(&block)
    d = []
    #each{ |v| d << delete(v) if yield v; puts "yield #{v} returned #{yield v}"}  # didn't work because the deleting messed up the each and not all elements were visited
    each{ |v| d << v if yield v}
    delete_values(*d)
    d
  end
end







#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec'

describe '' do
  it "delete_if! { el == 'a'}" do
    orig = %w[a b c]
    deleted = orig.delete_if! {|el| el == 'a'}

    deleted.should == %w[a]
    orig   .should == %w[b c]
  end

  it "delete_if! { ... == el.upcase}" do
    orig = %w[a b A B]
    deleted = orig.delete_if! {|el| el.upcase == el}

    deleted.should == %w[A B]
    orig   .should == %w[a b]
  end

  it "delete_if! { ... == i % 3 == 0}" do
    a = (1..6).to_a
   (d = a.delete_if! {|i| i % 3 == 0}).should == [3, 6]
    a                                 .should == [1, 2, 4, 5]
  end

  it "select_if! { ... == i % 3 == 0}" do
    orig_a = a = (1..6).to_a
   (d = a.select_if! {|i| i % 3 == 0}).should == [1, 2, 4, 5] 
    a                                 .should == [3, 6]
    a.object_id.should == orig_a.object_id
  end

  it "unlike when using partition, keeps its identity" do
    orig_a = a = (1..6).to_a
    a, b = a.partition {|i| i % 3 == 0}
    a.should == [3, 6]
    b.should == [1, 2, 4, 5]
    a.object_id.should_not == orig_a.object_id
  end

end
=end
