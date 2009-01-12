# http://tfletcher.com/lib/gradiate.rb
require 'rgb'

class Numeric #:nodoc:
  def diff(n)
    return (self > n ? self - n : n - self)
  end
end

module Enumerable

  # Sorts objects in the enumeration and applies a color scale to them.
  #
  # Color ranges must be in the form [x, y], where x and y are either fixnums
  # (e.g. 255, 0xFF) or hexadecimal strings (e.g. 'FF').
  #
  # Ranges can be provided for each RGB color e.g.
  #
  #   gradiate(:red => red_range)
  #
  # ...and a default range (for all colors) can be set using :all e.g.
  #
  #   gradiate(:all => default_range, :green => green_range)
  #
  # If no color ranges are supplied then the _sorted_ enumeration will be returned.
  #
  # Objects contained in the enumeration are expected to have a color (or colour)
  # attribute/method that returns a <tt>Color::RGB</tt> object (or similar).
  #
  # By default, objects are sorted using <tt>:to_i</tt>. This can be overidden
  # by setting <tt>options[:compare_using]</tt> to a different method symbol.
  #
  # By default, objects are ordered "smallest" first. To reverse this set
  # <tt>options[:order]</tt> to either <tt>:desc</tt> or <tt>:reverse</tt>.
  #
  def gradiate(options={})
    ranges = [:red, :green, :blue].map do |col|
      if range = (options[col] || options[:all])
        a, b = range.map { |x| x.respond_to?(:hex) ? x.hex : x.to_i }
        a, b = b, a if a > b # smallest first
        c = b.diff(a) / (self.size - 1)
        next (a..b).every(c)
      else [] end
    end
    objects = sort_by { |object| object.send(options[:compare_using] || :to_i) }
    objects = objects.reverse if [:desc, :reverse].include?(options[:order])
    objects.zip(*ranges).collect do |object, red, green, blue|
      color = object.respond_to?(:colour) ? object.colour : object.color
      color.red = red if red
      color.green = green if green
      color.blue = blue if blue
      next object
    end
  end

  # Yields every nth object (if invoked with a block),
  # or returns an array of every nth object e.g.
  #
  #   [1, 2, 3, 4, 5, 6].every(2)               -> [1, 3, 5]
  #   [1, 2, 3, 4, 5, 6].every(2) { |i| ... }   -> nil
  #
  def every(n)
    result = [] unless block_given?
    each_with_index do |object, i|
      if i % n == 0
        block_given?? yield(object) : result << object
      end
    end
    return block_given?? nil : result
  end
  
end
