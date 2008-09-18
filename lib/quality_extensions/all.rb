require File.dirname(__FILE__) + "/kernel/require_all"
require_all File.dirname(__FILE__), 
  :exclude => %r{(^|/)test/|nil_method_missing.rb},         # Exclude files with side-effects: Don't include anything in test/ because those files will include test/unit, which causes tests to automatically be run
  :exclude_files => 'all.rb'
