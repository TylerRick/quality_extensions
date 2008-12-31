#--
# Source::    extensions gem
#++

require 'pp'
require 'stringio'
class Object
  #
  # Returns a pretty-printed string of the object.  Requires libraries +pp+ and
  # +stringio+ from the Ruby standard library.
  #
  # The following code pretty-prints an object (much like +p+ plain-prints an
  # object):
  #
  #   pp object
  #
  # The following code captures the pretty-printing in +str+ instead of
  # sending it to +STDOUT+.
  #
  #   str = object.pp_s 
  #
  def pp_s
    pps = StringIO.new
    PP.pp(self, pps)
    pps.string
  end
end
