#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# Changes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

class Object
  # Returns +self+ if +condition+; otherwise, returns +else_value+.
  #
  # Example:
  #   "Average: #{array.average}". if_else array.size >= 3, ''
  # That is another way to say this:
  #   array.size >= 3 ? "Average: #{array.average}" : '' )
  #
  # Sometimes you want to do 'something unless condition' and you want that whole expression to return '' (or some other value)
  # if the condition is false, rather than nil, which is what it currently returns.
  #
  # *Important*: "+self+" will always be "evaluated". So if the receiver of this message is some _dangerous_ call (has side 
  # effects), then you would be advised to use the normal if/then/else or ?/: constructs instead.
  #
  # For example, +method_with_adverse_side_effects+ will be called unconditionally in this case (whether or not +ready?+ returns +false+):
  #   obj.method_with_adverse_side_effects.   if_else ready?, NotReady
  # But it will not be called in this case if +ready?+ returns +false+:
  #   ready? ? obj.method_with_adverse_side_effects : NotReady)
  #
  # "Isn't this method useless?" ... Yes, basically. Its main advantage is that it lets you put the condition _after_ the normal
  # value, which may make it easier to follow the normal execution flow when reading the source.
  #
  # This is similar to something I saw in another language (Python?) where a similar syntax is built right into the language. Something like this:
  #   normal_value if condition else else_value
  #
  # I thought that was a neat idea so I implemented it as best I could in Ruby.
  #
  # This might also be interesting for folks coming from Smalltalk, where +if+ really _is_ just a message that you pass to an
  # object along with a block (?) to be executed if +condition+ is +true+ and a block to be executed if +condition+ is +false+.
  #
  def if(condition, else_value = nil)
    condition ?
      self :
      else_value
  end
  alias_method :if_else, :if

  def unless(condition, else_value)
    !condition ?
      self :
      else_value
  end
  alias_method :unless_else, :unless
end






#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'test/unit'

require 'rubygems'
require 'quality_extensions/array/average'

class TheTest < Test::Unit::TestCase
  def test_1
    array = [1, 2]
    assert_equal 'not enough values', average(array)
    assert_equal 'not enough values', average_the_normal_way(array)

    array = [1, 2, 3]
    assert_equal 'average = 2.0', average(array)
    assert_equal 'average = 2.0', average_the_normal_way(array)
  end

  # This way is actually easier to read, so you'd be pretty silly to use if_else in this case!
  def average_the_normal_way(array)
    array.size >= 3 ?
      "average = #{array.average}" :
      'not enough values'
  end

  def average(array)
    "average = #{array.average}".if_else( array.size >= 3, 'not enough values' )
  end





  def test_2
    # Sometimes you want to do 'something unless condition' and you want that whole expression to return '' (or some other value)
    # if the condition is false, rather than nil, which is what it currently returns.
    assert_equal nil, render_list_the_naive_way([])
    assert_equal '',  render_list_the_long_way([])
    assert_equal '',  render_list([])

    list = ['Alice', 'Malory']

    [
      render_list_the_naive_way(list),
      render_list_the_long_way(list),
      render_list(list),
    ].each {|a|
      assert_equal '<ul><li>Alice</li><li>Malory</li></ul>', a
    }

  end

  def render_list_the_naive_way(list)
    content_tag(:ul,
      list.map { |item|
        content_tag(:li,
          item
        )
      }
    ) unless list.empty?
  end
  def render_list_the_long_way(list)
    unless list.empty?
      content_tag(:ul,
        list.map { |item|
          content_tag(:li,
            item
          )
        }
      )
    else
      ''
    end
  end
  def render_list(list)
    content_tag(:ul,
      list.map { |item|
        content_tag(:li,
          item
        )
      }
    ).   unless_else list.empty?, ''
  end

  def content_tag(tag, contents)
    "<#{tag}>#{contents}</#{tag}>"
  end
end
=end


