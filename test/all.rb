#require File.dirname(__FILE__) + "/../lib/kernel/require_all.rb"

require "rubygems"
require "rake" # FileList
require 'exacto'  # Test extractor

#gem 'test_extensions'
#require 'test_extensions'

FileList[File.dirname(__FILE__) + "/../lib/" + "**/**/*.rb"].exclude(/all/).each do |filename|
  begin
    puts "Running #{filename}"
    unless !open(filename).read(300).grep(/^# Alias for:/).empty?
      Exacto::RubyCommand.new([filename]).run
    end
  rescue SystemExit => exception  # "Code block not found" -- we don't care -- keep going already!
  end
  #sh "exrb #{filename}"
end


