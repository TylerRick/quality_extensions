# Rationale:
# The ||= "operator" is often used to set a default value.
#   var ||= 'default'
# Unfortunately, it does not give the desired behavior for when you want to give a default value to a *boolean* (which might have been already initialized to false).
# When setting a variable to a default value, we actually only want to set it to the default if it's currently set to *nil*!
# This was an attempt to supply that missing method...

module Kernel
  def default!(object, default_value)
    case object
    when NilClass
      #object.become default_value
      #object.replace default_value
    else
    end
  end

end


class NilClass
  def default!(default_value)
    #self.become default_value
    #self.replace default_value
    #self = default_value

    # Not sure how to implemnet this! ... without writing/using a C extension that lets me turn a NilClass object into another object.
  end
end
class Object
  def default!(default_value)
    # This should have no effect on any objects other than instances of NilClass.
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

class Foo
  def do_it(options = {})
    options[:how_many_times] ||= 3
    #options[:actually_do_it]  ||= true     # Doesn't work! What if they explicitly set it to false? We would unconditionally be overriding it with true. We only want to set it to true if it's "not set yet" (if it's nil).
    options[:actually_do_it].default! true  # This is how I'd like to do it. It makes it clear what we're doing (setting a default value).
    options[:actually_do_it] = true if options[:actually_do_it].nil?   # This works, but you have to duplicate the variable name in two places. Plus it's not explicitly clear that true is being used as a *default* value.

    options[:actually_do_it] ? "We did it #{options[:how_many_times]} times" : "We didn't actually do it"
  end
end

class TheTest < Test::Unit::TestCase
  def test_false
    assert_equal "We didn't actually do it", Foo.new.do_it(:actually_do_it => false)
  end
  def test_true
    assert_equal "We did it 3 times", Foo.new.do_it()
  end

end
=end

