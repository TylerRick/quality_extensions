#--
# Author::    Tyler Rick
# Copyright:: Copyright (c) 2007 QualitySmith, Inc.
# License::   Ruby License
# Submit to Facets?:: No, not yet
#++

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

module Kernel
  # Fixes bug in Ruby (1.8, at least -- not sure if 2.0 fixes it) where a file can be required twice if the path is spelled differently.
  def require_once(name)
    raise NotImplementedError
    # store expand_path(name) in an array ($required_files or something)
    # only do the require if it wasn't already in the array
  end
end

