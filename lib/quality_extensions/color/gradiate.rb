#--
# Source:     http://tfletcher.com/lib/gradiate.rb
# Author::    Tim Fletcher
# Copyright:: Copyright (c) 2008, Tim Fletcher
# License::   Ruby License?
# Submit to Facets?:: No
# Developer notes::
# Changes::
#++

require 'facets/kernel/require_local'
require_local 'rgb'
require_local '../numeric/diff'
require_local '../enumerable/every'

module Enumerable

  # Sorts objects in the enumeration and applies a color scale to them.
  #
  # Color ranges must be in the form [x, y], where x and y are either fixnums
  # (e.g. 255, 0xFF) or hexadecimal strings (e.g. 'FF').
  #
  # Ranges can be provided for each RGB color e.g.
  #
  #   gradiate(:red => red_range)
  #
  # ...and a default range (for all colors) can be set using :all e.g.
  #
  #   gradiate(:all => default_range, :green => green_range)
  #
  # If no color ranges are supplied then the _sorted_ enumeration will be returned.
  #
  # Objects contained in the enumeration are expected to have a color (or colour)
  # attribute/method that returns a <tt>Color::RGB</tt> object (or similar).
  #
  # By default, objects are sorted using <tt>:to_i</tt>. This can be overidden
  # by setting <tt>options[:compare_using]</tt> to a different method symbol.
  #
  # By default, objects are ordered "smallest" first. To reverse this set
  # <tt>options[:order]</tt> to either <tt>:desc</tt> or <tt>:reverse</tt>.
  #
  def gradiate(options={})
    ranges = [:red, :green, :blue].map do |col|
      if range = (options[col] || options[:all])
        a, b = range.map { |x| x.respond_to?(:hex) ? x.hex : x.to_i }
        a, b = b, a if a > b # smallest first
        c = b.diff(a) / (self.size - 1)
        next (a..b).every(c)
      else [] end
    end

    objects = sort_by { |object| object.send(options[:compare_using] || :to_i) }
    objects = objects.reverse if [:desc, :reverse].include?(options[:order])
    objects.zip(*ranges).collect do |object, red, green, blue|
      color = object.respond_to?(:colour) ? object.colour : object.color
      color.red = red if red
      color.green = green if green
      color.blue = blue if blue
      next object
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
require 'spec'
Spec::Runner.options.colour = true
ENV['AUTOTEST'] = '1'

describe Enumerable.instance_method(:gradiate) do
  class Thing < ::Struct.new(:name, :color)
  end

  it "works when gradiating from 'cc' to 'dd' for all components" do
    results = [
       Thing.new('d', Color::RGB.new(  0,  0,  0)),
       Thing.new('c', Color::RGB.new(  0,  0,  0)),
       Thing.new('b', Color::RGB.new(  0,  0,  0)),
       Thing.new('a', Color::RGB.new(  0,  0,  0)),
    ].gradiate :all => ['cc', 'dd'], :compare_using => :name

    results.map(&:name).should == %w[a b c d]

    results.map(&:color)[0].should == Color::RGB.new(0xcccccc)
    results.map(&:color)[1].should == Color::RGB.new(0xd1d1d1)
    results.map(&:color)[2].should == Color::RGB.new(0xd6d6d6)
    results.map(&:color)[3].should == Color::RGB.new(0xdbdbdb)

    results.map(&:color).map(&:red).enum_cons(2).map {|a,b| b-a}.map {|a| a == 5}.should be_all
  end

  it "works when gradiating from '00' to 'ff' for red component" do
    results = [
       Thing.new('ruby',      Color::RGB.new(255,  0,  0)),
       Thing.new('apple',     Color::RGB.new(  0,255,  0)),
       Thing.new('blueberry', Color::RGB.new(  0,  0,255)),
    ].gradiate :red => ['00', 'ff'], :compare_using => :name

    results.map(&:color)[0].should == Color::RGB.new(0x00ff00)
    results.map(&:color)[1].should == Color::RGB.new(0x7f00ff)
    results.map(&:color)[2].should == Color::RGB.new(0xfe0000)
  end

end
=end
