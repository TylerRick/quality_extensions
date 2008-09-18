#--
# Author::    Anthony Kaufman, Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

autoload :CGI, 'cgi'
class Array

=begin rdoc
  Converts into a string that can be used as the {query string}[http://en.wikipedia.org/wiki/Query_string] of a URL (for example, <tt>?key[]=val1&key[]=val2</tt>).

  Example:
    [
      'Fred',
      'Sam'
    ].to_query_string('names')
    ==> "names[]=Fred&names[]=Sam"

  <tt>key</tt> is the name of the key in params that will receive the array when you load the page. So, for example, if you go to page with this query string (key = "names"): <tt>?names[]=Fred&names[]=Sam</tt>, params will be have a key "names", like so: <tt>{"names"=>["Fred", "Sam"]}</tt>.
=end
  def to_query_string(key)
    elements = []
    
    self.each do |value|
      _key = key + '[]'
      if value.is_a? Array
        raise "Array#to_query_string only works on flat (1-dimensional) arrays."
      elsif value.respond_to? :to_query_string
      	value = value.to_query_string(_key)
      else
        value = CGI.escape value.to_s
      end
      elements << _key + '=' + value
    end
    
    elements.join('&')
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
  #-------------------------------------------------------------------------------------------------
  # Array:

  def test_array_to_query_string_trivial
    data = []
    assert_equal '', data.to_query_string('names')
  end

  def test_array_to_query_string_basic
    data = [
      'Fred',
      'Sam'
    ]
    assert_equal 'names[]=Fred&names[]=Sam', data.to_query_string('names')
  end
  
  def test_array_to_query_string_encoding
    data = ['f&r', 'a w$']
    
    assert_equal 'foo[]=f%26r&foo[]=a+w%24', data.to_query_string('foo')
  end

  def test_array_to_query_string_nesting
    data = [
        [
          'Wilma',
          'Sara'
        ],
        [
          'Fred',
          'Sam'
        ]
      ]
    assert_raise RuntimeError do data.to_query_string('names') end
  end
end
=end

=begin examples
require 'irb/xmp'
xmp <<End
    [
      'Fred',
      'Sam'
    ].to_query_string('names')
End
=end
