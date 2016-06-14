#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc., 2009 Tyler Rick
# License::   Ruby License
# Submit to Facets?::
# Developer notes::
# To do:
# * do the same for refute_equal, which unfortunately does not simply wrap assert_equal
#++
# This file adds a bit of color to your failed string comparisons (assert_equal).
# Differences will be highlighted for you in color so that you can instantly find them.


$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
gem 'colored'
require 'colored'
gem 'facets'
require 'facets/module/alias_method_chain'
require 'quality_extensions/object/send_if'
require 'quality_extensions/string/each_char_with_index'
require 'quality_extensions/module/bool_attr_accessor'
require 'quality_extensions/module/guard_method'
require 'quality_extensions/colored/toggleability'

require 'minitest/unit'

class String
  # For all of the next 3 methods, we will underline spaces so that they are actually visible on the screen.
  # Newlines will be replaced with '\n'"\n".

  # This is a (sub)string that is common to both expected and actual
  def highlight_commonality
    self.
      make_control_characters_visible.
      make_spaces_visible(:green).
      green.bold
      #send_unless(self == ' ', :bold)     # spaces are not bold; '_'s (and everything else) are
  end
  # This is a (sub)string that is different between expected and actual
  def highlight_difference
    self.
      make_control_characters_visible.
      make_spaces_visible(:red).
      red.bold
      #send_unless(self == ' ', :bold)     # spaces are not bold; '_'s (and everything else) are
  end
  # This is a (sub)string that exists only in *self*, not in the other string
  def highlight_unique
    self.
      make_control_characters_visible.
      make_spaces_visible(:magenta).
      magenta
  end
  # This is a (sub)string that doesn't exist in self, only in the *other* string. It's just a placeholder character (a space) that represents a *missing* character.
  def highlight_absence
    self.white.on_cyan.bold
  end
  def make_spaces_visible(color)
    #:todo: Make this optional? Might be useful if you are comparing things with lots of spaces and underscores and you want to be able to tell the difference between them...?
    self.gsub(' ', ' '.send(:"on_#{color}"))
  end
  def make_control_characters_visible 
    self.gsub(/\n/, '\n'+"\n").   # Show '\n' in addition to actually doing the line break
         gsub(/\r/, '\r').        # Just escape it...
         gsub(/\t/, '\t')
    #:todo: Add other control characters?
  end
end

