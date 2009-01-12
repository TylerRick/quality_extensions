#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Maybe
# Developer notes:: It's probably already been implemented in a better, more efficient way. Will remove when I run across said better implementation...
# Changes::
#++

class Fixnum # :nodoc:
  # Converts to a new base, returning the digits as an array.
  def digits_for_new_base(base, padding = 0)
    digits = []
    if self == 0
      digits = [0]
    else
      remainder = self
      max_exponent = (Math.log(self)/Math.log(base)).to_i
      max_exponent.downto(0) do |exp|
        #puts "#{remainder} / #{base**exp}"
        digit, remainder = remainder.divmod(base**exp)
        digits << digit
      end
    end
    digits.pad(-padding, 0)
  end
  
  def change_base(base, padding = 0, numerals = nil)
    numerals ||= (0..9).to_a + ('a'..'z').to_a
    numerals.map!(&:to_s)

    digits_for_new_base(base, padding).map {|digit| numerals[digit]}.join
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
require 'facets/array/pad'

describe 'Fixnum#digits_for_new_base' do
  it "8" do
    8.digits_for_new_base( 2).should == [1, 0, 0, 0]
    8.digits_for_new_base( 8).should == [      1, 0]
    8.digits_for_new_base(10).should == [         8]
    8.digits_for_new_base(16).should == [         8]
  end

  it do
    (1).                        digits_for_new_base(256, 3).should == [0,0,1]
    (65536*204 + 256*221 + 255).digits_for_new_base(256, 3).should == [204,221,255]
    16777215.                   digits_for_new_base(256, 3).should == [255,255,255]
  end
end

describe 'Fixnum#change_base' do
  it "0" do
    0.change_base(2).should == "0"
  end

  it "8" do
    8.change_base( 2).should == "1000"
    8.change_base( 8).should ==   "10"
    8.change_base(10).should ==    "8"
    8.change_base(16).should ==    "8"
  end

  it "8, padded" do
    8.change_base( 2, 5).should == "01000"
    8.change_base( 8, 5).should == "00010"
    8.change_base(10, 5).should == "00008"
    8.change_base(16, 5).should == "00008"
  end

  it "uses numerals above 9" do
    10.change_base(16).should == "a"
    11.change_base(16).should == "b"
    12.change_base(16).should == "c"
    13.change_base(16).should == "d"
    14.change_base(16).should == "e"
    15.change_base(16).should == "f"
    # ...
    35.change_base(36).should == "z"
  end

  it "17" do
    17.change_base( 2).should == "10001"
    17.change_base( 8).should ==    "21"
    17.change_base(10).should ==    "17"
    17.change_base(16).should ==    "11"
  end

  it "lets you use custom numerals" do
    custom_numerals = %w[) ! @ # $ % ^ & * (]
    0.change_base(16, 0, custom_numerals).should == ")"
    1.change_base(16, 0, custom_numerals).should == "!"
    2.change_base(16, 0, custom_numerals).should == "@"
    3.change_base(16, 0, custom_numerals).should == "#"
  end

end
=end
