# http://tfletcher.com/lib/rgb.rb

class Fixnum # :nodoc:
  def to_rgb
    a, b = divmod(65536)
    return b.divmod(256).unshift(a)
  end
end

class String # :nodoc:
  def to_rgb
    self.hex.to_rgb
  end
end

class Symbol # :nodoc:
  def to_rgb
    self.to_s.to_rgb
  end
end

module Color # :nodoc:
  #
  # A lightweight implementation of rgb/hex colors, designed for web use.
  #
  #   c = Color::RGB.new(0xFFFFFF)
  #
  #   c.to_s -> "ffffff"
  #
  #   c.red = 196
  #   c.green = 0xDD
  #   c.blue  = 'EE'
  #
  #   c.to_s -> "c4ddee"
  #
  # Similar to (see also) {ColorTools}[http://rubyforge.org/projects/ruby-pdf].
  #
  class RGB

    # :stopdoc:
    [:red, :green, :blue].each do |col|
      define_method(:"#{col}=") { |value| set!(col, value) }
    end
    # :startdoc:
  
    attr_reader :red, :green, :blue

    # The following are the same color:
    #
    #   RGB.new(0xFFFFFF)
    #   RGB.new(:FFFFFF)
    #   RGB.new("FFFFFF")
    #   RGB.new(255, "FF", 0xFF)
    #
    def initialize(*rgb)
      (rgb.size == 1 ? rgb[0].to_rgb : rgb).zip([:red, :green, :blue]) do |(value, col)|
        set!(col, value)
      end
    end

    # Returns the hexadecimal string representation of the color e.g.
    #
    #   RGB.new(255, 255, 255).to_s  -> "FFFFFF"
    #
    def to_s
      "%02x%02x%02x" % [ red, green, blue ]
    end

  protected

    def set!(color, value)
      value = value.hex if value.respond_to?(:hex)
      unless (0..255) === value
        raise ArgumentError, "#{value.inspect} not in range 0..255"
      end
      instance_variable_set(:"@#{color}", value)
    end

  end
end
