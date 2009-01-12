#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2009, Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# Changes::
#++

class String

  def prefix_lines(prefix)
    gsub(/^/, prefix)
  end

  def unprefix_lines(prefix)
    gsub(/^#{Regexp.escape(prefix)}/, "")
  end

  # TODO:
  #def suffix_lines(suffix)
  #def unsuffix_lines(suffix)

end


#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'spec'

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
=end
