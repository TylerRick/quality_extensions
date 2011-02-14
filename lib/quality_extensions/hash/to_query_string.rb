#--
# Author::    Anthony Kaufman, Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
autoload :CGI, 'cgi'
require 'rubygems'
require 'facets/kernel/require_relative'
require_relative '../array/to_query_string.rb'

class Hash

=begin rdoc
  Converts into a string that can be used as the {query string}[http://en.wikipedia.org/wiki/Query_string] of a URL (for example, <tt>?key1=val1&key2=val2</tt>).

  Example:
    {
      'colors' => ['red', 'blue'],
      'username' => 'pineapple'
    }.to_query_string('data')
    ==> "data[username]=pineapple&data[colors][]=red&data[colors][]=blue"

  The hash can be nested as deeply as you want and can also contain arrays.

  <tt>key</tt> is the name of the key in params that will receive this hash when you load the page. So, for example, if you go to page with this query string (key = "name"): <tt>?name[first]=Fred&name[last]=Fredson</tt>, params will be have a key "name", like so: <tt>{"name"=>{"last"=>"Fredson", "first"=>"Fred"}}</tt>.

    {
      'colors' => ['red', 'blue'],
      'username' => 'pineapple'
    }.to_query_string('data')

  is equivalent to just writing your hash like so:

    {
      'data' => {
        'colors' => ['red', 'blue'],
        'username' => 'pineapple'
      }
    }.to_query_string()
=end
  def to_query_string(key = '')
    prefix = key.dup
    elements = []

    self.each_pair do |key, value|
      key = CGI.escape key.to_s
      key = prefix.length > 1 ? "#{prefix}[#{key}]" : key
      if value.respond_to? :to_query_string
        valuepre = value.dup
        value = value.to_query_string(key)
        #puts "#{key}#{valuepre.inspect} => #{value}"
        elements << value
      else
        value = CGI.escape value.to_s
        elements << key + '=' + value
      end
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
require 'rubygems'
require 'set'

class TheTest < Test::Unit::TestCase
  def test_hash_to_query_string_nesting
    data = {
      'foo' => 'bar',
      'names' => {
        'common' => 'smith',
        'uncommon' => {
          :first => 'lance',
          :last => 'wilheiminkauf'
        }
      }
    }
    assert_equal ['foo=bar', 'names[common]=smith', 'names[uncommon][first]=lance', 'names[uncommon][last]=wilheiminkauf'].to_set,
                  data.to_query_string.split(/&/).to_set
  end
  def test_hash_to_query_string_nesting_2
    data = {
        'common' => 'smith',
        'uncommon' => [
          'frankenwatzel',
          'wilheiminkauf'
        ]
    }
    assert_equal 'names[common]=smith&names[uncommon][]=frankenwatzel&names[uncommon][]=wilheiminkauf', data.to_query_string('names')
    assert_equal( {'names' => data}.to_query_string(),
                  data.to_query_string('names') )
  end

  def test_hash_to_query_string_encoding
    data = {'f&r' => 'a w$'}

    assert_equal 'f%26r=a+w%24', data.to_query_string
  end
end
=end

=begin examples
require 'irb/xmp'
xmp <<End
    {
      'colors' => ['red', 'blue'],
      'username' => 'pineapple'
    }.to_query_string('data')
    {
      'data' => {
        'colors' => ['red', 'blue'],
        'username' => 'pineapple'
      }
    }.to_query_string()
End
=end
