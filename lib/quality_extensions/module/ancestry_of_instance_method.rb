#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Yes.
# Developer notes::
# * May not have taken every single case into consideration. Needs a bit more testing.
#   * public/private/protected?
# * Tests for this method can be found in ../object/ancestry_of_method.rb . It made more sense to test those two methods together;
#   yet it's still to _use_ module/ancestry_of_instance_method.rb without using ../object/ancestry_of_method.rb.
#++

class Module

  # Returns the module/class which defined the given instance method. If more than one module/class defined the method, returns the _closest_
  # ancestor to have defined it (would be +self+ if it is defined in +self+).
  #
  # This looks at the results of <tt>instance_methods</tt>, which means that if you call this on a module/class, it will _only_ look 
  # at _instance_ methods. Thus, (unlike +ancestry_of_method+) it _only_ makes sense to call this method on modules/classes, 
  # not _instances_ of those modules/classes.
  #
  # Example:
  #   class Base
  #     def it; end
  #   end
  #   class SubWithIt < Base
  #     def it; end
  #   end
  #   class SubWithoutIt < Base
  #   end
  #   SubWithIt.ancestors # => [SubWithIt, Base, Object, Kernel]
  #   SubWithIt.ancestry_of_instance_method(:it)    # => SubWithIt  # (Stops with self)
  #   SubWithoutIt.ancestry_of_instance_method(:it) # => Base       # (Goes one step up the ancestry tree)
  #
  # Returns nil if it cannot be found in self or in any ancestor.
  def ancestry_of_instance_method(method_name)
    method_name = method_name.to_s
    self.ancestors.find do |ancestor|
      ancestor.instance_methods(false).include? method_name
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

class TheTest < Test::Unit::TestCase
  def test_1
  end

end
=end

