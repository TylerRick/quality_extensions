#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No, too ugly and unreliable.
#++

module Kernel
  # Gets the global variable +var+, which can either be a symbol or an actual global variable (use +:match_object+).
  #  global_variable_get(:$a)
  #  global_variable_get($a, :match_object => true)
  def global_variable_get(var, options = {})
    if options.delete(:match_object)
      return global_variable_get(global_variable_name(var), options)
    else 
      if var.is_a? Symbol
        raise NameError.new("#{var} is not a valid global variable name") unless var.to_s[0..0] == '$'
        return eval("#{var}")
      else
        raise ArgumentError.new("var must be a symbol unless :match_object => true")
      end
    end
  end

  # Looks up the name of global variable +var+, which must be an actual global variable.
  #   global_variable_name($a)
  def global_variable_name(var)
    global_variables.each do |test_var|
      #if eval(test_var).eql?(var)
      if eval(test_var).object_id == var.object_id
        #$stderr.puts "Checking #{test_var}. #{eval(test_var).inspect}" 
        #$stderr.puts "          #{$stdout.inspect}"
        return test_var.to_sym
      end
    end
    raise ArgumentError.new("The given object (#{var.inspect}) (#{var.object_id}) is not a valid global variable")
  end

  # Sets the global variable +var+, which can either be a symbol or an actual global variable (use +:match_object+).
  #  global_variable_set(:$a, 'new')
  #  global_variable_set($a, 'new', :match_object => true)
  #  global_variable_set(:$a, "StringIO.new", :eval_string => true)
  def global_variable_set(var, value, options = {})
    #puts "global_variable_set(#{var}, #{value.inspect}, #{options.inspect}"
    if options.delete(:match_object)
      return global_variable_set(global_variable_name(var), value, options)
    else 
      if var.is_a? Symbol
        raise NameError.new("#{var} is not a valid global variable name") unless var.to_s[0..0] == '$'
        if options.delete(:eval_string)
          #puts("About to eval: #{var} = #{value}")
          eval("#{var} = #{value}")
        else
          marshalled_data = Marshal.dump(value)
          eval("#{var} = Marshal.load(%Q<#{marshalled_data}>)")
        end
        return var
      else
        raise ArgumentError.new("var must be a symbol unless :match_object => true")
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
require 'test/unit'
require 'stringio'

class MyClass
  attr_reader :data
  @data = [:foo]
  def ==(other)
    self.data == other.data
  end
end

class GlobalVariableGetTest < Test::Unit::TestCase
  def test_simple
    $a = 'old'
    assert_equal 'old', global_variable_get(:$a)
    assert_equal :$a, global_variable_name($a)
  end

  def test_can_pass_variable_instead_of_symbol
    $a = 'old'
    assert_equal 'old', global_variable_get($a, :match_object => true)

    $a = :already_a_symbol
    assert_raise(NameError) { global_variable_get($a) }   # If the global ($a) contains a symbol, it will assume we want to get the global variable *named* :$already_a_symbol . Wrong! That's why the :match_object option was introduced.
    assert_nothing_raised   { global_variable_get($a, :match_object => true) }
    assert_equal :already_a_symbol, global_variable_get($a, :match_object => true)
    assert_equal :$a, global_variable_name($a)
  end

  def test_error
    assert_raise(NameError) { global_variable_get(:a) }  # Must be :$a, not :a
  end
end

class GlobalVariableSetTest < Test::Unit::TestCase
  def test_simple
    $a = 'old'
    global_variable_set(:$a, 'new')
    assert_equal('new', $a)
  end

  def test_can_pass_variable_instead_of_symbol
    $a = 'old'
    global_variable_set($a, 'new', :match_object => true)
    assert_equal('new', $a)

    $a = :already_a_symbol
    assert_raise(NameError) { global_variable_set($a, expected = :a_symbol) }   # If the global ($a) contains a symbol, it will assume we want to set the global variable *named* :$already_a_symbol . Wrong! That's why the :match_object option was introduced.
    assert_nothing_raised   { global_variable_set($a, expected = :a_symbol, :match_object => true) }
    global_variable_set(:$a, expected = :a_symbol)
    assert_equal(expected, $a)
  end

  def test_returns_name_of_variable
    $a = 'old'
    assert_equal(:$a, global_variable_set(:$a, 'new'))

    $a = 'old'
    assert_equal(:$a,  global_variable_set($a, 'new', :match_object => true))
  end

  def test_works_for_complex_data_types
    $a = 'old'
    global_variable_set(:$a, expected = {:a => 'a', :b => ['1', 2]})
    assert_equal(expected, $a)

    global_variable_set(:$a, expected = MyClass.new)
    assert !expected.eql?( $a )  # :bug: The way we do it currently, they'll have different object_id's
    assert_equal(expected, $a)

    assert_raise(TypeError) { global_variable_set(:$a, expected = $stdout) } # "can't dump IO". 
    assert_raise(TypeError) { global_variable_set(:$a, expected = StringIO.new) } # "no marshal_dump is defined for class StringIO". That's why the :eval_string option was introduced.
    assert_nothing_raised   { global_variable_set(:$a, expected = "StringIO.new", :eval_string => true) }
    assert $a.is_a?(StringIO)
  end

  def test_error
    assert_raise(NameError) { global_variable_set(:a, 'new') }  # Must be :$a, not :a
  end
end
=end

