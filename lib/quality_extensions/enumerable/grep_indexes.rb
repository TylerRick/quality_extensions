#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2012, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++


module Enumerable
  # Returns the indexes of the elements that match +regexp+.
  #
  # %w[a ab abc].grep_indexes(/a$/) => [0]
  # %w[a ab abc].grep_indexes(/b/)  => [1, 2]
  #
  def grep_indexes(regexp)
    indexes = []
    each_with_index {|el, i|
      indexes << i if el =~ regexp
    }
    indexes
  end
end

#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'rspec/autorun'

describe 'Enumerable#grep_indexes' do

  describe %w[a ab abc] do
    it { subject.grep_indexes(/a$/).should == [0      ] }
    it { subject.grep_indexes(/a/). should == [0, 1, 2] }
    it { subject.grep_indexes(/b/). should == [   1, 2] }
    it { subject.grep_indexes(/c/). should == [      2] }
  end

  describe [
    "gems/ruby-debug-base19x-0.11.30.pre10/lib/ruby-debug-base.rb:55:in `at_line'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/base.rb:52:in `rescue in synchronize'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/base.rb:44:in `synchronize'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/finders.rb:29:in `find'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/element.rb:177:in `block in find'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/base.rb:45:in `synchronize'",
    "bundler/gems/capybara-555008c74751/lib/capybara/node/element.rb:177:in `find'",
    "features/step_definitions/web_steps.rb:163:in `select'",
    "bundler/gems/capybara-555008c74751/lib/capybara/session.rb:291:in `select'",
    "bundler/gems/capybara-555008c74751/lib/capybara/dsl.rb:43:in `select'",
    "features/step_definitions/javascript_steps.rb:87:in `block (2 levels) in <top (required)>'",
  ] do
    it do
      subject.grep(/in `synchronize'/).should == [
        "bundler/gems/capybara-555008c74751/lib/capybara/node/base.rb:44:in `synchronize'",
        "bundler/gems/capybara-555008c74751/lib/capybara/node/base.rb:45:in `synchronize'",
      ]
    end
    it { subject.grep_indexes(/in `synchronize'/).should == [2, 5] }
  end
end
=end
