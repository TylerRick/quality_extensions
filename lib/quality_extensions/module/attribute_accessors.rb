# Copied from ActiveSupport because I couldn't get the ones in Facets to work...

# Extends the module object with module and instance accessors for class attributes, 
# just like the native attr* accessors for instance attributes.
class Module # :nodoc:
  def mattr_reader(*syms)
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__+1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end
        
        def self.#{sym}
          @@#{sym}
        end

        def #{sym}
          @@#{sym}
        end
      EOS
    end
  end
  alias_method :cattr_reader, :mattr_reader
  
  def mattr_writer(*syms)
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__+1)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end
        
        def self.#{sym}=(obj)
          @@#{sym} = obj
        end

        def #{sym}=(obj)
          @@#{sym} = obj
        end
      EOS
    end
  end
  alias_method :cattr_writer, :mattr_writer
  
  def mattr_accessor(*syms)
    mattr_reader(*syms)
    mattr_writer(*syms)
  end
  alias_method :cattr_accessor, :mattr_accessor
end
