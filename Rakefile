require "mg"
MG.new("limgur.gemspec")

require 'fileutils'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new("test") do |t|
	t.pattern = 'test/test_*.rb'
end
