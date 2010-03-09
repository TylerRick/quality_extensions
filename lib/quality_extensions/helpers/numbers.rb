#--
# Author::    Tyler Rick
# Copyright:: Ruby on Rails developers
# License::   Ruby on Rails license
# Submit to Facets?:: yes
# Developer notes::
# History::
#++

require 'facets/hash/symbolize_keys'


class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

#-------------------------------------------------------------------------------

module Kernel
  # TODO: use quality_extensions/helpers/numbers instead
  # Adapted from /var/lib/gems/1.9.1/gems/actionpack-2.3.4/lib/action_view/helpers/number_helper.rb

  # Formats a +number+ with grouped thousands using +delimiter+ (e.g., 12,324). You can
  # customize the format in the +options+ hash.
  #
  # ==== Options
  # * <tt>:delimiter</tt>  - Sets the thousands delimiter (defaults to ",").
  # * <tt>:separator</tt>  - Sets the separator between the units (defaults to ".").
  #
  # ==== Examples
  #  number_with_delimiter(12345678)                        # => 12,345,678
  #  number_with_delimiter(12345678.05)                     # => 12,345,678.05
  #  number_with_delimiter(12345678, :delimiter => ".")     # => 12.345.678
  #  number_with_delimiter(12345678, :separator => ",")     # => 12,345,678
  #  number_with_delimiter(98765432.98, :delimiter => " ", :separator => ",")
  #  # => 98 765 432,98
  #
  # You can still use <tt>number_with_delimiter</tt> with the old API that accepts the
  # +delimiter+ as its optional second and the +separator+ as its
  # optional third parameter:
  #  number_with_delimiter(12345678, " ")                     # => 12 345.678
  #  number_with_delimiter(12345678.05, ".", ",")             # => 12.345.678,05
  def number_with_delimiter(number, *args)
    options = args.extract_options!
    options.symbolize_keys!

    unless args.empty?
      ActiveSupport::Deprecation.warn('number_with_delimiter takes an option hash ' +
        'instead of separate delimiter and precision arguments.', caller)
      delimiter = args[0] || '.'
      separator = args[1] || ','
    end

    delimiter ||= (options[:delimiter] || '.')
    separator ||= (options[:separator] || ',')

    begin
      parts = number.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      parts.join(separator)
    #rescue
    #  number
    end
  end

  # Formats a +number+ with the specified level of <tt>:precision</tt> (e.g., 112.32 has a precision of 2).
  # You can customize the format in the +options+ hash.
  #
  # ==== Options
  # * <tt>:precision</tt>  - Sets the level of precision (defaults to 3).
  # * <tt>:separator</tt>  - Sets the separator between the units (defaults to ".").
  # * <tt>:delimiter</tt>  - Sets the thousands delimiter (defaults to "").
  #
  # ==== Examples
  #  number_with_precision(111.2345)                    # => 111.235
  #  number_with_precision(111.2345, :precision => 2)   # => 111.23
  #  number_with_precision(13, :precision => 5)         # => 13.00000
  #  number_with_precision(389.32314, :precision => 0)  # => 389
  #  number_with_precision(1111.2345, :precision => 2, :separator => ',', :delimiter => '.')
  #  # => 1.111,23
  #
  # You can still use <tt>number_with_precision</tt> with the old API that accepts the
  # +precision+ as its optional second parameter:
  #   number_with_precision(number_with_precision(111.2345, 2)   # => 111.23
  def number_with_precision(number, *args)
    options = args.extract_options!
    options.symbolize_keys!

    precision ||= (options[:precision] || 3)
    separator ||= (options[:separator] || '.')
    delimiter ||= (options[:delimiter] || '')

    begin
      rounded_number = (Float(number) * (10 ** precision)).round.to_f / 10 ** precision
      number_with_delimiter("%01.#{precision}f" % rounded_number,
        :separator => separator,
        :delimiter => delimiter)
    #rescue
    #  number
    end
  end

  # Formats the bytes in +size+ into a more understandable representation
  # (e.g., giving it 1500 yields 1.5 KB). This method is useful for
  # reporting file sizes to users. This method returns nil if
  # +size+ cannot be converted into a number. You can customize the
  # format in the +options+ hash.
  #
  # ==== Options
  # * <tt>:base</tt>       - Pass in 2 (or 1024) to use binary units (KiB, MiB),
  #                          pass in 10 (or 1000) to use SI (decimal) units (KB, MB)
  #                          (defaults to base 10).
  # * <tt>:precision</tt>  - Sets the level of precision (defaults to 1).
  # * <tt>:separator</tt>  - Sets the separator between the units (defaults to ".").
  # * <tt>:delimiter</tt>  - Sets the thousands delimiter (defaults to "").
  #
  # ==== Examples
  #  number_to_human_size(123)                                          # => 123 Bytes
  #  number_to_human_size(1234)                                         # => 1.2 KB
  #  number_to_human_size(12345)                                        # => 12.3 KB
  #  number_to_human_size(1234567)                                      # => 1.2 MB
  #  number_to_human_size(1234567890)                                   # => 1.2 GB
  #  number_to_human_size(1234567890123)                                # => 1.2 TB
  #  number_to_human_size(1234567, :precision => 2)                     # => 1.23 MB
  #  number_to_human_size(1234567, :precision => 2, :base => 2)         # => 1.18 MiB
  #  number_to_human_size(483989, :precision => 0)                      # => 484 KB
  #  number_to_human_size(483989, :precision => 0, :base => 2)          # => 473 KiB
  #  number_to_human_size(1234567, :precision => 2, :separator => ',')  # => 1,23 MB
  #
  # ==== Differences from ActiveSupport version
  #  The ActiveSupport version defaults to binary (base 2) units, while this one
  #  defaults to SI (base 10) units.
  #
  #  The ActiveSupport incorrectly uses KB to refer to binary units, when the correct
  #  abbreviation would be KiB (see http://en.wikipedia.org/wiki/Binary_prefix).
  #
  #  This version has a :base option to let you change the base; the ActiveSupport
  #  version does not.
  #
  def number_to_human_size(number, *args)
    return nil if number.nil?

    options = args.extract_options!
    options.symbolize_keys!

    precision ||= (options[:precision] || 1)
    separator ||= (options[:separator] || '.')
    delimiter ||= (options[:delimiter] || ',')
    base      ||= (options[:base]      || 10)

    # http://en.wikipedia.org/wiki/Binary_prefix
    if base == 10 || base == 1000
      storage_units = %w( Bytes KB MB GB TB ).freeze
      base = 1000
    elsif base == 2 || base == 1024
      storage_units = %w( Bytes KiB MiB GiB TiB ).freeze
      base = 1024
    else
      raise ArgumentError, "base must be 1000 or 1024"
    end
    storage_units_format = '%n %u'

    if number.to_i < base
      unit = number.to_i == 1 ? 'byte' : 'bytes'
      storage_units_format.gsub(/%n/, number.to_i.to_s).gsub(/%u/, unit)
    else
      max_exp  = storage_units.size - 1
      number   = Float(number)
      exponent = (Math.log(number) / Math.log(base)).to_i # Convert to base 1024
      exponent = max_exp if exponent > max_exp # we need this to avoid overflow for the highest unit
      number  /= base ** exponent

      unit = storage_units[exponent]

      begin
        escaped_separator = Regexp.escape(separator)
        formatted_number = number_with_precision(number,
          :precision => precision,
          :separator => separator,
          :delimiter => delimiter
        ).sub(/(\d)(#{escaped_separator}[1-9]*)?0+\z/, '\1\2').sub(/#{escaped_separator}\z/, '')
        storage_units_format.gsub(/%n/, formatted_number).gsub(/%u/, unit)
      #rescue
      #  number
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
require 'spec/autorun'

describe 'number_to_human_size' do
  it 'uses decimal unit (KB) when using base 1000' do
    number_to_human_size(524288, :base => 1000).should match(/ KB$/)
  end

  it 'uses the correct conversion when using base 1000' do
    number_to_human_size(524288, :base => 1000).should match(/^524\.3 /)
  end

  it 'uses binary unit (KiB) when using base 1024' do
    number_to_human_size(524288, :base => 1024).should match(/ KiB$/)
  end

  it 'uses the correct conversion when using base 1024' do
    number_to_human_size(524288, :base => 1024).should match(/^512 /)
  end
end

describe 'number_to_human_size examples' do
  it '1234' do
    number_to_human_size(123).should == '123 bytes'
  end

  it '12345' do
    number_to_human_size(12345).should == '12.3 KB'
  end

  it '1234567' do
    number_to_human_size(1234567).should == '1.2 MB'
    number_to_human_size(1234567, :base => 2).should == '1.2 MiB'
  end

  it '1234567890' do
    number_to_human_size(1234567890).should == '1.2 GB'
  end

  it '1234567890123' do
    number_to_human_size(1234567890123).should == '1.2 TB'
  end

  it '1234567' do
    number_to_human_size(1234567, :precision => 2).should == '1.23 MB'
    number_to_human_size(1234567, :precision => 2, :base => 2).should == '1.18 MiB'
  end

  it '483989' do
    number_to_human_size(483989, :precision => 0).should == '484 KB'
    number_to_human_size(483989, :precision => 0, :base => 2).should == '473 KiB'
  end

  it '1234567' do
    number_to_human_size(1234567, :precision => 2, :separator => ',').should == '1,23 MB'
  end
end


=end

