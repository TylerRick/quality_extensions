# http://tfletcher.com/lib/inspect_with.rb
module InspectWith
  class Config
    def with(*vars)
      @variables_to_include = convert(vars)
    end
    
    def without(*vars)
      @variables_to_ignore = convert(vars)
    end
    
    def unspecified?
      variables_to_include.empty? && variables_to_ignore.empty?
    end
    
    def variables_to_include
      @variables_to_include ||= []
    end
    
    def variables_to_ignore
      @variables_to_ignore ||= []
    end

    private
    
    def convert(names)
      names.map { |name| name.is_a?(Symbol) ? "@#{name}" : name }
    end
  end  

  class Inspector
    def initialize(config, object, default_inspect_string)
      @config, @object, @default_inspect_string = config, object, default_inspect_string
    end
    
    def inspect
      return @default_inspect_string if @config.unspecified?
    
      return '%s %s>' % [ @default_inspect_string.split.first, vars.join(' ') ]      
    end
    
    private
    
    def vars
      variable_names.map(&to_key_value { |name| [ name, @object.instance_variable_get(name) ] })
    end

    def variable_names
      if @config.variables_to_include.empty?
        @object.instance_variables - @config.variables_to_ignore
      else
        @config.variables_to_include 
      end
    end
    
    def to_key_value(&block)
      proc { |name| '%s=%p' % block.call(name) }
    end
  end

  module ClassMethods
    def inspect_with_config
      @inspect_with_config ||= Config.new
    end
    
    def inspect_with(*vars)
      inspect_with_config.with(*vars)
    end
    
    def inspect_without(*vars)
      inspect_with_config.without(*vars)
    end
  end

  def inspect
    Inspector.new(self.class.inspect_with_config, self, super).inspect
  end
  
  def self.included(klass)
    klass.extend ClassMethods
  end
end

if __FILE__ == $0 then
  require 'test/unit'
  
  class HtmlElement
    include InspectWith
    
    inspect_with :name
    
    def initialize(name, *children)
      @name, @children = name, children
    end
  end

  class InspectWithTestCase < Test::Unit::TestCase
    def setup
      @div = HtmlElement.new(:div,
        HtmlElement.new(:ul,
          HtmlElement.new(:li, 'Hello'),
          HtmlElement.new(:li, 'World')))
    end

    def test_sanity
      string = @div.inspect

      assert_match /\#<HtmlElement:/, string
      assert_match /@name=:div/, string
      assert_no_match /@children/, string
      assert_equal @div.object_id * 2, string[/(0x.+?) /, 1].hex
    end
  end
end
