require 'rubygems'
gem 'quality_rake_tasks'
require 'quality_rake_tasks'

#---------------------------------------------------------------------------------------------------------------------------------
# Specification and description

module Project
  PrettyName = "QualityExtensions"
  Name       = "quality_extensions"
  RubyForgeName = "quality-ext"
  Version    = "1.1.0" 
end

specification = Gem::Specification.new do |s|
  s.name    = Project::Name
  s.summary = "A collection of reusable Ruby methods which are not (yet) in Facets."
  s.description = s.summary
  s.version = Project::Version
  s.author  = 'Tyler Rick and others'
  s.email = "rubyforge.org@tylerrick.com"
  s.homepage = "http://#{Project::RubyForgeName}.rubyforge.org/"
  s.rubyforge_project = Project::Name
  s.platform = Gem::Platform::RUBY

  # Documentation
  s.has_rdoc = true
  s.extra_rdoc_files = ['Readme']
  s.rdoc_options << '--title' << Project::Name << '--main' << 'Readme' << '--line-numbers'

  # Files
  s.files = FileList[
    '{lib,test,examples}/**/*.rb',
    'Readme'
  ].to_a
  s.test_file = "test/all.rb"
  s.require_path = "lib"
end

#---------------------------------------------------------------------------------------------------------------------------------
# Tests

task :default => :test
SharedTasks.normal_test_task do |task|
  task.pattern = 'test/all.rb'
end

#---------------------------------------------------------------------------------------------------------------------------------
# Documentation

require 'rake/rdoctask'

SharedTasks.rdoc_task do |task|
  task.title = Project::Name
  task.rdoc_files.include(
    'License'
  ).exclude('**/*.facets.*')
end


#---------------------------------------------------------------------------------------------------------------------------------
# Packaging

SharedTasks.package_task(specification)
SharedTasks.inc_version(__FILE__)

#---------------------------------------------------------------------------------------------------------------------------------
# Publishing

SharedTasks.publish_task

#---------------------------------------------------------------------------------------------------------------------------------
