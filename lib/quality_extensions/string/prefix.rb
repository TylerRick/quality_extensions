#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# Changes::
#++

class String
  def prefix(prefix)
    sub(/^/, prefix)
  end

  def unprefix(prefix)
    sub(/^#{Regexp.escape(prefix)}/, "")
  end

  def suffix(suffix)
    sub(/$/, suffix)
  end

  def unsuffix(suffix)
    sub(/#{Regexp.escape(suffix)}$/, "")
  end

  #----------------------------------------------------------------------------------------------------

  def prefix_lines(prefix)
    gsub(/^/, prefix)
  end

  def unprefix_lines(prefix)
    gsub(/^#{Regexp.escape(prefix)}/, "")
  end

  def suffix_lines(suffix)
    gsub(/$/, suffix)
  end

  def unsuffix_lines(suffix)
    gsub(/#{Regexp.escape(suffix)}$/, "")
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

describe "String#prefix_lines" do
  it "lets you indent lines, similar to Facets' String#indent(n)" do
    "abc".  prefix_lines('    ').should == '    abc'
    "  abc".prefix_lines('  ').  should == '    abc'

    ("abc\n"   +
     "xyz"     ).prefix_lines('  ').should ==
    ("  abc\n" +
     "  xyz")
  end

  it "lets you comment lines" do
    "abc".  prefix_lines('# ').should == '# abc'
    "  abc".prefix_lines('# ').should == '#   abc'

    ("line 1\n"   +
     "line 2"     ).prefix_lines('# ').should ==
    ("# line 1\n" +
     "# line 2")
  end

  it "lets you uncomment lines" do
    "# abc".  unprefix_lines('# ').should == 'abc'
    "#   abc".unprefix_lines('# ').should == '  abc'

    ("# line 1\n"   +
     "# line 2"     ).unprefix_lines('# ').should ==
    ("line 1\n" +
     "line 2")
  end
end

describe "String#suffix_lines" do
  it "lets you indent lines, similar to Facets' String#indent(n)" do
    "abc".  suffix_lines('    ').should == 'abc    '
    "abc  ".suffix_lines('  ').  should == 'abc    '

    ("abc\n"   +
     "xyz"     ).suffix_lines('  ').should ==
    ("abc  \n" +
     "xyz  ")
  end

  it "lets you add something to the end of each line" do
    "abc". suffix_lines(' \\').should == 'abc \\'
    "abc ".suffix_lines(' \\').should == 'abc  \\'

    ("line 1\n"   +
     "line 2"     ).suffix_lines(' \\').should ==
    ("line 1 \\\n" +
     "line 2 \\")
  end

  it "lets you uncomment lines" do
    "abc \\". unsuffix_lines(' \\').should == 'abc'
    "abc  \\".unsuffix_lines(' \\').should == 'abc '

    ("line 1 \\\n"   +
     "line 2 \\"     ).unsuffix_lines(' \\').should ==
    ("line 1\n" +
     "line 2")
  end
end
=end
