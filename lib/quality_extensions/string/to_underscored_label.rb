#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: Probably not.
# Developer notes:
# * Can we use a more general method instead (like humanize or methodize)? Does this really have a use distinct from all the other inflection methods out there?
#++

class String
  # Strips out most non-alphanumeric characters and leaves you with a lowercased, underscored string that can safely be used as a class_name 
  def to_underscored_label
    self.
      downcase.
      gsub(/-+/, "_").gsub(/ +/, "_").  # spaces and -'s-> underscores
      gsub(/[^a-z0-9_]/, "").           # keep only alphanumeric and _ characters
      gsub(/_+$/, "").                   # We don't want any _ characters at the end
      gsub(/^_+/, "")                   # ... or the beginning 
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
  def test_to_underscored_label
    assert_equal "discount_amount", "Discount Amount".to_underscored_label
    assert_equal "more_spaces", "More    SPACES".to_underscored_label
    assert_equal "other_123_types_of_characters", "Other-123 Types? Of!!! Characters".to_underscored_label
    assert_equal "weird_characters_on_the_end", "weird characters on the end *#*#**".to_underscored_label
  end
end
=end
