# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "quality_extensions/version"

Gem::Specification.new do |s|
  s.name        = "quality_extensions"
  s.version     = QualityExtensions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tyler Rick", "and others"]
  s.email       = ["github.com@tylerrick.com"]
  s.homepage    = %q{http://github.com/TylerRick/quality_extensions}
  s.summary     = %q{A collection of reusable Ruby methods which are not (yet) in Facets.}
  s.description = s.summary

  s.rubyforge_project = "quality_extensions"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
