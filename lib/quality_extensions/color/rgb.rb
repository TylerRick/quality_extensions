#--
# Source:     http://tfletcher.com/lib/rgb.rb
# Author::    Tim Fletcher
# Copyright:: Copyright (c) 2008, Tim Fletcher
# License::   Ruby License?
# Submit to Facets?:: Maybe
# Developer notes::
# Changes::
# * 2009-01-11 (Tyler):
#   * Added RGB#to_i, #inspect, #==
#   * Added some tests
#++

class Fixnum # :nodoc:
  def to_rgb
    a, b = divmod(65536)
    b, c = b.divmod(256)
    return [a, b, c]
  end
end

class String # :nodoc:
  def to_rgb
    self.hex.to_rgb
  end
end

class Symbol # :nodoc:
  def to_rgb
    self.to_s.to_rgb
  end
end

module Color # :nodoc:
  #
  # A lightweight implementation of rgb/hex colors, designed for web use.
  #
  #   c = Color::RGB.new(0xFFFFFF)
  #
  #   c.to_s -> "ffffff"
  #
  #   c.red = 196
  #   c.green = 0xDD
  #   c.blue  = 'EE'
  #
  #   c.to_s -> "c4ddee"
  #
  # Similar to (see also) {ColorTools}[http://rubyforge.org/projects/ruby-pdf].
  #
  class RGB

    # :stopdoc:
    [:red, :green, :blue].each do |col|
      define_method(:"#{col}=") { |value| set!(col, value) }
    end
    # :startdoc:
  
    attr_reader :red, :green, :blue

    # The following are the same color:
    #
    #   RGB.new(0xFFFFFF)
    #   RGB.new(:FFFFFF)
    #   RGB.new("FFFFFF")
    #   RGB.new(255, "FF", 0xFF)
    #
    def initialize(*rgb)
      (rgb.size == 1 ? rgb[0].to_rgb : rgb).zip([:red, :green, :blue]) do |(value, col)|
        set!(col, value)
      end
    end

    # Returns the hexadecimal string representation of the color, f.e.:
    #
    #   RGB.new(255, 255, 255).to_s  -> "FFFFFF"
    #
    def to_s
      "%02x%02x%02x" % [ red, green, blue ]
    end

    def inspect
      "<Color::RGB '#{to_s}'>"
    end

    # Returns the integral representation of the color, f.e.:
    #
    #   RGB.new(255, 255, 255).to_i  -> "FFFFFF"
    #
    def to_i
      red*65536 + green*256 + blue
    end

    def ==(other)
      to_s == other.to_s
    end

  protected

    def set!(color, value)
      value = value.hex if value.respond_to?(:hex)
      unless (0..255) === value
        raise ArgumentError, "#{value.inspect} not in range 0..255"
      end
      instance_variable_set(:"@#{color}", value)
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

describe 'Fixnum#to_rgb' do
  it do
    (1).to_rgb.                        should == [0,0,1]
    (65536*2).to_rgb.                  should == [2,0,0]
    (65536*2 + 256*3 + 4).to_rgb.      should == [2,3,4]
    (65536*204 + 256*221 + 255).to_rgb.should == [204,221,255]
    16777215.to_rgb.                   should == [255,255,255]
  end
end

describe 'String#to_rgb' do
  it do
    ('000001').to_rgb.should == [0,0,1]
    ('020000').to_rgb.should == [2,0,0]
    ('020304').to_rgb.should == [2,3,4]
    ('ccddff').to_rgb.should == [204,221,255]
  end
end

describe 'Symbol#to_rgb' do
  it do
    (:'000001').to_rgb.should == [0,0,1]
    (:'020000').to_rgb.should == [2,0,0]
    (:'020304').to_rgb.should == [2,3,4]
    (:ccddff).  to_rgb.should == [204,221,255]
  end
end

describe Color::RGB do
  it "equality" do
    color = Color::RGB.new(0xFFFFFF)
    Color::RGB.new(:FFFFFF).        should == color
    Color::RGB.new("FFFFFF").       should == color
    Color::RGB.new(255, "FF", 0xFF).should == color
  end

  it "to_i" do
    Color::RGB.new(0x000000).to_i.should ==        0
    Color::RGB.new(0x000100).to_i.should ==      256
    Color::RGB.new(0xFFFFFF).to_i.should == 16777215
  end

  it "to_s" do
    Color::RGB.new(0x000000).to_s.should == '000000'
    Color::RGB.new(0x000100).to_s.should == '000100'
    Color::RGB.new(0xFFFFFF).to_s.should == 'ffffff'
  end

  it "inspect" do
    Color::RGB.new(0x000000).inspect.should == "<Color::RGB '000000'>"
  end
end
=end
