#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes!
# Developer notes::
# Changes::
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
require 'rubygems'
require 'facets/kernel/constant'

class Symbol
  # Tries to find a declared constant with the name specified in self.
  #
  #   :Foo.constantize => Foo
  #
  # Unlike ActiveSupport, we don't do this check (because Kernel.module "can handle module hierarchy"):
  #   vendor/rails/activesupport/lib/active_support/inflector.rb
  #     unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
  #       raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
  #     end
  def constantize
    Kernel.constant(self)
  end
end
class String
  # Tries to find a declared constant with the name specified in self.
  #
  #   'Foo'.constantize => Foo
  #
  # Unlike ActiveSupport, we don't do this check (because Kernel.module "can handle module hierarchy"):
  #   vendor/rails/activesupport/lib/active_support/inflector.rb
  #     unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
  #       raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
  #     end
  def constantize
    Kernel.constant(self)
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

module OuterModule; end
module OuterModule::InnerModule; end

class SymbolTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal OuterModule,              :OuterModule.constantize
    assert_equal OuterModule::InnerModule, :'OuterModule::InnerModule'.constantize
  end
end
class StringTest < Test::Unit::TestCase
  module InnerModule; end
  def test_1
    assert_equal OuterModule,              'OuterModule'.constantize
    assert_equal OuterModule::InnerModule, 'OuterModule::InnerModule'.constantize
  end
end
=end