module MiniTest
  # put in class Unit::TestCase ? but how could we access it from methods in Assertions module then?
  @@inspect_strings = false
  mguard_method :inspect_strings!, :@@inspect_strings

  module Assertions

    # The problem with the original convert() is that it always called #inspect on strings... which is fine if you really
    # want to see all those \n's and such. But not so great if you want to visually compare the strings. And if you have
    # ANSI color codes in the strings, it will escape those so that you see the codes (\e[33m1) rather than the nice
    # colored strings that you (sometimes) *want* to see...
    #
    def mu_pp_with_option_to_not_use_inspect_for_strings(object)
      if String === object
        if MiniTest.inspect_strings?
          # Use the original method, which used inspect
          mu_pp_without_option_to_not_use_inspect_for_strings(object)
        else
          object
        end
      else
        # We only care about strings. Everything else can just keep happening like it was before.
        mu_pp_without_option_to_not_use_inspect_for_strings(object)
      end
    end
    alias_method_chain :mu_pp, :option_to_not_use_inspect_for_strings



    @@use_assert_equal_with_highlight = nil
    mguard_method :use_assert_equal_with_highlight!, :@@use_assert_equal_with_highlight

    # The built-in behavior for <tt>assert_equal</tt> method is great for comparing small strings, but not so great for long strings.
    # If both the strings you are dealing with are both 20 paragraphs long, for example, and they differ by only one character,
    # the task of locating and identifying the one character that is off is akin to finding a (literal) needle in a 
    # (literal) haystack (not fun!).
    #
    # link:include/assert_equal_with_difference_highlighting-wheres_waldo.png
    #
    # This replacement/wrapper for <tt>assert_equal</tt> aims to solve all of your string comparison woes (and eventually someday
    # perhaps arrays and hashes as well), helping you to spot differences very quickly and to have fun doing it.
    #
    # Rather than simply showing you the raw (<tt>inspect</tt>ed) +expected+ and +actual+ and expecting you, the poor user, to
    # painstakingly compare the two and figure out exactly which characters are different by yourself this method will *highlight*
    # the differences for you, allowing you to spot them an instant or less!!
    #
    # link:include/assert_equal_with_difference_highlighting-there_he_is.png
    #
    # *Strings*:
    # * Does a characterwise comparison between the two strings. That is, for each index, it will look at the character at that
    #   index and decide if it is the same or different than the character at the same location in the other string. There are
    #   3 1/2 cases:
    #   * *Common* characters are displayed in _green_,
    #   * *Different* characters in _red_,
    #   * Characters that exist <b>in only one string</b> but not the other are displayed in _yellow_
    #     * A _cyan_ <tt>~</tt> will appear that location in the _other_ string, as a placeholder for the <b>missing character</b>.
    # *Arrays*:
    # * [:todo:] 
    # *Hashes*:
    # * [:todo:] 
    #
    # <b>Disabling/enabling highlighting</b>:
    #
    # By default, highlighting is only used when one or both of the strings being compared is long or spans multiple lines. You can override the default with the <tt>:higlight</tt> option:
    #   assert_equal 'really long string', 'another really long string', :highlight => true
    # You can turn it on for all assert_equal assertions by calling
    #   MiniTest::Assertions::use_assert_equal_with_highlight!
    # Or you can just turn it on or off for the duration of a block only:
    #   MiniTest::Assertions::use_assert_equal_with_highlight! do
    #     assert_equal 'really long string', 'another really long string'
    #   end
    #
    # *Notes*:
    # * Spaces are displayed as with a bright colored background so that they are actually visible on the screen (so you can distinguish an empty line from a line with spaces on it, for example).
    # * Newlines are displayed as the text <tt>\n</tt> followed by the actual newline. Other control characters (<tt>\t</tt>, <tt>\r</tt>) are escaped as well so that you can tell what character it is.
    #
    # <b>Difference in method signature</b> from <tt>assert_equal_without_difference_highlighting</tt> (the standard behavior):
    # * The last argument (+options+) is expected to be a hash rather than message=nil, since I don't see the use in passing in a message if
    #   the _default_ message can be made useful enough.
    # * However, for compatibility with existing assert_equal calls, it will check if the 3rd argument is a string and if it is will use it as the failure message.
    # * If you to pass in a message in combination with other options, use <tt>:message => 'my message'</tt>
    #
    # *Advanced*:
    # * If you want everything to be escaped (so you can see the color _codes_ instead of the color itself, for example), use <tt>:inspect_strings => true</tt>
    #
    def assert_equal_with_highlighting(expected, actual, options = {})
      if options.is_a?(String)
        message = options 
        options = {}
      else
        message = options.delete(:message) || nil
      end
      highlight = options.delete(:highlight)

      Assertions.send_unless(highlight.nil?, :use_assert_equal_with_highlight!, highlight) do

        if String===expected and String===actual and expected!=actual and 
            (Assertions.use_assert_equal_with_highlight? || [expected.length, actual.length].max > 80 || [expected, actual].any? {|a| a.include?("\n")}) and
            !(Assertions.use_assert_equal_with_highlight? == false)

          expected_with_highlighting = ''
          actual_with_highlighting = ''
          full_message = nil
          String.color_on! do
            longest_string = [expected, actual].max {|a, b| a.length <=> b.length}
            longest_string.each_char_with_index do |i, exp|
              exp = expected[i] ? expected[i].chr : nil
              act = actual[i]   ? actual[i].chr   : nil
              if act.nil?
                expected_with_highlighting << exp.highlight_unique
                actual_with_highlighting   << '~'.highlight_absence
              elsif exp.nil?
                expected_with_highlighting << '~'.highlight_absence
                actual_with_highlighting   << act.highlight_unique
              elsif exp != act
                expected_with_highlighting << exp.highlight_difference
                actual_with_highlighting   << act.highlight_difference
              else
                expected_with_highlighting << exp.highlight_commonality
                actual_with_highlighting   << exp.highlight_commonality
              end

            end
            full_message = message(message) { <<End }
#{(' '*50 + ' Expected: ' + ' '*50).blue.underline.on_white }
#{expected_with_highlighting}
#{(' '*50 + ' But was:  ' + ' '*50).yellow.underline.on_red }
#{actual_with_highlighting}
End
          end
            MiniTest.inspect_strings!(options.delete(:inspect_strings) || false) do
              assert(expected == actual, full_message)
            end
        else
          assert_equal_without_highlighting(expected, actual, message)
        end

      end # use_assert_equal_with_highlight!

    end # def assert_equal_with_highlighting
    alias_method_chain :assert_equal, :highlighting

  end # module Assertions
end

#puts MiniTest::Assertions.instance_methods








#  _____         _
# |_   _|__  ___| |_
#   | |/ _ \/ __| __|
#   | |  __/\__ \ |_
#   |_|\___||___/\__|
#
=begin test
require 'minitest/autorun'
#MiniTest::Assertions::use_assert_equal_with_highlight!

# :todo: Currently these (intentionally failing) tests are just manual and require visual inspection. If possible it would be 
# nice to capture the output of the failure and make an assertion against that. But I'm not sure how to do that...

class TheTest < MiniTest::Unit::TestCase
  def test01_single_character_differences
    assert_equal <<End, <<End
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed feugiat mi. In sagittis, augue non eleifend sodales, arcu urna congue sapien, aliquet molestie pede urna sit amet dolor. Etiam diam. Vestibulum ornare, felis et porta faucibus, magna sapien vulputate arcu, vel facilisis lectus ipsum et ipsum.

