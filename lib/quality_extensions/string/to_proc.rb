# String#to_proc
#
# See http://weblog.raganwald.com/2007/10/stringtoproc.html ( Subscribe in a reader)
#
# Ported from the String Lambdas in Oliver Steele's Functional Javascript
# http://osteele.com/sources/javascript/functional/
#
# This work is licensed under the MIT License:
#
# (c) 2007 Reginald Braithwaite
# Portions Copyright (c) 2006 Oliver Steele
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class String
  unless ''.respond_to?(:to_proc)
    def to_proc &block
      params = []
      expr = self
      sections = expr.split(/\s*->\s*/m)
      if sections.length > 1 then
          eval sections.reverse!.inject { |e, p| "(Proc.new { |#{p.split(/\s/).join(', ')}| #{e} })" }, block && block.binding
      elsif expr.match(/\b_\b/)
          eval "Proc.new { |_| #{expr} }", block && block.binding
      else
          leftSection = expr.match(/^\s*(?:[+*\/%&|\^\.=<>\[]|!=)/m)
          rightSection = expr.match(/[+\-*\/%&|\^\.=<>!]\s*$/m)
          if leftSection || rightSection then
              if (leftSection) then
                  params.push('$left')
                  expr = '$left' + expr
              end
              if (rightSection) then
                  params.push('$right')
                  expr = expr + '$right'
              end
          else
              self.gsub(
                  /(?:\b[A-Z]|\.[a-zA-Z_$])[a-zA-Z_$\d]*|[a-zA-Z_$][a-zA-Z_$\d]*:|self|arguments|'(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*"/, ''
              ).scan(
                /([a-z_$][a-z_$\d]*)/i
              ) do |v|
                params.push(v) unless params.include?(v)
              end
          end
          eval "Proc.new { |#{params.join(', ')}| #{expr} }", block && block.binding
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
require 'spec/autorun'

describe "String to Proc" do

  before(:all) do
    @one2five = 1..5
  end

  it "should handle simple arrow notation" do
    @one2five.map(&'x -> x + 1').should eql(@one2five.map { |x| x + 1 })
    @one2five.map(&'x -> x*x').should eql(@one2five.map { |x| x*x })
    @one2five.inject(&'x y -> x*y').should eql(@one2five.inject { |x,y| x*y })
    'x y -> x**y'.to_proc()[2,3].should eql(lambda { |x,y| x**y }[2,3])
    'y x -> x**y'.to_proc()[2,3].should eql(lambda { |y,x| x**y }[2,3])
  end

  it "should handle chained arrows" do
    'x -> y -> x**y'.to_proc()[2][3].should eql(lambda { |x| lambda { |y| x**y } }[2][3])
    'x -> y z -> y**(z-x)'.to_proc()[1][2,3].should eql(lambda { |x| lambda { |y,z| y**(z-x) } }[1][2,3])
  end

  it "should handle the default parameter" do
    @one2five.map(&'2**_/2').should eql(@one2five.map { |x| 2**x/2 })
    @one2five.select(&'_%2==0').should eql(@one2five.select { |x| x%2==0 })
  end

  it "should handle point-free notation" do
    @one2five.inject(&'*').should eql(@one2five.inject { |mem, var| mem * var })
    @one2five.select(&'>2').should eql(@one2five.select { |x| x>2 })
    @one2five.select(&'2<').should eql(@one2five.select { |x| 2<x })
    @one2five.map(&'2*').should eql(@one2five.map { |x| 2*x })
    (-3..3).map(&'.abs').should eql((-3..3).map { |x| x.abs })
  end

  it "should handle implied parameters as best it can" do
    @one2five.inject(&'x*y').should eql(@one2five.inject(&'*'))
    'x**y'.to_proc()[2,3].should eql(8)
    'y**x'.to_proc()[2,3].should eql(8)
  end

end
=end

