#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2012, Tyler Rick
# License::   Ruby License
# Submit to Facets?:: Yes
# Developer notes::
# History::
#++


require 'facets/enumerable/map_send'
require_relative 'grep_indexes'

module Enumerable
  # For each element that matches +regexp+ return the element that is +offset+ elements forward.
  #
  # Examples:
  #
  # %w[1 2 3].grep_plus_offset(/1/, -1)  => [nil]
  # %w[1 2 3].grep_plus_offset(/1/, 0)   => ['1']
  # %w[1 2 3].grep_plus_offset(/1/, 1)   => ['2']
  # %w[1 2 3].grep_plus_offset(/1/, 2)   => ['3']
  # %w[1 2 3].grep_plus_offset(/1/, 3)   => [nil]
  #
  # caller(0).grep_plus_offset(/in `synchronize'/, 1) => the line that *called* synchronize
  #
  def grep_plus_offset(regexp, offset, wrap_around = false)
    indexes = grep_indexes(regexp).map_send(:+, offset)
    # If any indexes are negative, replace with (maximum index + 1) so that values_at will return
    # nil for that element (instead of returning an element from the end -- values_at(-1) returns
    # the last element, for example), the same as how providing a positive that results in an offset
    # > maximum_index (length - 1) results in a nil being returned for that index.
    indexes.map! {|_| _ < 0 ? length : _ } unless wrap_around
    values_at *indexes
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

  describe %w[1 2 3] do
    it { subject.grep_plus_offset(/1/, -1, true).should == ['3'] }
    it { subject.grep_plus_offset(/1/, -1).should == [nil] }
    it { subject.grep_plus_offset(/1/, 0).should == ['1'] }
    it { subject.grep_plus_offset(/1/, 1).should == ['2'] }
    it { subject.grep_plus_offset(/1/, 2).should == ['3'] }
    it { subject.grep_plus_offset(/1/, 3).should == [nil] }
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
      subject.grep_plus_offset(/in `synchronize'/, 1).should == [
        "bundler/gems/capybara-555008c74751/lib/capybara/node/finders.rb:29:in `find'",
        "bundler/gems/capybara-555008c74751/lib/capybara/node/element.rb:177:in `find'",
      ]
    end
  end
end
=end