Vivamus massa odio, lacinia eu, euismod vitae, lobortis eu, erat. Duis tincidunt, neque ac_tincidunt convallis, nibh tellus sodales eros, ut tristique nunc purus in urna. Nullam semper. Fusce quis augue ut metus interdum congue. Duis id dolor eu mi pellentesque sagittis. Quisque imperdiet orci a odio.
End
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed feugiat mi. In sagittis, augue non eleifend sodales, arcu urna congue sapien, aliquet molestie pede urna sit amet dolor. Etiam diam. Vestibulum ornare, felis et porta faucibus, magna sapien vulputate arcu, vel facilisis lectus ipsum et ipsum.

Vivamus massa odio, lacinia eu, euismod vitae, lobortis eu, erat. Duis tincidunt, neque ac tincidunt convallis, nibh tellus sodales eros, ut tristique nunc purus in urna. Nullam semper. Fusce quis augue ut metus interdum congue. Duis id color eu mi pellentesque sagittis. Quisque imperdiet orci a odio.
End
  end

  def test02_difference_in_control_characters
    assert_equal "Lorem ipsum dolor sit amet,\nconsectetuer adipiscing elit.\nSed feugiat mi.",
                 "Lorem ipsum_dolor sit amet, consectetuer\tadipiscing elit.\n\rSed feugiat mi.", :highlight => true
  end

  def test03_expected_is_longer
    assert_equal '1234567890', '123', :highlight => true
  end

  def test04_actual_is_longer
    assert_equal '123', '1234567890', :highlight => true
  end

  # Use the ones above this line as screenshot material...

  def test05_one_is_much_longer
    assert_equal <<End, <<End
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed feugiat mi. In sagittis, augue non eleifend sodales, arcu urna congue sapien, aliquet molestie pede urna sit amet dolor. Etiam diam. Vestibulum ornare, felis et porta faucibus, magna sapien vulputate arcu, vel facilisis lectus ipsum et ipsum. Sed dictum, dolor suscipit malesuada pharetra, orci augue lobortis lectus, porta porta magna magna ut dui. Duis viverra enim sed felis. Mauris semper volutpat pede. Integer lectus lorem, lacinia in, iaculis ut, euismod non, nulla. Nunc non libero eget diam congue ornare. Nunc dictum tellus sed turpis. Sed venenatis, pede non ultricies pharetra, dolor felis malesuada nisl, id imperdiet lorem dui vel velit.
End
Lorem ipsum dolor sit amet
End
  end

  def test06_only_minor_single_character_differences_but_then_it_gets_out_of_sync
    assert_equal <<End, <<End
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed feugiat mi. In sagittis, augue non eleifend sodales, arcu urna congue sapien.

Vivamus massa odio, lacinia eu, euismod vitae, lobortis eu, erat. Duis tincidunt, neque ac tincidunt convallis, nibh tellus sodales eros, ut tristique nunc purus in urna. Nullam semper. Fusce quis augue ut metus interdum congue. Duis id dolor eu mi pellentesque sagittis. Quisque imperdiet orci a odio.
End
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Sed feugiat mi. In sagittis, argue non eleifend sodales, arcu urna conque sapien.

Vivamus massa odio, lacinia eu, euismod vitae, lobortis eu, erat. Duis tincidunt, neque ac tincidunt convallis, nibh tellus sodales eros, ut tristique nunc purus in urna. Nullam semper. Fusce quis augue ut metus interdum congue. Duis id dolor eu mi pellentesque sagittis. Quisque imperdiet orci a odio.
End
  end

  def test07_underscores_versus_underlines
    assert_equal <<End, <<End
___[Underscores]___[Underscores]   [Spaces] _ _ _ _ _ [Mix]
End
   [Spaces]     ___[Underscores]   [Spaces] _ _ __ _ _[Mix]     
End
  end

  def test08_inspect_strings_true
    assert_equal '1234567890', '123', :inspect_strings => true
  end
  def test09_inspect_highlight_false
    assert_equal '1234567890', '123', :highlight => false
  end
  def test10_highlight_false
    MiniTest::Assertions::use_assert_equal_with_highlight! false do
      assert_equal 'really long string', 'another really long string'
    end
  end
  def test11_highlight_true
    MiniTest::Assertions::use_assert_equal_with_highlight! do
      assert_equal 'really long string', 'another really long string'
    end
  end
  def test12_compatibility__using_arg3_as_message
    assert_equal 'really long string', 'another really long string', 'This is my message! Can you see it?'
  end
  def test13_that_assert_nil_still_works
    # Exposed a bug that existed previously, where it tried to do "".delete(:message)
    assert_nil nil
  end

end
=end


