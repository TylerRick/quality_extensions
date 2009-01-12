# http://tfletcher.com/lib/dictable.rb
 
# Provides dictionary/hash-like mixin for any enumerable object that yields
# key-value pairs and responds_to :update (the included Dict builds upon Array).
#
# For example:
#
#   require 'dictable'
#
#   a = Dict.new
#  
#   d[:one] = 1
#   d[:two] = 2
#  
#   d[:one]    -> 1
#   d[:ten]    -> nil
#              
#   d.keys     -> [:one, :two]
#   d.values   -> [1, 2]
#   d.to_hash  -> {:two=>2, :one=>1}
#
#
module Dictable
  def [](key)
    each { |(k, v)| return v if k == key }
    return nil
  end
  def []=(key, value)
    update key, value
  end
  def keys
    inject([]) { |keys, (k, v)| keys << k }
  end
  def values
    inject([]) { |values, (k, v)| values << v }
  end
  def to_hash
    inject({}) { |hash, (k, v)| hash.update({ k => v }) }
  end
end

class Dict < Array
  include Dictable
  def update(key, value)
    delete_if { |(k, v)| k == key }
    push [ key, value ]
  end
end
